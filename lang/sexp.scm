;; todo: remove implicit UTF-8 conversion from parser and move to a separate pass

(define-library (lang sexp)

   (export
      sexp-parser
      read-exps-from
      list->number
      get-sexps       ;; greedy* get-sexp
      string->sexp
      vector->sexps
      list->sexps
      fd->exp-stream
      file->exp-stream

      ; io
      read
      ; parser
      get-number
      )

   (import
      (scheme core)
      (r5rs srfi-1)

      (owl parse)
      (owl math)
      (owl string)
      (owl list)
      (owl math-extra)
      (owl vector)
      (owl list-extra)
      (owl ff)
      (owl lazy)
      (owl io) ; testing
      (owl unicode)
      (only (owl interop) interact)
      (only (lang intern) string->symbol string->uninterned-symbol)
      (only (owl regex) get-sexp-regex))

   (begin

      (define (between? lo x hi) ; fast version of (<= lo x hi))
         (and
            (or (less? lo x)
               (eq? lo x))
            (or (less? x hi)
               (eq? x hi))))

      (define special-initial-chars (string->runes "!$%&*+-/:<=>?^_~")) ; dot(.) reserved for numbers and pairs, sorry.
      (define special-subseqent-chars (string->runes "@"))

      (define (symbol-lead-char? n)
         (or
            (between? #\a n #\z)
            (between? #\A n #\Z)
            (has? special-initial-chars n)
            (> n 127)))         ;; allow high code points in symbols

      (define (symbol-char? n)
         (or
            (symbol-lead-char? n)
            (between? #\0 n #\9)
            (has? special-subseqent-chars n)))

      (define get-symbol
         (get-either
            (let-parses
               ((head (get-rune-if symbol-lead-char?))
                (tail (get-greedy* (get-rune-if symbol-char?)))
                (next (peek get-byte))
                (foo (assert (lambda (b) (not (symbol-char? b))) next))) ; avoid useless backtracking
               (string->uninterned-symbol (runes->string (cons head tail))))
            (let-parses
               ((skip (get-imm #\|))
                (chars (get-greedy+ (get-rune-if (λ (x) (not (eq? x #\|))))))
                (skip (get-imm #\|)))
               (string->uninterned-symbol (runes->string chars)))))

;      (define (digit-char? x)
;         (or
;            (between? #\0 x #\9)
;            (between? #\A x #\F)
;            (between? #\a x #\f)))

      (define digit-values (list->ff
            (foldr append null
               (list
                  (map (lambda (d i) (cons d i)) (iota 10 #\0) (iota 10 0))  ;; 0-9
                  (map (lambda (d i) (cons d i)) (iota  6 #\A) (iota 6 10))  ;; A-F
                  (map (lambda (d i) (cons d i)) (iota  6 #\a) (iota 6 10))  ;; a-f
                  ))))

      (define bases (list->ff '(
         (#\b . 2)
         (#\o . 8)
         (#\d .10)
         (#\x .16))))

      (define (digit-char? base)
         (if (eq? base 10)
            (λ (n) (between? #\0 n #\9))
            (λ (n) (< (get digit-values n 100) base)))) ; base should be less than 100

      (define (bytes->number digits base)
         (fold
            (λ (n digit)
               (let ((d (get digit-values digit #false)))
                  (cond
                     ((or (not d) (>= d base))
                        (runtime-error "bad digit " digit))
                     (else
                        (+ (* n base) d)))))
            0 digits))

      (define get-sign
         (get-any-of (get-imm #\+) (get-imm #\-) (get-epsilon #\+)))
      (define get-signer
         (let-parses
               ((char get-sign))
            (if (eq? char #\+)
               (λ (x) x)
               negate)))


      (define (get-natural base)
         (let-parses
               ((digits (get-greedy+ (get-byte-if (digit-char? base)))))
            (bytes->number digits base)))

      (define (get-integer base)
         (let-parses
               ((sign get-signer)
                (n (get-natural base)))
            (sign n)))

      ;; → n, to multiply with
      ; r7rs accepts only exponent in base 10
      (define get-exponent
         (get-either
            (let-parses
                  ((skip (get-imm #\e))
                   (pow (get-integer 10)))
               (expt 10 pow))
            (get-epsilon 1)))

      ;; separate parser with explicitly given base for string->number
      (define (get-number-in-base base)
         (let-parses
               ((sign get-signer) ;; default + <- could allow also an optional base here
                (num (get-integer base))
                (tail(get-either ;; optional after dot part be added
                        (let-parses
                              ((skip (get-imm #\.))
                               (digits (get-greedy* (get-byte-if (digit-char? base)))))
                           (/ (bytes->number digits base)
                              (expt base (length digits))))
                        (get-epsilon 0)))
                (pow get-exponent))
            (sign (* (+ num tail) pow))))

      ;; a sub-rational (other than as decimal notation) number
      (define get-base
         (get-any-of
            (let-parses
                  ((skip (get-imm #\#))
                   (char (get-byte-if (λ (x) (getf bases x)))))
               (getf bases char))
            (get-epsilon 10)))

      (define get-number-unit
         (let-parses
               ((base get-base) ;; default 10
                (val (get-number-in-base base)))
            val))

      ;; anything up to a rational
      (define get-rational
         (let-parses
               ((val (let-parses
                     ((n get-number-unit)
                      (m (get-either
                           (let-parses
                                 ((skip (get-imm #\/))
                                 (m get-number-unit)
                                 (verify (not (eq? 0 m)) "zero denominator")) ; todo: remove verifier
                              m)
                           (get-epsilon 1))))
                  (/ n m))))
            val))

      (define get-imaginary-part
         (let-parses
               ((sign get-signer)
                (imag (get-either get-rational (get-epsilon 1))) ; we also want 0+i
                (skip (get-imm #\i)))
            (sign imag)))

      ; https://srfi.schemers.org/srfi-77/srfi-77.html
      (setq |+inf.0| (vm:fp2 #xF9 1 0)) ; 1 / 0 = +infin
      (setq |-inf.0| (vm:fp2 #xF9 -1 0));-1 / 0 = -infin
      (setq |+nan.0| (vm:fp2 #xF9 0 0)) ; 0 / 0 = NaN

      (define get-number
         (get-any-of
            (get-word "+inf.0" |+inf.0|)
            (get-word "-inf.0" |-inf.0|)
            (get-word "+nan.0" |+nan.0|)
            (let-parses
                  ((real get-rational) ;; typically this is it
                   (imag (get-either get-imaginary-part (get-epsilon 0))))
               (if (eq? imag 0)
                  real
                  (complex real imag)))))


      (define get-rest-of-line
         (let-parses
            ((chars (get-greedy* (get-byte-if (lambda (x) (not (eq? x 10))))))
             (skip (get-imm 10))) ;; <- note that this won't match if line ends to eof
            chars))

      ;; #!<string>\n parses to '(hashbang <string>)
      (define get-hashbang
         (let-parses
            ((hash (get-imm #\#))
             (bang (get-imm #\!))
             (line get-rest-of-line))
            (list 'quote (list 'hashbang (list->string line)))))

      ;; skip everything up to |#
      (define (get-block-comment)
         (get-either
            (let-parses
               ((skip (get-imm #\|))
                (skip (get-imm #\#)))
               'comment)
            (let-parses
               ((skip get-byte)
                (skip (get-block-comment)))
               skip)))

      (define get-a-whitespace
         (get-any-of
            ;get-hashbang   ;; actually probably better to make it a symbol as above
            (get-byte-if (lambda (x) (has? '(#\tab #\newline #\space #\return) x)))
            (let-parses
               ((skip (get-imm #\;))
                (skip get-rest-of-line))
               'comment)
            (let-parses
               ((skip (get-imm #\#))
                (skip (get-imm #\|))
                (skip (get-block-comment)))
               'comment)))

      (define maybe-whitespace (get-kleene* get-a-whitespace))
      (define whitespace (get-greedy+ get-a-whitespace))

      (define (get-list-of parser)
         (let-parses
            ((lp (get-imm #\())
             (things
               (get-kleene* parser))
             (skip maybe-whitespace)
             (tail
               (get-either
                  (let-parses ((rp (get-imm #\)))) null)
                  (let-parses
                     ((dot (get-imm #\.))
                      (fini parser)
                      (skip maybe-whitespace)
                      (skip (get-imm #\))))
                     fini))))
            (if (null? tail)
               things
               (append things tail))))

      (define quoted-values
         (list->ff
            '((#\a . #x0007)
              (#\b . #x0008)
              (#\t . #x0009)
              (#\n . #x000a)
              (#\r . #x000d)
              (#\e . #x001B)
              (#\" . #x0022) ;"
              (#\\ . #x005c))))

      (define get-quoted-string-char
         (let-parses
            ((skip (get-imm #\\))
             (char
               (get-either
                  (let-parses
                     ((char (get-byte-if (λ (byte) (getf quoted-values byte)))))
                     (getf quoted-values char))
                  (let-parses
                     ((skip (get-imm #\x))
                      (hexes (get-greedy+ (get-byte-if (digit-char? 16))))
                      (skip (get-imm #\;)))
                     (bytes->number hexes 16)))))
            char))

      (define get-string
         (let-parses
            ((skip (get-imm #\")) ;"
             (chars
               (get-kleene*
                  (get-either
                     get-quoted-string-char
                     (get-rune-if (lambda (x) (not (has? '(#\" #\\) x))))))) ;"
             (skip (get-imm #\"))) ;"
            (runes->string chars)))

      (define quotations
         (list->ff '((#\' . quote) (#\, . unquote) (#\` . quasiquote) (splice . unquote-splicing))))

      (define (get-quoted parser)
         (let-parses
            ((type
               (get-either
                  (let-parses ((_ (get-imm #\,)) (_ (get-imm #\@))) 'splice) ; ,@
                  (get-byte-if (λ (x) (get quotations x #false)))))
             (value parser))
            (list (get quotations type #false) value)))

      (define get-named-char
         (get-any-of
            (get-word "null"      #\null)      ; 0
            (get-word "alarm"     #\alarm)     ; 7
            (get-word "backspace" #\backspace) ; 8
            (get-word "tab"       #\tab)       ; 9
            (get-word "newline"   #\newline)   ;10
            (get-word "return"    #\return)    ;13
            (get-word "escape"    #\escape)    ;27
            (get-word "space"     #\space)     ;32
            (get-word "delete"    #\delete))) ;127

      ;; fixme: add named characters #\newline, ...
      (define get-quoted-char
         (let-parses
            ((skip (get-imm #\#))
             (skip (get-imm #\\))
             (codepoint (get-either get-named-char get-rune)))
            codepoint))

      ;; most of these are to go via type definitions later
      (define get-funny-word
         (get-any-of
            (get-word "..." '...)
            (let-parses
               ((skip (get-imm #\#))
                (val
                  (get-any-of
                     (get-word "false" #false)
                     (get-word "true"  #true)    ;; get the longer ones first if present
                     (get-word "null"  #null)
                     (get-word "empty" #empty)
                     (get-word "eof"   #eof)     ; (vm:cast 4 13))
                     ; сокращения
                     (get-word "t"     #true)
                     (get-word "f"     #false)
                     (get-word "T"     #true)
                     (get-word "F"     #false)
                     (get-word "e"     #empty)
                     (let-parses
                        ((bang (get-imm #\!)) ; sha-bang
                         (line get-rest-of-line))
                        (list 'quote (list 'hashbang (list->string line)))))))
               val)))

      (define (intern-symbols sexp)
         (cond
            ((symbol? sexp)
               (string->symbol (ref sexp 1)))
            ((pair? sexp)
               (cons (intern-symbols (car sexp)) (intern-symbols (cdr sexp))))
            (else sexp)))

      (define (get-vector-of parser)
         (let-parses
            ((skip (get-imm #\#))
             (fields (get-list-of parser)))
            (let ((fields (intern-symbols fields)))
               (if (first pair? fields #false)
                  ;; vector may have unquoted stuff, so convert it to a sexp constructing a vector, which the macro handler can deal with
                  (cons '_sharp_vector fields) ; <- quasiquote macro expects to see this in vectors
                  (list->vector fields)))))

      (define (get-sexp)
         (let-parses
            ((skip maybe-whitespace)
             (val
               (get-any-of
                  ;get-hashbang
                  get-number         ;; more than a simple integer
                  get-sexp-regex     ;; must be before symbols, which also may start with /
                  get-symbol
                  get-string
                  get-funny-word
                  (get-list-of (get-sexp))
                  (get-vector-of (get-sexp))
                  (get-quoted (get-sexp))
                  (get-byte-if eof?)
                  get-quoted-char)))
            val))

      (define (ok? x) (eq? (ref x 1) 'ok))
      (define (ok exp env) (tuple 'ok exp env))
      (define (fail reason) (tuple 'fail reason))

      (define sexp-parser
         (let-parses
            ((sexp (get-sexp))
             (foo maybe-whitespace))
            (intern-symbols sexp)))

      (define get-sexps
         (get-greedy* sexp-parser))

      ;; fixme: new error message info ignored, and this is used for loading causing the associated issue
      (define (read-exps-from data done fail)
         (lets/cc ret  ;; <- not needed if fail is already a cont
            ((data
               (utf8-decoder data
                  (λ (self line data)
                     (ret (fail (list "Bad UTF-8 data on line " line ": " (ltake line 10))))))))
            (sexp-parser data
               (λ (data drop val pos)
                  (cond
                     ((eof? val) (reverse done))
                     ((null? data) (reverse (cons val done))) ;; only for non-files
                     (else (read-exps-from data (cons val done) fail))))
               (λ (pos reason)
                  (if (null? done)
                     (fail "syntax error in first expression")
                     (fail (list 'syntax 'error 'after (car done) 'at pos))))
               0)))

      (define (list->number lst base)
         (try-parse (get-number-in-base base) lst #false #false #false))

      (define (string->sexp str fail)
         (try-parse (get-sexp) (str-iter str) #false #false fail))

      ;; parse all contents of vector to a list of sexps, or fail with
      ;; fail-val and print error message with further info if errmsg
      ;; is non-false

      (define (vector->sexps vec fail errmsg)
         ; try-parse parser data maybe-path maybe-error-msg fail-val
         (let ((lst (vector->list vec)))
            (try-parse get-sexps lst #false errmsg #false)))

      (define (list->sexps lst fail errmsg)
         ; try-parse parser data maybe-path maybe-error-msg fail-val
         (try-parse get-sexps lst #false errmsg #false))


      ; exp streams reader
      ;; todo: fd->exp-stream could easily keep track of file name and line number to show also those in syntax error messages

      ; rchunks fd block? -> rchunks' end?
      ;; bug: maybe-get-input should now use in-process mail queuing using return-mails interop at the end if necessary
      (define (maybe-get-input rchunks fd block? prompt)
         (let ((chunk (try-get-block fd 1024 #false)))
            ;; handle received input
            (cond
               ((not chunk) ;; read error in port
                  (values rchunks #true))
               ((eq? chunk #true) ;; would block
                  (sleep 5) ;; interact with sleeper thread to let cpu sleep
                  (values rchunks #false))
               ((eof? chunk) ;; normal end if input, no need to call me again
                  (values rchunks #true))
               (else
                  (maybe-get-input (cons chunk rchunks) fd #false prompt)))))

      (define (push-chunks data rchunks)
         (if (null? rchunks)
            data
            (append data
               (foldr append null
                  (map vec->list (reverse rchunks))))))

      ; -> lazy list of parser results, possibly ending to ... (fail <pos> <info> <lst>)

      (define (fd->exp-stream fd prompt parse fail)
         (let loop ((old-data #null) (block? #true) (finished? #false)) ; old-data not successfullt parseable (apart from epsilon)
            (lets
               ((rchunks end?
                  (if finished?
                     (values null #true)
                     (maybe-get-input null fd (or (null? old-data) block?)
                        (if (null? old-data) prompt "|   "))))
                (data (push-chunks old-data rchunks)))
               (if (null? data)
                  (if end? null (loop data #true #false))
                  (parse data
                     (λ (data-tail backtrack val pos)
                        (pair val
                           (if (and finished? (null? data-tail))
                              null
                              (loop data-tail (null? data-tail) end?))))
                     (λ (pos info)
                        (cond
                           (end?
                              ; parse failed and out of data -> must be a parse error, like unterminated string
                              (list (fail pos info data)))
                           ((= pos (length data))
                              ; parse error at eof and not all read -> get more data
                              (loop data #true end?))
                           (else
                              (list (fail pos info data)))))
                     0)))))


   ; (parser ll ok fail pos)
   ;      -> (ok ll' fail' val pos)
   ;      -> (fail fail-pos fail-msg')

      (define (file->exp-stream path prompt parse fail)
         (let ((fd (open-input-file path)))
            (if fd
               (fd->exp-stream fd prompt parse fail)
               #false)))

      (define (syntax-fail pos info lst)
         (list #f info
            (list ">>> " "x" " <<<")))

      (define (read-impl in)
         (fd->exp-stream in "" sexp-parser syntax-fail))

      (define read
         (case-lambda
            ((in)
               (car (read-impl in)))
            (()
               (car (read-impl stdin)))))

))
