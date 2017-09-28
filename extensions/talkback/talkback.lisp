;(import (owl unicode))
(import (lang eval)
        (lang sexp)
        (lang threading)
        (lang intern)

        (lang env)
        (lang macro)
        (lang sexp)

        (lang ast)
        (lang fixedpoint)
        (lang alpha)
        (lang cps)
        (lang closure)
        (lang assemble)
        (lang compile))
(import (owl parse)
        (scheme misc))


; ==============================================================================
;; fixme: should sleep one round to get a timing, and then use avg of the last one(s) to make an educated guess
(define (sleep ms)
   (lets ((end (+ ms (time-ms))))
      (let loop ()
         ;(print (interop 18 1 1))
         (let ((now (time-ms)))
            (if (> now end)
               now
               (begin (interact sleeper-id 50) (loop)))))))

; -> mcp gets <cont> 5 reason info
; (run <mcp-cont> thunk quantum) -> result

(define input-chunk-size  1024)
(define output-chunk-size 4096)

(define-syntax share-bindings
   (syntax-rules (defined)
      ((share-bindings) null)
      ((share-bindings this . rest)
         (cons
            (cons 'this
               (tuple 'defined (mkval this)))
            (share-bindings . rest)))))

(define (share-modules mods)
   (for null mods
      (λ (envl mod)
         (append (ff->list mod) envl))))

;(import (owl random))

(import (owl args))
(import (owl sys))

;; implementation features, used by cond-expand
(define *features*
   (cons
      (string->symbol (string-append "owl-lisp-" *owl-version*))
      '(owl-lisp r7rs exact-closed ratios exact-complex full-unicode immutable)))
      ;;          ^
      ;;          '-- to be a fairly large subset of at least, so adding this

(import (lang eval))

;; push it to libraries for sharing, replacing the old one
(define *libraries* ; заменим старую (src olvm) на новую
   (cons
      (cons '(src olvm) *src-olvm*)
      (keep (λ (x) (not (equal? (car x) '(src olvm)))) *libraries*)))

;; todo: share the modules instead later
(define shared-misc
   (share-bindings
      *features*
      *include-dirs*
      *libraries*))      ;; all currently loaded libraries



;;;
;;; MCP, master control program and the thread controller
;;;

(define shared-bindings shared-misc)

(define initial-environment-sans-macros
   (fold
      (λ (env pair) (env-put-raw env (car pair) (cdr pair)))
      *src-olvm*
      shared-bindings))

(define initial-environment
   (bind-toplevel
      (library-import initial-environment-sans-macros
         '((otus lisp))
         (λ (reason) (error "bootstrap import error: " reason))
         (λ (env exp) (error "bootstrap import requires repl: " exp)))))

(define *version*
   (let loop ((args *vm-args*))
      (if (null? args)
         (cdr (vm:version))
      (if (string-eq? (car args) "--version")
         (if (null? (cdr args))
            (runtime-error "no version in command line" args)
            (cadr args))
         (loop (cdr args))))))


;(define (next-newline-distance lst)
;   (let loop ((lst lst) (pos 0))
;      (cond
;         ((null? lst) (values pos lst))
;         ((eq? (car lst) 10) (values (+ pos 1) (cdr lst)))
;         (else (loop (cdr lst) (+ pos 1))))))
;
;(define (find-line data error-pos)
;   ;(print " - find-line")
;   (let loop ((data data) (pos 0))
;      ;(print* (list "data " data " pos " pos  " error-pos " error-pos))
;      (lets ((next datap (next-newline-distance data)))
;         (cond
;            ((<= error-pos next)
;               (runes->string (take data (- next 1)))) ; take this line
;            ((null? data)
;               "(end of input)")
;            (else
;               (loop datap next))))))

(define syntax-error-mark (list 'syntax-error))
(define (syntax-fail pos info lst)
   (list syntax-error-mark info
      (list ">>> " #|(find-line lst pos)|# " <<<")))
(define (syntax-error? x) (and (pair? x) (eq? syntax-error-mark (car x))))


(define (repl-ok env value) (tuple 'ok value env))
(define (repl-fail env reason)
   (let ((seterrno (env-get env 'seterrno #f)))
      ;(print-to stderr "\nseterrno: " seterrno))
      (if seterrno (seterrno)))
    (tuple 'error reason env))





(define (repl env in)
   (let loop ((env env) (in in) (last 'blank)) ; last - последний результат
      (cond
         ((null? in)
            (repl-ok env last))
         ((pair? in)
            (lets ((this in (uncons in #false)))
               (cond
                  ((eof? this)
                     (repl-ok env last))
                  ((syntax-error? this)
                     (repl-fail env (cons "This makes no sense: " (cdr this))))
                  (else
                     (tuple-case (eval-repl this env repl)
                        ((ok result env)
                           (loop env in result))
                        ((fail reason)
                           (repl-fail env reason)))))))
         (else
            (loop env (in) last)))))

(define (repl-trampoline env in out)
   (let boing ((env env))
      (let ((env (bind-toplevel env)))
         (tuple-case (repl env (fd->exp-stream in "" sexp-parser syntax-fail #false))
            ((ok val env)
               (halt 0))
            ((error reason env)
               ; better luck next time
               (cond
                  ((list? reason)
                     (print-to out reason)
                     (boing env))
                  (else
                     (print-to out reason)
                     (boing env))))
            (else is foo
               (boing env))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; new repl image
;;;

;; say hi if interactive mode and fail if cannot do so (the rest are done using
;; repl-prompt. this should too, actually)
(define (get-main-entry symbols codes)
   (let*((initial-names   *owl-names*)
         (initial-version *owl-version*))
      ; main: / entry point of the compiled image
      (λ (vm-args)
         ;(print "//vm-args: " vm-args)
         ;; now we're running in the new repl
         (start-thread-controller
            (list ;1 thread
               (tuple 'init
                  (λ ()
                     (let ((IN  (vm:cast (string->integer (car  vm-args)) type-port))
                           (OUT (vm:cast (string->integer (cadr vm-args)) type-port)))
                     (fork-server 'repl (lambda ()
                        ;; get basic io running
                        (io:init)

                        ;; repl needs symbol and bytecode interning,
                        ;;  which is handled by this threads
                        (fork-intern-interner symbols)
                        (fork-bytecode-interner codes)

                        ;; set a signal handler which stop evaluation instead of owl
                        ;; if a repl eval thread is running
                        (set-signal-action repl-signal-handler) ; TODO: change

                        ;; repl
                        (exit-owl
                           (let*((home (or (getenv "OL_HOME")
                                           (cond
                                              ((string-eq? (ref (uname) 1) "Windows") "C:/Program Files/OL")
                                              (else "/usr/lib/ol")))) ; Linux, *BSD, etc.
                                 (version (cons "OL" *version*))
                                 (env (fold
                                          (λ (env defn)
                                             (env-set env (car defn) (cdr defn)))
                                          initial-environment
                                          (list
                                             (cons '*owl-names*   initial-names)
                                             (cons '*owl-version* initial-version)
                                             (cons '*include-dirs* (list "." home))
                                             (cons '*interactive* #false)
                                             (cons '*vm-args* vm-args)
                                             (cons '*version* version)
                                             (cons '*sandbox* #false)

                                             (cons 'IN IN)
                                             (cons 'OUT OUT)
                                          ))))
                              (repl-trampoline env IN OUT)
                              ;(let boing ((env env))
                              ;   (let ((env (bind-toplevel env)))
                              ;      (tuple-case (repl-port env IN)
                              ;         ((ok val env)
                              ;            ;; bye-bye
                              ;            (halt 0))
                              ;         ((error reason renv)
                              ;            ;(print-to stderr ">" (env-get env 'seterrno #false))
                              ;            ; notify error:
                              ;            (error env "error :)")
                              ;            ;(let ((seterrno (env-get env 'seterrno #false)))
                              ;            ;   ;(print-to stderr "seterrno: " seterrno)
                              ;            ;   (if seterrno (seterrno))) ;(print "###### seterrno!")))
                              ;            ; post error text in output buffer
                              ;            (cond
                              ;               ((list? reason)
                              ;                  (print-to OUT "1")
                              ;                  ;(print-to OUT reason)
                              ;                  (boing renv))
                              ;               (else
                              ;                  (print-to OUT "2")
                              ;                  ;(print-to OUT reason)
                              ;                  (boing renv))))
                              ;         (else is foo
                              ;            (boing env)))))
                              ))))))))
            )))) ; no threads state


;(define symbols (symbols-of get-main-entry))
;(define codes   (codes-of   get-main-entry))

;;;
;;; Dump the new repl
;;;

;--
(define (symbols-of node)
   (define tag (list 'syms))

   (define (walk trail node)
      (cond
         ((value? node) trail)
         ((get trail node #false) trail)
         ((symbol? node)
            (let ((trail (put trail node 1)))
               (put trail tag
                  (cons node (get trail tag null)))))
         ((vm:raw? node)
            (cond
               ((eq? (type node) type-bytecode) #t)
               ((eq? (type node) type-string) #t)
               ((eq? (type node) type-port) #t)
               ((eq? (type node) type-vector-raw) #t)
               (else (print "unknown raw object: " node)))
            trail)
         (else
            (fold walk
               (put trail node #true)
               (tuple->list node)))))
   (define trail
      (walk (put empty tag null) node))

   (get
      (walk (put empty tag null) node)
      tag null))

;--
(define (code-refs seen obj)
   (cond
      ((value? obj) (values seen empty))
      ((bytecode? obj)
         (values seen (put empty obj 1)))
      ((get seen obj #false) =>
         (λ (here) (values seen here)))
      (else
         (let loop ((seen seen) (lst (tuple->list obj)) (here empty))
            (if (null? lst)
               (values (put seen obj here) here)
               (lets ((seen this (code-refs seen (car lst))))
                  (loop seen (cdr lst)
                     (ff-union this here +))))))))
(define (codes-of ob)
   (lets ((refs this (code-refs empty ob)))
      (ff-fold (λ (out x n) (cons (cons x x) out)) null this)))



; compile the talkback:
(let*((symbols (symbols-of get-main-entry))
      (codes   (codes-of   get-main-entry))
      (entry   (get-main-entry symbols codes))
      (bytes (fasl-encode entry)))

   (let*((path "talkback")
         (port (open-output-file path)))

      (write-bytes port bytes)
      (close-port port))

   (display "unsigned char *talkback = (unsigned char*) \"")
   (for-each (lambda (x)
                (display "\\x")
                (display (string (ref "0123456789abcdef" (div x 16))))
                (display (string (ref "0123456789abcdef" (mod x 16)))))
      bytes)
   (display "\";")
)
