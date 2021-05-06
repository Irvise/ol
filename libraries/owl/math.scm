;;;
;;; Basic math library
;;;

;; todo: split this to separate libraries for fixnums, integers, rationals etc?
;; todo: add a simple school-long-division using vm:div to get the top digit usually fairly right and see where the breakeven point is for other methods

;; todo: factor this to smaller libraries

;; wishlist: pi, e, ... (as iterators)
;; todo: remove the cast instruction (only used here iirc)
;; wishlist: complex numbers not implemented yet
;; fixme: at least main base bignum functions (+ - * =) should handle the full dispatch

;; write this sans big(gish) humbers in code to allow changing

; todo: read this http://www.fitc.unc.edu.ar/javadev/math/previous/algorithms.html
; todo: move all math to folder math

(define-library (owl math)

   (export
      = < > <= >=
      zero? positive? negative? odd? even?
      square

      + - * = /
      << >>
      band bor bxor
      div ediv rem mod quotrem divmod
      add nat-succ sub mul big-bad-args negate
      gcd gcdl lcm
      min max minl maxl
      quotient quot
      floor ceiling ceil abs
      sum product
      numerator denumerator
      ilog ilog2
      render-number
      denominator numerator
      remainder modulo
      truncate round
      rational complex
      
      math-constructor)

   (import
      (scheme core)
      (owl math fp)
      (owl list)
      (owl ff))

   (begin
      (define o (λ (f g) (λ (x) (f (g x)))))

      (define-syntax ncons
         (syntax-rules ()
            ((ncons a d) (vm:new type-int+ a d))))

      (define ncar car)
      (define ncdr cdr)

      (define-syntax lets (syntax-rules () ((lets . stuff) (let* . stuff)))) ; TEMP

;      now changed to vm call (vm:maxvalue)

      ;; biggest before highest bit is set (needed in some bignum ops)
      ; эта функция довольно редко вызывается
      (define (*pre-max-fixnum*) ; TODO: сделать константой, не вызовом функции
         (let* ((f o (vm:shr (vm:maxvalue) 1)))
            f))

;      now changed to vm call (vm:valuewidth)

      ; this is special internal "number" that is not a number
      ; should not be a type-int+
      (setq *big-one* (cons 1 #null)) ; this 

      ; same
      (setq *first-bignum* (cons 0 *big-one*))

      ; same
      (setq *big-zero* (cons 0 #null))

      ;; deprecated primop
      ;(define-syntax fxdivmod
      ;   (syntax-rules ()
      ;      ((fxdivmod a b)
      ;         (lets ((q1 q2 r (vm:div 0 a b)))
      ;            (values q2 r)))))

      (define (copy! to from)  ; * internal helper
         (define start 0)
         (define end (size to))
         (let loop ((p start))
            (when (less? p end)
               (set-ref! to p (ref from p))
               (loop (++ p)))))

      ; создадим библиотечный конструктор (экспериментальная фича)
      (define math-constructor (vm:cast (lambda ()
            ; floating point constants:
            (copy! +nan.0 (fsqrt -1))
         ) 63))

      ; ========================================================
      ; procedure:  (zero? z)
      (setq |0.| (vm:cast 0 type-inexact)) ; * internal

      (define (zero? x)
         (or
            (eq? x 0)
            (equal? x |0.|)))

      (assert (zero? 0)              ===>  #t)
      (assert (zero? 4)              ===>  #f)
      (assert (zero? (fsub 7 7))     ===>  #t)
      (assert (zero? (fadd 7 7))     ===>  #f)


      ; procedure:  (positive? z)
      (define (positive? x)
         (case (type x)
            (type-enum+ #true)
            (type-int+ #true)
            (type-enum- #false)
            (type-rational
               (let* ((n d x))
                  (positive? n)))
            (type-inexact
               (or
                  (fless? |0.| x)
                  (equal? x |0.|)
                  (equal? x +inf.0)))))

      (assert (positive? -1)       ===> #false)
      (assert (positive? -11111111111111111111111) ===> #false)
      (assert (positive? 42)       ===> #true)
      (assert (positive? 111111111111111111111111) ===> #true)
      (assert (positive? -3/7)     ===> #false)
      (assert (positive? 3/-7)     ===> #false)
      (assert (positive? 17/9)     ===> #true)
      (assert (positive? -inf.0)   ===> #false)
      (assert (positive? +inf.0)   ===> #true)
      (assert (positive? +nan.0)   ===> #false)
      (assert (positive? |0.|)     ===> #true)


      ; procedure:  (negative? z)
      (define (negative? x)
         (case (type x)
            (type-enum- #true)
            (type-int- #true)
            (type-enum+ #false)
            (type-rational
               (let* ((n d x))
                  (negative? n)))
            (type-inexact
               (or
                  (fless? x |0.|)
                  (equal? x -inf.0)))))

      (assert (negative? -1)       ===> #true)
      (assert (negative? -11111111111111111111111) ===> #true)
      (assert (negative? 42)       ===> #false)
      (assert (negative? 111111111111111111111111) ===> #false)
      (assert (negative? -3/7)     ===> #true)
      (assert (negative? 3/-7)     ===> #true)
      (assert (negative? 17/9)     ===> #false)
      (assert (negative? -inf.0)   ===> #true)
      (assert (negative? +inf.0)   ===> #false)
      (assert (negative? +nan.0)   ===> #false)
      (assert (negative? |0.|)     ===> #false)









      (define-syntax define-traced
         (syntax-rules ()
            ((define-traced (name arg ...) . whatever)
               (define (name arg ...)
                  (print (list (quote name) (list (quote arg) '= arg) ...))
                  . whatever))))

      (define (nrev-walk num to)
         (if (eq? num #null)
            to
            (nrev-walk
               (ncdr num)
               (ncons (ncar num) to))))

      (define-syntax nrev
         (syntax-rules ()
            ((nrev num)
               (nrev-walk num #null))))

      (define (big-bad-args op a b)
         (runtime-error "Bad math:" (list op a b)))

      (define (big-unimplemented op a b)
         (runtime-error "Math too high:" (list op a b)))


      ;;;
      ;;; COMPARISON
      ;;;

      ; looks like big-digits-equal? === equal?
      (define (big-digits-equal? a b)
         (cond
            ((eq? a b) #true)      ; shared tail or both empty
            ((eq? a #null) #false)
            ((eq? b #null) #false)
            ((eq? (ncar a) (ncar b))
               (big-digits-equal? (ncdr a) (ncdr b)))
            (else #false)))

      (define (big-less a b lower)
         (cond
            ((eq? a b)    ; both ended or shared tail
               lower)
            ((eq? a #null) #true)
            ((eq? b #null) #false)
            (else
               (let ((ad (ncar a)) (bd (ncar b)))
                  (cond
                     ((less? ad bd)
                        (big-less (ncdr a) (ncdr b) #true))
                     ((eq? ad bd)
                        (big-less (ncdr a) (ncdr b) lower))
                     (else
                        (big-less (ncdr a) (ncdr b) #false)))))))

      ;; fixnum/integer <
      (define (int< a b)
         (case (type a)
            (type-enum+
               (case (type b)
                  (type-enum+ (less? a b))
                  (type-int+ #true)
                  (else #false)))
            (type-enum-
               (case (type b)
                  (type-enum+ #true)
                  (type-enum- (less? b a))
                  (type-int+ #true)
                  (else #false)))
            (type-int+
               (case (type b)
                  (type-int+ (big-less a b #false))
                  (else #false)))
            (type-int-
               (case (type b)
                  ; todo: rewrite
                  (type-int-
                     (if (big-less a b #false) #false #true))
                  (else #true)))
            (else
               (big-bad-args 'int< a b))))

      ;        =       (compare-numbers a b #false #true #false)
      ;(define (> a b)  (compare-numbers a b #false #false #true))
      ;(define (>= a b) (compare-numbers a b #false #true #true))
      ;(define (< a b) (compare-numbers a b #true #false #false))
      ;(define (<= a b) (compare-numbers a b #true #true #false))



      ; a slightly optimized =

      (define (= b a)
         (case (type a)
            (type-enum+ (if (eq? (type b) type-inexact) (equal? (inexact a) b) (eq? a b)))
            (type-enum- (if (eq? (type b) type-inexact) (equal? (inexact a) b) (eq? a b)))
            (type-int+
               (case (type b)
                  (type-int+ (big-digits-equal? a b))
                  (type-inexact (equal? (inexact a) b))
                  (else #false)))
            (type-int-
               (case (type b)
                  (type-int- (big-digits-equal? a b))
                  (type-inexact (equal? (inexact a) b))
                  (else #false)))
            (type-rational
               (case (type b)
                  (type-rational
                     ;; todo: add eq-simple to avoid this becoming recursive
                     (if (= (ncar a) (ncar b))
                        (= (ncdr a) (ncdr b))
                        #false))
                  (type-inexact (equal? (inexact a) b))
                  (else #false)))
            (type-complex
               (if (eq? (type b) type-complex)
                  (and (= (ref a 1) (ref b 1))
                       (= (ref a 2) (ref b 2)))
                  #false))
            (type-inexact
               ; complex means "have an 'i'", so it's definitely not equal
               (unless (eq? (type b) type-complex)
                  (equal? a (inexact b))))
            (else
               (big-bad-args '= a b))))

      ; assert (= +inf.0 +inf.0)
      ; assert (not (= -inf.0 +inf.0))
      ; assert (= -inf.0 -inf.0)

      ; later just, is major type X



      ;;;
      ;;; ADDITION
      ;;;

      (define (nat-succ n)
         (let ((t (type n)))
            (cond
               ((eq? t type-enum+)
                  (if (eq? n (vm:maxvalue))
                     *first-bignum*
                     (lets ((n x (vm:add n 1))) n)))
               ((eq? t type-int+)
                  (let ((lo (ncar n)))
                     (if (eq? lo (vm:maxvalue))
                        (ncons 0 (nat-succ (ncdr n)))
                        (lets ((lo x (vm:add lo 1)))
                           (ncons lo (ncdr n))))))
               ((eq? n #null)
                  *big-one*)
               (else
                  (big-bad-args 'inc n n)))))

      (define (nlen n)
         (cond
            ((eq? (type n) type-enum+) 1)
            ((eq? (type n) type-enum-) 1)
            (else
               (let loop ((n n) (i 0))
                  (if (null? n)
                     i
                     (loop (ncdr n) (nat-succ i)))))))

      (define (add-number-big a big)
         (lets
            ((b bs big)
             (new overflow? (vm:add a b)))
            (if overflow?
               (if (eq? bs #null)
                  (ncons new *big-one*)
                  (ncons new (add-number-big 1 bs)))
               (ncons new bs))))

      (define (add-big a b carry)
         (cond
            ((eq? a #null)
               (if (eq? b #null)
                  (if carry *big-one* #null)
                  (if carry (add-number-big 1 b) b)))
            ((eq? b #null)
               (if carry (add-number-big 1 a) a))
            (else
               (lets ((r o (vm:add (ncar a) (ncar b))))
                  (if carry
                     (lets ((r o2 (vm:add r 1)))
                        (cond
                           (o (ncons r (add-big (ncdr a) (ncdr b) #true)))
                           (o2 (ncons r (add-big (ncdr a) (ncdr b) #true)))
                           (else (ncons r (add-big (ncdr a) (ncdr b) #false)))))
                     (ncons r
                        (add-big (ncdr a) (ncdr b) o)))))))

      (define-syntax add-small->positive
         (syntax-rules ()
            ((add-small->positive a b)
               (lets ((r overflow? (vm:add a b)))
                  (if overflow? (ncons r *big-one*) r)))))




      ;;;
      ;;; SUBSTRACTION
      ;;;

      (define-syntax sub-small->pick-sign
         (syntax-rules ()
            ((sub-small->pick-sign a b) ; todo: переделать!
               (lets ((r uf? (vm:sub a b)))
                  (if uf?
                     (lets ((r _ (vm:sub b a))) ;; could also fix here by adding or bitwise
                        (vm:cast r type-enum-))
                     r)))))

      ; bignum - fixnum -> either
      (define (sub-big-number a b leading?)
         (lets ((r underflow? (vm:sub (ncar a) b)))
            (cond
               (underflow?
                  (let ((tail (sub-big-number (ncdr a) 1 #false)))
                     (cond
                        (tail (ncons r tail))   ; otherwise tail went to 0
                        (leading? r)
                        ((eq? r 0) #false)
                        (else (ncons r #null)))))
               ((eq? r 0)
                  (let ((tail (ncdr a)))
                     (if (eq? tail #null)
                        (if leading? r #false)
                        (ncons r tail))))
               (else
                  (ncons r (ncdr a))))))

      ; a - B = a + -B = -(-a + B) = -(B - a)

      (define (sub-number-big a b first?)
         (let ((res (sub-big-number b a #true)))
            ; res is either fixnum or bignum
            (case (type res)
               (type-enum+ (vm:cast res type-enum-))
               (else (vm:cast res type-int-)))))


      ; substract from a, which must be bigger

      (define (sub-digits a b borrow? leading?)
         (cond
            ((eq? a #null)
               #false)
            ((eq? b #null)
               (if borrow?
                  (sub-big-number a 1 leading?)
                  a))
            (else
               (lets ((r u? (vm:sub (ncar a) (ncar b))))
                  (if borrow?
                     (lets ((r u2? (vm:sub r 1)))
                        (let ((tail
                           (cond
                              (u? (sub-digits (ncdr a) (ncdr b) #true #false))
                              (u2? (sub-digits (ncdr a) (ncdr b) #true #false))
                              (else
                                 (sub-digits (ncdr a) (ncdr b) #false #false)))))
                           (cond
                              (tail (ncons r tail))
                              (leading? r)
                              ((eq? r 0) #false)
                              (else (ncons r #null)))))

                     (let ((tail (sub-digits (ncdr a) (ncdr b) u? #false)))
                        (cond
                           (tail (ncons r tail))
                           (leading? r)
                           ((eq? r 0) #false)
                           (else (ncons r #null)))))))))


      ; A - B = -(B - A)

      (define (sub-big a b)
         (cond
            ((big-less a b #false)
               (let ((neg (sub-digits b a #false #true)))
                  (cond
                     ((eq? neg 0) neg)
                     ((eq? (type neg) type-enum+) (vm:cast neg type-enum-))
                     (else (vm:cast neg type-int-)))))
            (else
               (sub-digits a b #false #true))))

      ; add bits, output is negative

      (define (add-small->negative a b)
         (lets ((r overflow? (vm:add a b)))
            (if overflow?
               (vm:cast (ncons r *big-one*) type-int-)
               (vm:cast r type-enum-))))


      ; for changing the (default positive) sign of unsigned operations
      (define-syntax negative
         (syntax-rules (imm vm:cast if fix+)
            ((negative (op . args))
               (let ((foo (op . args)))
                  (negative foo)))
            ((negative x)
               (if (eq? (type x) type-enum+)
                  (vm:cast x type-enum-)
                  (vm:cast x type-int-)))))

      (define-syntax rational
         (syntax-rules ()
            ((rational a b) (vm:new type-rational a b))))

      (define (negate num)
         (case (type num)
            (type-enum+
               (if (eq? num 0)
                  0
                  (vm:cast num type-enum-)))      ;; a  -> -a
            (type-enum- (vm:cast num type-enum+)) ;; -a ->  a
            (type-int+                ;;  A -> -A
               (vm:new type-int- (ncar num) (ncdr num)))
            (type-int-             ;; -A -> A
               (vm:new type-int+ (ncar num) (ncdr num)))
            (type-rational
               (let* ((a b num))
                  (rational (negate a) b)))
            (type-inexact
               (fsub 0 num))
            (else
               (big-bad-args 'negate num #false))))


      ;;;
      ;;; Addition and substraction generics
      ;;;

      (define (addi a b)
         (case (type a)
            (type-enum+ ; a signed fixnum
               (case (type b)
                  (type-enum+ (add-small->positive a b))            ;; +a + +b -> c | C
                  (type-enum- (sub-small->pick-sign a b))         ;; +a + -b -> +c | -c, underflow determines sign
                  (type-int+ (add-number-big a b))               ;; +a + +B -> +C
                  (type-int- (sub-number-big a b #true))         ;; +a + -B -> -c | -C
                  (else (big-bad-args 'add a b))))
            (type-enum-
               (case (type b)
                  (type-enum+ (sub-small->pick-sign b a))         ;; -a + +b == +b + -a -> as above (no need to recurse)
                  (type-enum- (add-small->negative a b))         ;; -a + -b -> -c | -C
                  (type-int+ (sub-big-number b a #true))            ;; -a + +B == +B - +a -> sub-big-number
                  (type-int- (vm:cast (add-number-big a b) type-int-))   ;; -a + -B == -C == -(a + B)
                  (else (big-bad-args 'add a b))))
            (type-int+
               (case (type b)
                  (type-enum+ (add-number-big b a))               ;; +A + +b -> +C
                  (type-enum- (sub-big-number a b #true))            ;; +A + -b == -b + +A -> as above
                  (type-int+ (add-big a b #false))                  ;; +A + +B == +C
                  (type-int- (sub-big a b))                     ;; +A + -B == +c | -c | +C | -C
                  (else (big-bad-args 'add a b))))
            (type-int-
               (case (type b)
                  (type-enum+ (sub-number-big b a #true))            ;; -A + +b == +b + -A -> as above
                  (type-enum- (vm:cast (add-number-big b a) type-int-))      ;; -A + -b == -b + -A = -C -> as above
                  (type-int+ (sub-big b a))                     ;; -A + +B == +B + -A -> as above
                  (type-int- (vm:cast (add-big a b #false) type-int-))      ;; -A + -B == -(A + B)
                  (else (big-bad-args 'add a b))))
            (else
               (big-bad-args 'add a b))))

      ; substraction is just just opencoded (+ a (negate b))

      ;; substraction for at most bignum integers (needed for the more complex ones)
      (define (subi a b)
         (case (type a)
            (type-enum+ ; a signed fixnum
               (case (type b)
                  (type-enum+   (sub-small->pick-sign a b))         ;; +a - +b -> as +a + -b
                  (type-enum- (add-small->positive a b))         ;; +a - -b -> as +a + +b
                  (type-int+ (sub-number-big a b #true))            ;; +a - +B -> as +a + -B
                  (type-int-   (add-number-big a b))            ;; +a - -B -> as +a + +B
                  (else (big-bad-args '- a b))))
            (type-enum-
               (case (type b)
                  (type-enum+ (add-small->negative a b))            ;; -a - +b -> as -a + -b
                  (type-enum- (sub-small->pick-sign b a))         ;; -a - -b -> as -a + +b
                  (type-int+ (vm:cast (add-number-big a b) type-int-))   ;; -a - +B -> as -a + -B
                  (type-int- (sub-big-number b a #true))         ;; -a - -B -> as -a + +B
                  (else (big-bad-args '- a b))))
            (type-int+
               (case (type b)
                  (type-enum+ (sub-big-number a b #true))            ;; +A - +b -> as +A + -b
                  (type-enum- (add-number-big b a))               ;; +A - -b -> as +A + +b
                  (type-int+ (sub-big a b))                     ;; +A - +B -> as +A + -B
                  (type-int- (add-big a b #false))                  ;; +A - -B -> as +A + +B
                  (else (big-bad-args '- a b))))
            (type-int-
               (case (type b)
                  (type-enum+ (vm:cast (add-number-big b a) type-int-))      ;; -A - +b -> as -A + -b
                  (type-enum- (sub-number-big b a #true))            ;; -A - -b -> as -A + +b
                  (type-int+ (vm:cast (add-big a b #false) type-int-))         ;; -A - +B -> as -A + -B
                  (type-int- (sub-big b a))                     ;; -A - -B -> as -A + +B
                  (else (big-bad-args '- a b))))
            (else
               (big-bad-args '- a b))))




      ;;;
      ;;; BITWISE OPERATIONS
      ;;;

      ; vm:and, vm:ior, vm:shl, vm:shr
      ; vm:and, fxor -> result
      ; vm:shl -> hi + lo
      ; vm:shr -> hi + lo

      (define (shift-right-walk this rest n first?)
         (if (eq? rest #null)
            (cond
               (first?  this)
               ((eq? this 0) #false)
               (else
                  (ncons this #null)))
            (let ((next (ncar rest)))
               (lets ((hi lo (vm:shr next n)))
                  (lets
                     ((this (vm:ior this lo))
                      (tail (shift-right-walk hi (ncdr rest) n #false)))
                     (cond
                        (tail (ncons this tail))
                        ((eq? this 0)
                           (if first? 0 #false))
                        (else
                           (if first? this
                              (ncons this #null)))))))))

      (define (shift-right a n)
         (if (eq? a #null)
            0
            (lets ((hi lo (vm:shr (ncar a) n)))
               (shift-right-walk hi (ncdr a) n #true))))

      ; words known to be fixnum
      (define (drop-digits a words)
         (cond
            ((eq? words 0) a)
            ((eq? a #null) a)
            (else
               (lets ((words _ (vm:sub words 1)))
                  (drop-digits (ncdr a) words)))))

      ; optimize << and >> since they will be heavily used in subsequent ops

      (define (>> a b)
         (case (type b)
            (type-enum+
               (lets ((_ wor bits (vm:div 0 b (vm:valuewidth))))
                  (if (eq? wor 0)
                     (case (type a)
                        (type-enum+ (values-apply (vm:shr a bits) (lambda (hi lo) hi)))
                        (type-enum- (values-apply (vm:shr a bits) (lambda (hi lo) (if (eq? hi 0) 0 (negate hi)))))
                        (type-int+ (shift-right a bits))
                        (type-int- (negative (shift-right a bits)))
                        (else (big-bad-args '>> a b)))
                     (case (type a)
                        (type-enum+ 0)
                        (type-enum- 0)
                        (type-int+ (shift-right (drop-digits a wor) bits))
                        (type-int-
                           (negative
                              (shift-right (drop-digits a wor) bits)))
                        (else (big-bad-args '>> a b))))))
            (type-int+
               ;; todo, use digit multiples instead or drop each digit
               (if (eq? a 0)
                  0 ;; terminate early if out of bits
                  (>> (ncdr a) (subi b (vm:valuewidth)))))
            (else
               (big-bad-args '>> a b))))

      ; make a digit with last as low bits
      (define (shift-left num n last)
         (if (eq? num #null)
            (if (eq? last 0)
               #null
               (ncons last #null))
            (lets ((hi lo (vm:shl (ncar num) n)))
               (ncons (vm:ior last lo)
                  (shift-left (ncdr num) n hi)))))

      ; << quarantees n is a fixnum
      (define (extend-digits num n)
         (if (eq? n 0)
            num
            (lets ((n _ (vm:sub n 1)))
               (extend-digits (ncons 0 num) n))))

      ; fixme: a << b = a * 2^b for other numbers
      ; thus #b0.0001 << 4 = 1

      (define (<< a b)
         (cond
            ((eq? a 0) 0)
            ((eq? (type b) type-enum+)
               (lets ((_ words bits (vm:div 0 b (vm:valuewidth))))
                  (case (type a)
                     (type-enum+
                        (lets ((hi lo (vm:shl a bits)))
                           (if (eq? hi 0)
                              (if (eq? words 0)
                                 lo
                                 (extend-digits (ncons lo #null) words))
                              (if (eq? words 0)
                                 (ncons lo (ncons hi #null))
                                 (extend-digits
                                    (ncons lo (ncons hi #null))
                                    words)))))
                     (type-enum-
                        (lets ((hi lo (vm:shl a bits)))
                           (if (eq? hi 0)
                              (if (eq? words 0)
                                 (vm:cast lo type-enum-)
                                 (vm:cast
                                    (extend-digits (ncons lo #null) words)
                                    type-int-))
                              (vm:cast
                                 (extend-digits
                                    (ncons lo (ncons hi #null)) words)
                                 type-int-))))
                     (type-int+
                        (extend-digits (shift-left a bits 0) words))
                     (type-int-
                        (vm:cast (extend-digits (shift-left a bits 0) words) type-int-))
                     (else
                        (big-bad-args '<< a b)))))
            ((eq? (type b) type-int+)
               ;; not likely to happen though
               (<< (<< a (vm:maxvalue)) (subi b (vm:maxvalue))))
            (else
               ;; could allow negative shift left to mean a shift right, but that is
               ;; probably more likely an accident than desired behavior, so failing here
               (big-bad-args '<< a b))))

      (define (big-band a b)
         (cond
            ((eq? a #null) 0)
            ((eq? b #null) 0)
            (else
               (lets
                  ((this (vm:and (ncar a) (ncar b)))
                   (tail (big-band (ncdr a) (ncdr b))))
                  (cond
                     ((eq? tail 0) this)
                     ((eq? (type tail) type-enum+)
                        (ncons this (ncons tail #null)))
                     (else
                        (ncons this tail)))))))

      ;; answer is quaranteed to be a bignum
      (define (big-bor a b)
         (cond
            ((eq? a #null) b)
            ((eq? b #null) a)
            (else
               (lets
                  ((this (vm:ior (ncar a) (ncar b)))
                   (tail (big-bor (ncdr a) (ncdr b))))
                  (ncons this tail)))))

      ;; → null | bignum
      (define (big-bxor-digits a b)
         (cond
            ((null? a) b)
            ((null? b) a)
            (else
               (lets
                  ((this (vm:xor (ncar a) (ncar b)))
                   (tail (big-bxor-digits (ncdr a) (ncdr b))))
                  (if (null? tail)
                     (if (eq? this 0)
                        #null
                        (ncons this tail))
                     (ncons this tail))))))

      (define (big-bxor a b)
         (let ((r (big-bxor-digits a b)))
            (cond
               ;; maybe demote to fixnum
               ((null? r) 0)
               ((null? (ncdr r)) (ncar r))
               (else r))))

      ; not yet defined for negative
      (define (band a b)
         (case (type a)
            (type-enum+
               (case (type b)
                  (type-enum+ (vm:and a b))
                  (type-int+ (vm:and a (ncar b)))
                  (else
                     (big-bad-args 'band a b))))
            (type-int+
               (case (type b)
                  (type-enum+
                     (vm:and (ncar a) b))
                  (type-int+
                     (big-band a b))
                  (else
                     (big-bad-args 'band a b))))
            (else
               (big-bad-args 'band a b))))

      (define (even? n) (eq? 0 (band n 1)))
      (define (odd?  n) (eq? 1 (band n 1)))

      (define (bor a b)
         (case (type a)
            (type-enum+
               (case (type b)
                  (type-enum+ (vm:ior a b))
                  (type-int+
                     (ncons (vm:ior a (ncar b))
                        (ncdr b)))
                  (else
                     (big-bad-args 'bor a b))))
            (type-int+
               (case (type b)
                  (type-enum+
                     (ncons (vm:ior b (ncar a))
                        (ncdr a)))
                  (type-int+
                     (big-bor a b))
                  (else
                     (big-bad-args 'bor a b))))
            (else
               (big-bad-args 'bor a b))))

      (define (bxor a b)
         (case (type a)
            (type-enum+
               (case (type b)
                  (type-enum+ (vm:xor a b))
                  (type-int+
                     (ncons (vm:xor a (ncar b)) (ncdr b)))
                  (else
                     (big-bad-args 'bxor a b))))
            (type-int+
               (case (type b)
                  (type-enum+
                     (ncons (vm:xor b (ncar a)) (ncdr a)))
                  (type-int+
                     (big-bxor a b))
                  (else
                     (big-bad-args 'bxor a b))))
            (else
               (big-bad-args 'bxor a b))))



      ;;;
      ;;; MULTIPLICATION
      ;;;

      ; O(n), basic multiply bignum b by fixnum a with carry

      (define (mult-num-big a b carry)
         (cond
            ((eq? b #null)
               (if (eq? carry 0)
                  #null
                  (ncons carry #null)))
            ((eq? carry 0)
               (lets ((lo hi (vm:mul a (ncar b))))
                  (ncons lo
                     (mult-num-big a (ncdr b) hi))))
            (else
               (lets
                  ((lo hi (vm:mul a (ncar b)))
                   (lo o? (vm:add lo carry)))
                  (if o?
                     (lets ((hi o? (vm:add hi 1)))
                        (ncons lo
                           (mult-num-big a (ncdr b) hi)))
                     (ncons lo
                        (mult-num-big a (ncdr b) hi)))))))

      ; O(1), fixnum multiply overflowing to bignum

      ;(define (mult-fixnums a b)
      ;   (values-apply (vm:mul a b)
      ;      (lambda (lo hi)
      ;         (if (eq? hi 0)
      ;            lo
      ;            (ncons lo (ncons hi #null))))))

      (define-syntax mult-fixnums
         (syntax-rules ()
            ((mult-fixnums a b)
               (lets ((lo hi (vm:mul a b)))
                  (if (eq? hi 0)
                     lo
                     (ncons lo (ncons hi #null)))))))


      ;;;
      ;;; Big multiplication
      ;;;

      ; current approach: karatsuba + schoolboy algorithm for small numbers

      ; ensure bigness
      (define (bigen x)
         (if (eq? (type x) type-enum+)
            (ncons x #null)
            x))

      ; a + (b << ex*16)
      (define (add-ext a b ex)
         (cond
            ((eq? ex 0) (if (null? a) (bigen b) (addi a b)))
            ((null? a)
               (ncons 0
                  (add-ext #null b (subi ex 1))))
            ((eq? (type a) type-enum+) (add-ext (ncons a #null) b ex))
            ((eq? (type ex) type-enum+)
               (lets
                  ((ex u (vm:sub ex 1))
                   (d ds a))
                  (ncons d (add-ext ds b ex))))
            (else
               (ncons (ncar a)
                  (add-ext (ncdr a) b (subi ex 1))))))

      ; fixme, should just keep jumbo digits for for added versions and
      ;        perform the carrying just once in a final pass. add merges
      ;        and high parts (if any) of the digits are the carriables.
      ; can be used for small bignums
      (define (mul-simple a b)
         (if (null? a)
            #null
            (lets ((digit (ncar a))
                (head (ncons 0 (mul-simple (ncdr a) b)))
                (this (mult-num-big digit b 0)))
               (addi head this))))

      ; downgrade to fixnum if length 1
      (define (fix n)
         (if (null? (ncdr n)) (ncar n) n))

      ; drop leading zeros, reverse digits and downgrade to fixnum if possible
      (define (fixr n)
         (if (null? n)
            0
            (lets ((d ds n))
               (cond
                  ((null? ds) d)
                  ((eq? d 0) (fixr ds))
                  (else (nrev n))))))

      ; cut numbers from the midpoint of smaller while counting length (tortoise and hare akimbo)
      (define (splice-nums ah bh at bt rat rbt s? l)
         (cond
            ((null? ah)
               (values (fix at) (fixr rat) (fix bt) (fixr rbt) l))
            ((null? bh)
               (values (fix at) (fixr rat) (fix bt) (fixr rbt) l))
            (s?
               (splice-nums (ncdr ah) (ncdr bh) at bt rat rbt #false l))
            (else
               (lets
                  ((a at at)
                   (b bt bt)
                   (l over (vm:add l 1))) ; fixme, no bignum len
                  (splice-nums (ncdr ah) (ncdr bh)
                     at bt (ncons a rat) (ncons b rbt) #true l)))))

      (define (kara a b)
         (cond
            ;; O(1) leaf cases
            ((eq? a 0) 0)
            ((eq? b 0) 0)
            ((eq? a 1) b)
            ((eq? b 1) a)

            ;; O(n) or O(1) leaf cases
            ((eq? (type a) type-enum+) (if (eq? (type b) type-enum+) (mult-fixnums a b) (mult-num-big a b 0)))
            ((eq? (type b) type-enum+) (mult-num-big b a 0))
            ((null? (ncdr a))
               (if (null? (ncdr b))
                  (mult-fixnums (ncar a) (ncar b))
                  (mult-num-big (ncar a) b 0)))
            ((null? (ncdr b)) (mult-num-big (ncar b) a 0))

            ;; otherwise divide et imperial troopers
            (else
               (lets
                  ; 3O(n)
                  ((ah at bh bt atl
                     (splice-nums a b a b #null #null #true 0)))
                  (if (less? atl 30)
                     (mul-simple a b)
                     (lets
                         ; 3F(O(n/2)) + 2O(n/2)
                        ((z2 (kara ah bh))
                         (z0 (kara at bt))
                         (z1a
                           (lets ((a (addi ah at)) (b (addi bh bt)))
                              (kara a b)))
                         ; 2O(n)
                         (z1 (subi z1a (addi z2 z0)))
                         ; two more below
                         (x (if (eq? z1 0) z0 (add-ext z0 z1 atl))))
                        (if (eq? z2 0)
                           x
                           (add-ext x z2 (<< atl 1)))))))))

      ;(define mult-big mul-simple)   ; for debugging only!
      (define mult-big kara)

      (define (muli a b)
         (cond
            ; are these actually useful?
            ((eq? a 0) 0)
            ;((eq? a 1) b)
            ((eq? b 0) 0)
            ;((eq? b 1) a)
            (else
               (case (type a)
                  (type-enum+
                     (case (type b)
                        (type-enum+ (mult-fixnums a b))                  ; +a * +b
                        (type-enum- (negative (mult-fixnums a b)))      ; +a * -b
                        (type-int+ (mult-num-big a b 0))               ; +a * +B
                        (type-int- (negative (mult-num-big a b 0)))   ; +a * -b
                        (else (big-bad-args 'mul a b))))
                  (type-enum-
                     (case (type b)
                        (type-enum+ (negative (mult-fixnums a b)))      ; -a * +b -> -c | -C
                        (type-enum- (mult-fixnums a b))                  ; -a * -b -> +c | +C
                        (type-int+ (vm:cast (mult-num-big a b 0) type-int-))   ; -a * +B -> -C
                        (type-int- (mult-num-big a b 0))            ; -a * -B -> +C
                        (else (big-bad-args 'mul a b))))
                  (type-int+
                     (case (type b)
                        (type-enum+ (mult-num-big b a 0))            ; +A * +b -> +C
                        (type-enum- (vm:cast (mult-num-big b a 0) type-int-))    ; +A * -b -> -C
                        (type-int+ (mult-big a b))               ; +A * +B -> +C
                        (type-int- (vm:cast (mult-big a b) type-int-))      ; +A * -B -> -C
                        (else (big-bad-args 'mul a b))))
                  (type-int-
                     (case (type b)
                        (type-enum+ (vm:cast (mult-num-big b a 0) type-int-))      ; -A * +b -> -C
                        (type-enum- (mult-num-big b a 0))               ; -A * -b -> +C
                        (type-int+ (vm:cast (mult-big a b) type-int-))      ; -A * +B -> -C
                        (type-int- (mult-big a b))                  ; -A * -B -> +C
                        (else (big-bad-args 'mul a b))))
                  (type-rational
                     (case (type b)
                        (type-rational  (big-bad-args 'mul a b))         ; handle this before mul for now
                        (else (muli b a))))                  ; otherwise use other branches
                  (else (big-bad-args 'mul a b))))))

      ;;; comparison (rationals need mul)

      ;; todo: rational comparison is dumb.. first one should check the signs, then whether log_2(ab') < log_2(ba'), which is way faster than multiplication, and only as a last resort do the actual multiplication. also, more common comparisons should be inlined here.
      (define (< a b)
         (cond
            ((eq? (type a) type-inexact)
               (fless? a b))
            ((eq? (type b) type-inexact)
               (fless? a b))
            ; add short type paths here later
            ((eq? (type a) type-rational)
               (if (eq? (type b) type-rational)
                  ; a/a' < b/b' <=> ab' < ba'
                  (int< (muli (ncar a) (ncdr b)) (muli (ncar b) (ncdr a)))
                  ; a/a' < b <=> a < ba'
                  (int< (ncar a) (muli b (ncdr a)))))
            ((eq? (type b) type-rational)
               ; a < b/b' <=> ab' < b
               (int< (muli a (ncdr b)) (ncar b)))
            (else
               (int< a b))))

      (define (denominator n)
         (if (eq? (type n) type-rational)
            (ncdr n)  ;; always positive
            1))

      (define (numerator n)
         (if (eq? (type n) type-rational)
            (ncar n)  ;; has the sign if negative
            1))

      (define (<= a b)
         (or (< a b) (= a b)))

      (define (> a b) (< b a))
      (define (>= a b) (<= b a))

      (define (min a b) (if (< a b) a b))
      (define (max a b) (if (< a b) b a))

      (define (minl as) (fold min (car as) (cdr as)))
      (define (maxl as) (fold max (car as) (cdr as)))





      ;;;
      ;;; DIVISION
      ;;;
      ; walk down a and compute each digit of quotient using the top 2 digits of a
      (define (qr-bs-loop a1 as b out)
         (if (null? as)
            (if (null? (ncdr out))
               (begin
                  (values (ncar out) a1))
               (begin
                  (values out a1)))
            (lets
               ((a2 as as)
                (q1 q2 r (vm:div a1 a2 b)))
               (if (eq? q1 0)
                  (qr-bs-loop r as b (ncons q2 out))
                  (qr-bs-loop r as b (ncons q2 (ncons q1 out)))))))

      (define (qr-big-small a b) ; -> q r
         (cond
            ((eq? b 0)
               (big-bad-args 'qr-big-small a b))
            ;((null? (ncdr (ncdr a))) ; (al ah) b -> can use vm:div primop
            ;   (let ((tl (ncdr a)))
            ;      (vm:div (ncar tl) (ncar a) b)))
            (else
               (lets
                  ((ra (nrev a))
                   (a as ra))
                  (qr-bs-loop a as b #null)))))

      ; once upon a time
      ;(define (big-divmod a b)
      ;   (let loop ((a a) (q 0))
      ;      (if (>= a b)
      ;         (loop (- a b) (+ q 1))
      ;         (values q a))))

      ; decrease b
      (define (shift-local-down a b n)
         (cond
            ((eq? n 0) 0)
            ((eq? a b) (subi n 1))
            ((less? b a) n)
            (else
               (lets ((b over (vm:shr b 1)))
                  (shift-local-down a b (subi n 1))))))

      ; increase b
      (define (shift-local-up a b n)
         (cond
            ((eq? a b) (subi n 1))
            ((less? a b) (subi n 1))
            (else
               (lets ((over b (vm:shl b 1)))
                  (if (eq? over 0)
                     (shift-local-up a b (nat-succ n))
                     (subi n 1))))))

      (define (div-shift a b n)
         (if (eq? (type a) type-enum+)
            0
            (let ((na (ncdr a)) (nb (ncdr b)))
               (cond
                  ((null? na)
                     (if (null? nb)
                        (let ((b-lead (ncar b)))
                           (if (eq? b-lead (vm:maxvalue))
                              (if (eq? n 0)
                                 0
                                 (shift-local-down (ncar a) (*pre-max-fixnum*) (subi n 1)))
                              (let ((aa (ncar a)) (bb (addi b-lead 1)))
                                 ; increment b to ensure b'000.. > b....
                                 (cond
                                    ((less? aa bb)
                                       (shift-local-down aa bb n))
                                    (else
                                       (shift-local-up aa bb n))))))
                        ; divisor is larger
                        0))
                  ((null? nb)
                     (div-shift (ncdr a) b (addi n (vm:valuewidth))))
                  (else
                     (div-shift (ncdr a) (ncdr b) n))))))

      (define (nat-quotrem-finish a b out)
         (let ((next (subi a b)))
            (if (negative? next)
               (values out a)
               (nat-quotrem-finish next b (nat-succ out)))))

      (define (nat-quotrem a b)
         (let loop ((a a) (out 0))
            (let ((s (div-shift a b 0)))
               (cond
                  ; hack warning, -1 0 1 are lesser of 2, but not -2
                  ; (tag bits including sign are low)
                  ((less? s 2)
                     (nat-quotrem-finish a b out))
                  (else
                     (let ((this (<< b s)))
                        (loop (subi a this) (addi out (<< 1 s)))))))))

      (define (div-big->negative a b)
         (lets ((q r (nat-quotrem a b)))
            (negate q)))

      ;; fixme: big division is ugly and slow
      (define (div-big-qr a b)
         (lets ((q r (nat-quotrem a b))) q))



      ;;;
      ;;; REMAINDER
      ;;;

      ;; mainly manually partial evaling remainder separately, since a fast one is needed for now for gcd and rational math

      (define (nat-rem-finish a b)
         (let ((ap (subi a b)))
            (if (negative? ap)
               a
               (nat-rem-finish ap b))))

      ;; substract large b*2^n's until a < b
      (define (nat-rem-simple a b)
         (let loop ((a a))
            (let ((s (div-shift a b 0)))
               (cond
                  ; hack warning, -1 0 1 are lesser of 2, but not -2
                  ; (tag bits including sign are low)
                  ((less? s 2)
                     (nat-rem-finish a b))
                  (else
                     (loop (subi a (<< b s))))))))

      ;; reverse number remainder

      (define (rsub a b) ; -> a' borrow|#null
         (cond
            ((null? b) (values a #false)) ; ok if borrowable
            ((null? a) (values a #null)) ; fail
            (else
               (lets
                  ((d (subi (ncar a) (ncar b))) ; fix+ or fix-
                   (tl dr (rsub (ncdr a) (ncdr b))))
                  (cond
                     ((null? dr) (values tl dr)) ; failed below
                     (dr
                        (let ((d (subi d 1))) ; int- (of was -vm:maxvalue), fix- or fix+
                           (if (negative? d)
                              (values (ncons (addi d *first-bignum*) tl) #true) ; borrow
                              (values (ncons d tl) #false))))
                     ((eq? (type d) type-enum-) ; borrow
                        (values (ncons (addi d *first-bignum*) tl) #true))
                     (else
                        (values (ncons d tl) #false)))))))

      (define (drop-zeros n)
         (cond
            ((null? n) n)
            ((eq? 0 (ncar n)) (drop-zeros (ncdr n)))
            (else n)))

      (define (rev-sub a b) ; bignum format a' | #false
         (lets ((val fail? (rsub a b)))
            (if fail?
               #false
               (drop-zeros val))))

      ;; reverse number multiplication by digit

      (define (rmul n d) ; tl x carry-up
         (if (null? n)
            (values #null 0)
            (lets
               ((x tl n)
                (lo hi (vm:mul x d))
                (tl carry (rmul (ncdr n) d))
                (lo over (vm:add lo carry)))
               (if over
                  (lets ((hi over (vm:add hi 1)))
                     (values (ncons lo tl) hi))
                  (values (ncons lo tl) hi)))))

      (define (rmul-digit n d) ; -> bignum
         (cond
            ((eq? d 0) *big-zero*) ; special number
            ((eq? d 1) n)
            (else
               (lets ((tl carry (rmul n d)))
                  (if (eq? carry 0)
                     tl
                     (ncons carry tl))))))

      (define (rrem a b) ; both should be scaled to get a good head for b
         (cond
            ((null? a) a)
            ((null? (ncdr a)) a)
            ((less? (ncar b) (ncar a))
               (lets
                  ((h over (vm:add (ncar b) 1))
                   (_ f r (vm:div 0 (ncar a) h))
                   (bp (rmul-digit b f))
                   (ap (rev-sub a bp)))
                  (if ap (rrem ap b) a)))
            ((rev-sub a b) =>
               (lambda (ap) (rrem ap b)))
            (else
               (lets
                  ((h o (vm:add (ncar b) 1))
                   (f r (qr-big-small (ncons (ncar (ncdr a)) (ncons (ncar a) #null)) h)) ; FIXME, use vm:div instead
                   )
                  (if (eq? (type f) type-enum+)
                     (lets
                        ((bp (rmul-digit b f))
                         (ap (rev-sub a bp))
                         (ap (or ap (rev-sub a (ncons 0 bp)))))
                        (if ap (rrem ap b) a))
                     (lets
                        ((f (cadr f))
                         (bp (rmul-digit b f))
                         ;(ap (rev-sub a bp))
                         (ap #false)
                         (ap (or ap (rev-sub a (ncons 0 bp)))))
                        (if ap (rrem ap b) a)))))))

      (define (nat-rem-reverse a b)
         (if (< a b)
            a
            (lets ((rb (nrev b)))
               (if (less? #b000000111111111111111111 (ncar rb))
                  ; scale them to get a more fitting head for b
                  ; and also get rid of the special case where it is vm:maxvalue
                  (>> (nat-rem-reverse (<< a 12) (<< b 12)) 12)
                  (let ((r (rrem (nrev a) rb)))
                     (cond
                        ((null? r) 0)
                        ((null? (ncdr r)) (ncar r))
                        (else (nrev r))))))))


      (define nat-rem nat-rem-simple)    ; better for same sized numers
      ;(define nat-rem nat-rem-reverse)    ; better when b is smaller ;; FIXME - not yet for variable sized fixnums


      ;;;
      ;;; Exact division
      ;;;

      ;; this algorithm is based on the observation that the lowest digit of
      ;; the quotient in division, when the remainder will be 0, depends only
      ;; on the lowest bits of the divisor and quotient, which allows the
      ;; quotient to be built bottom up using only shifts and substractions.

      ; bottom up exact division, base 2

      (define (div-rev st out)
         (if (null? st) out
            (div-rev (ncdr st) (ncons (ncar st) out))))

      (define (div-finish n)
         (cond
            ((null? (ncdr n)) (ncar n))
            ((eq? (ncar n) 0) (div-finish (ncdr n)))
            (else (div-rev n #null))))

      ; fixme, postpone and merge shifts and substraction

      ; later (sub-shifted a b s) in 1-bit positions
      ; b is usually shorter, so shift b right and then substract instead
      ; of moving a by s

      (define last-bit (subi (vm:valuewidth) 1))

      (define (divex bit bp a b out)
         (cond
            ((eq? (type a) type-enum-) #false) ;; not divisible
            ((eq? (type a) type-int-) #false) ;; not divisible
            ((eq? a 0) (div-finish out))
            ((eq? (band a bit) 0) ; O(1)
               (if (eq? bp last-bit)
                  (lets
                     ((a (ncdr a))
                      (a (if (null? (ncdr a)) (ncar a) a)))
                     (divex 1 0 a b (ncons 0 out)))
                  (lets
                     ((_ bit (vm:shl bit 1))
                      (bp _  (vm:add bp 1)))
                     (divex bit bp a b out))))
            (else ; shift + substract = amortized O(2b) + O(log a)
               (divex bit bp (subi a (<< b bp))
                  b (ncons (vm:ior bit (ncar out)) (ncdr out))))))

      (define divex-start *big-zero*)

      ; FIXME: shifts are O(a+b), switch to bit walking later to get O(1)

      (define (nat-divide-exact a b)
         (if (eq? (band b 1) 0)
            (if (eq? (band a 1) 0)
               ;; drop a powers of two from both and get 1 bit to bottom of b
               (nat-divide-exact (>> a 1) (>> b 1))
               #false) ;; not divisible
            (divex 1 0 a b divex-start)))

      (define (maybe-negate a)
         (if a (negate a) a))

      ; int nat -> int | #false
      (define (divide-exact a b)
         (case (type a)
            (type-enum- (maybe-negate (divide-exact (negate a) b)))
            (type-int- (maybe-negate (divide-exact (negate a) b)))
            (else (nat-divide-exact a b))))

      (define ediv divide-exact)


      ;; the same can be generalized for base B, where 2^16 is convenient given that it is the
      ;; base in which bignums are represented in owl. the lowest digit will have

      ;; fixme, add ^


      ;;; alternative division

      (define (div-big-exact a b) (ediv (subi a (nat-rem a b)) b))

      (define div-big div-big-exact)

      ;;; continue old general division

      (define (div-fixnum->negative a b)
         (lets ((_ q r (vm:div 0 a b)))
            (if (eq? q 0)
               q
               (vm:cast q type-enum-))))

      (define (div-big-num->negative a b)
         (lets ((q r (qr-big-small a b)))
            (case (type q)
               (type-enum+ (vm:cast q type-enum-))
               (else (vm:cast q type-int-)))))

      ; todo, drop this and use just quotrem
      (define (quotient a b)
         (if (eq? b 0)
            (big-bad-args 'div a b)
            (case (type a)
               (type-enum+
                  (case (type b)
                     (type-enum+ (lets ((_ q r (vm:div 0 a b))) q))   ; +a / +b -> +c
                     (type-enum- (div-fixnum->negative a b))                  ; +a / -b -> -c | 0
                     (type-int+ 0)                                             ; +a / +B -> 0
                     (type-int- 0)                                             ; +a / -B -> 0
                     (else (big-bad-args 'div a b))))
               (type-enum-
                  (case (type b)
                     (type-enum+ (div-fixnum->negative a b))                  ; -a / +b -> -c | 0
                     (type-enum- (lets ((_ q r (vm:div 0 a b))) q))             ; -a / -b -> +c
                     (type-int+ 0)                                           ; -a / +B -> 0
                     (type-int- 0)                                             ; -a / -B -> 0
                     (else (big-bad-args 'div a b))))
               (type-int+
                  (case (type b)
                     (type-enum+ (lets ((q r (qr-big-small a b))) q))   ; +A / +b -> +c | +C
                     (type-enum- (div-big-num->negative a b))            ; +A / -b -> -c | -C
                     (type-int+ (div-big a b))                           ; +A / +B -> 0 | +c | +C
                     (type-int- (div-big->negative a (negate b)))      ; +A / -B -> 0 | -c | -C
                     (else (big-bad-args 'div a b))))
               (type-int-
                  (case (type b)
                     (type-enum+ (div-big-num->negative a b))            ; -A / +b -> -c | -C
                     (type-enum- (lets ((q r (qr-big-small a b))) q))    ; -A / -b -> +c | +C
                     (type-int+ (div-big->negative (negate a) b))                     ; -A / +B -> 0 | -c | -C
                     (type-int- (div-big (negate a) (negate b)))                              ; -A / -B -> 0 | +c | +C
                     (else (big-bad-args 'div a b))))
               (else (big-bad-args 'div a b)))))

      (define-syntax fx%
         (syntax-rules ()
            ((fx% a b)
               (lets ((q1 q2 r (vm:div 0 a b))) r))))

      (define (remainder a b)
         (case (type a)
            (type-enum+
               (case (type b)
                  (type-enum+ (fx% a b))
                  (type-enum- (fx% a b))
                  (type-int+ a)
                  (type-int- a)
                  (else (big-bad-args 'remainder a b))))
            (type-enum-
               (case (type b)
                  (type-enum+ (negate (fx% a b)))
                  (type-enum- (negate (fx% a b)))
                  (type-int+ a)
                  (type-int- a)
                  (else (big-bad-args 'remainder a b))))
            (type-int+
               (case (type b)
                  (type-enum+ (values-apply (qr-big-small a b) (lambda (q r) r)))
                  (type-enum- (values-apply (qr-big-small a b) (lambda (q r) r)))
                  (type-int+ (nat-rem a b))
                  (type-int- (nat-rem a (negate b)))
                  (else (big-bad-args 'remainder a b))))
            (type-int-
               (case (type b)
                  (type-enum+
                     (values-apply (qr-big-small a b)
                        (lambda (q r) (negate r))))
                  (type-enum-
                     (values-apply (qr-big-small a b)
                        (lambda (q r) (negate r))))
                  (type-int+ (negate (nat-rem (negate a) b)))
                  (type-int- (negate (nat-rem (negate a) (negate b))))
                  (else (big-bad-args 'remainder a b))))
            (else (big-bad-args 'remainder a b))))

      (define rem remainder)
      (define div quotient)

      ; required when (quotrem a b) -> q,r and b != 0
      ;   a = q*b + r
      ;    |r| < |b|
      ;    -a/b = a/-b = -(a/b)

      ; note: rem has sign of a, mod that of b

      (define (quotrem a b)
         (if (eq? b 0)
            (big-bad-args 'quotrem a b)
            (case (type a)
               (type-enum+
                  (case (type b)
                     (type-enum+ (values-apply (vm:div 0 a b) (lambda (_ q r) (values q r))))
                     (type-int+ (values 0 a))
                     (type-enum- (values-apply (vm:div 0 a b) (lambda (_ q r) (values (negate q) r))))
                     (type-int- (values 0 a))
                     (else (big-bad-args 'quotrem a b))))
               (type-int+
                  (case (type b)
                     (type-enum+ (values-apply (qr-big-small a b) (lambda (q r) (values q r))))
                     (type-int+ (nat-quotrem a b))
                     (type-enum- (values-apply (qr-big-small a b) (lambda (q r) (values (negate q) r))))
                     (type-int- (values-apply (nat-quotrem a (negate b))
                              (lambda (q r) (values (negate q) r))))
                     (else (big-bad-args 'quotrem a b))))
               (type-enum-
                  (case (type b)
                     (type-enum+
                        (values-apply (vm:div 0 a b) (lambda (_ q r) (values (negate q) (negate r)))))
                     (type-enum- (values-apply (vm:div 0 a b) (lambda (_ q r) (values q (negate r)))))
                     (type-int+ (values 0 a))
                     (type-int- (values 0 a))
                     (else (big-bad-args 'quotrem a b))))
               (type-int-
                  (case (type b)
                     (type-enum+
                        (lets ((q r (qr-big-small a b)))
                           (values (negate q) (negate r))))
                     (type-enum- (values-apply (qr-big-small a b) (lambda (q r) (values q (negate r)))))
                     (type-int+ (values-apply (nat-quotrem (negate a) b)
                              (lambda (q r) (values (negate q) (negate r)))))
                     (type-int- (values-apply (nat-quotrem (negate a) (negate b))
                              (lambda (q r) (values q (negate r)))))
                     (else (big-bad-args 'quotrem a b))))
               (else
                  (big-bad-args 'quotrem a b)))))

      ;(print "math.scm: fix quotrem")
      (define divmod quotrem)


      ;;;
      ;;; GCD (lazy binary new)
      ;;;

      ;; Euclid's gcd
      (define (gcd-euclid a b)
         (if (eq? b 0)
            a
            (gcd-euclid b (rem a b))))

      ;; lazy gcd

      (define (pre-m)
         (let* ((value carry (vm:sub (vm:valuewidth) 1)))
            value))

      ; O(1), shift focus bit
      (define (gcd-drop n)
         (let ((s (car n)))
            (cond
               ((eq? s (pre-m))
                  (let ((n (cdr n)))
                     ; drop a digit or zero
                     (if (eq? (type n) type-enum+)
                        (cons 0 0)
                        (let ((tl (ncdr n)))
                           (if (null? (ncdr tl))
                              (cons 0 (ncar tl))
                              (cons 0 tl))))))
               (else
                  (let* ((value carry (vm:add s 1)))
                     (cons value (cdr n)))))))

      (define (lazy-gcd a b n)
         (let ((av (cdr a)) (bv (cdr b))
               (a1 (let* ((c v (vm:shl 1 (car a)))) v))
               (b1 (let* ((c v (vm:shl 1 (car b)))) v)))
            (cond
               ((eq? av 0) (<< bv n))
               ((eq? bv 0) (<< av n))
               ((eq? (band av a1) 0) ; a even
                  (if (eq? (band bv b1) 0) ; a and b even
                     (begin
                        (lazy-gcd (gcd-drop a) (gcd-drop b) (addi n 1)))
                     (begin
                        (lazy-gcd (gcd-drop a) b n))))
               ((eq? (band bv b1) 0) ; a is odd, u is even
                  (lazy-gcd a (gcd-drop b) n))
               (else
                  (lets
                     ((av (>> av (car a)))
                      (bv (>> bv (car b)))
                      (x (subi av bv)))
                     (if (negative? x)
                        (lazy-gcd (cons 1 (negate x)) (cons 0 av) n)
                        (lazy-gcd (cons 1 x) (cons 0 bv) n)))))))

      ;; why are the bit values consed to head of numbers?
      (define (nat-gcd a b) (lazy-gcd (cons 0 a) (cons 0 b) 0)) ;; FIXME - does not yet work with variable fixnum size (?)
      ;(define nat-gcd gcd-euclid)

      ;; signed wrapper for nat-gcd
      (define (gcd a b)
         (cond ; todo: change to case (TODO:)
            ; negates should be inlined
            ((eq? (type a) type-enum-) (gcd (negate a) b))
            ((eq? (type a) type-int-) (gcd (negate a) b))
            ((eq? (type b) type-enum-) (gcd a (negate b)))
            ((eq? (type b) type-int-) (gcd a (negate b)))
            ((eq? (type a) type-enum+) (gcd-euclid a b))
            ((eq? (type b) type-enum+) (gcd-euclid a b))
            ((eq? a b) a)
            (else (nat-gcd a b))))

      (define (gcdl ls) (fold gcd (car ls) (cdr ls)))


      ;;;
      ;;; RATIONALS and COMPLEX (stub)
      ;;;

      (define-syntax complex
         (syntax-rules ()
            ((complex a b) (vm:new type-complex a b))))

      ; normalize, fix sign and construct rational
      (define (rationalize a b)
         (let ((f (gcd a b)))
            (if (eq? f 1)
               (cond
                  ((eq? (type b) type-enum-) (rational (negate a) (negate b)))
                  ((eq? (type b) type-int-) (rational (negate a) (negate b)))
                  (else (rational a b)))
               (rationalize (div a f) (div b f)))))

      ;; if dividing small fixnums, do it with primops
      (define (divide-simple a b)
         (if (eq? (type b) type-enum+) ; negative (if any) always at a
            (cond
               ((eq? (type a) type-enum+)
                  (lets ((_ q r (vm:div 0 a b)))
                     (if (eq? r 0)
                        q
                        #false)))
               (else #false))
            #false))

      ; fixme, to change real soon now

      (define (divide a b)
         (cond
            ((eq? (type b) type-enum-) (divide (negate a) (negate b)))
            ((eq? (type b) type-int-) (divide (negate a) (negate b)))
            ; todo: change next one to (and (eq? (type b) type-enum+) (eq?...)
            ((divide-simple a b) => (lambda (x) x))
            (else
               (let ((f (gcd a b)))
                  (cond
                     ((eq? f 1)
                        (if (eq? b 1)
                           a
                           (rational a b)))
                     ((= f b)
                        (divide-exact a f))
                     (else
                        (rational
                           (divide-exact a f)
                           (divide-exact b f))))))))



      ;;; ===========================================================================================
      ;;;
      ;;; Generic arithmetic routines
      ;;;

      ;; rational case: a/b + c, gcd(a,b) = 1 => gcd(a+bc, b) = 1 -> no need to renormalize
      ;; todo: check and change all possible "add" to "addi"

      (define (add a b)
         (case (type a)
            (type-enum+
               (case (type b)
                  (type-enum+  (add-small->positive a b))
                  (type-int+  (add-number-big a b))
                  (type-enum-  (sub-small->pick-sign a b))
                  (type-int-  (sub-number-big a b #true))
                  (type-rational  (lets ((x z b)) (rational (add (muli a z) x) z)))
                  (type-inexact  (fadd a b))
                  (type-complex  (lets ((x y b)) (complex (add a x) y)))
                  (else (big-bad-args '+ a b))))
            (type-int+
               (case (type b)
                  (type-enum+ (add-number-big b a))
                  (type-int+ (add-big a b #false))
                  (type-enum- (sub-big-number a b #true))
                  (type-int- (sub-big a b))
                  (type-rational  (lets ((x z b)) (rational (add (muli a z) x) z)))
                  (type-inexact  (fadd a b))
                  (type-complex  (lets ((x y b)) (complex (add a x) y)))
                  (else (big-bad-args '+ a b))))
            (type-enum-
               (case (type b)
                  (type-enum+ (sub-small->pick-sign b a))
                  (type-enum- (add-small->negative a b))
                  (type-int+ (sub-big-number b a #true))
                  (type-int- (vm:cast (add-number-big a b) type-int-))
                  (type-rational  (lets ((x z b)) (rational (add (muli a z) x) z)))
                  (type-inexact  (fadd a b))
                  (type-complex  (lets ((x y b)) (complex (add a x) y)))
                  (else (big-bad-args '+ a b))))
            (type-int-
               (case (type b)
                  (type-enum+ (sub-number-big b a #true))
                  (type-enum- (vm:cast (add-number-big b a) type-int-))
                  (type-int+ (sub-big b a))
                  (type-int- (vm:cast (add-big a b #false) type-int-))
                  (type-rational  (lets ((x z b)) (rational (add (muli a z) x) z)))
                  (type-inexact  (fadd a b))
                  (type-complex  (lets ((x y b)) (complex (add a x) y)))
                  (else (big-bad-args '+ a b))))
            (type-rational
               (case (type b)
                  (type-rational
                     ; a'/a" + b'/b" = a'b" + b'a" / a"b"
                     (let ((ad (ncdr a)) (bd (ncdr b)))
                        (if (eq? ad bd)
                           ; a/x + b/x = (a+b)/x, x within fixnum range
                           (divide (add (ncar a) (ncar b)) ad)
                           (let ((an (ncar a)) (bn (ncar b)))
                              (divide
                                 (add (muli an bd) (muli bn ad))
                                 (muli ad bd))))))
                  (type-inexact  (fadd a b))
                  (type-complex
                     (lets ((br bi b))
                        (complex (add a br) bi)))
                  (else
                     ; a'/a" + b = (a'+ba")/a"
                     (rational (add (ncar a) (muli b (ncdr a))) (ncdr a)))))
            (type-inexact
               (fadd a b)) ; casting inexact -> inexact is ok
            (type-complex
               (case (type b)
                  (type-complex
                     ;; A+ai + B+bi = A+B + (a+b)i
                     (let*((ar ai a)
                           (br bi b)
                           (r (add ar br))
                           (i (add ai bi)))
                        (if (eq? i 0) r (complex r i))))
                  (type-inexact
                     (let*((ar ai a))
                        (complex (fadd ar b) ai)))
                  (else
                     ;; A+ai + B = A+B + ai
                     (let*((ar ai a))
                        (complex (add ar b) ai)))))
            (else
               (big-bad-args '+ a b))))

      (define (sub a b)
         (case (type a)
            (type-enum+
               (case (type b)
                  (type-enum+ (sub-small->pick-sign a b))
                  (type-enum- (add-small->positive a b))
                  (type-int+ (sub-number-big a b #true))
                  (type-int- (add-number-big a b))
                  (type-rational  (let ((bl (ncdr b))) (sub (rational (muli a bl) bl) b)))
                  (type-inexact  (fsub a b))
                  (type-complex  (lets ((br bi b)) (complex (sub a br) (negate bi))))
                  (else (big-bad-args '- a b))))
            (type-enum-
               (case (type b)
                  (type-enum+ (add-small->negative a b))
                  (type-enum- (sub-small->pick-sign b a))
                  (type-int+ (vm:cast (add-number-big a b) type-int-))
                  (type-int- (sub-big-number b a #true))
                  (type-rational  (let ((bl (ncdr b))) (sub (rational (muli a bl) bl) b)))
                  (type-inexact  (fsub a b))
                  (type-complex  (lets ((br bi b)) (complex (sub a br) (negate bi))))
                  (else (big-bad-args '- a b))))
            (type-int+
               (case (type b)
                  (type-enum+ (sub-big-number a b #true))
                  (type-enum- (add-number-big b a))
                  (type-int+ (sub-big a b))
                  (type-int- (add-big a b #false))
                  (type-rational  (let ((bl (ncdr b))) (sub (rational (muli a bl) bl) b)))
                  (type-inexact  (fsub a b))
                  (type-complex  (lets ((br bi b)) (complex (sub a br) (negate bi))))
                  (else (big-bad-args '- a b))))
            (type-int-
               (case (type b)
                  (type-enum+ (vm:cast (add-number-big b a) type-int-))
                  (type-enum- (sub-number-big b a #true))
                  (type-int+ (vm:cast (add-big a b #false) type-int-))
                  (type-int- (sub-big b a))
                  (type-rational  (let ((bl (ncdr b))) (sub (rational (muli a bl) bl) b)))
                  (type-inexact  (fsub a b))
                  (type-complex  (lets ((br bi b)) (complex (sub a br) (negate bi))))
                  (else (big-bad-args '- a b))))
            (type-rational
               (case (type b)
                  (type-rational
                     ; a'/a" - b'/b" = a'b" - b'a" / a"b"
                     (let ((ad (ncdr a)) (bd (ncdr b)))
                        (if (eq? ad bd)
                           ; a/x - b/x = (a-b)/x, x within fixnum range
                           (divide (subi (ncar a) (ncar b)) ad)
                           (let ((an (ncar a)) (bn (ncar b)))
                              (divide
                                 (subi (muli an bd) (muli bn ad))
                                 (muli ad bd))))))
                  (type-inexact  (fsub a b))
                  (type-complex
                     (lets ((br bi b)) (complex (sub a br) (negate bi))))
                  (else
                     ; a'/a" - b = (a'-ba")/a"
                     (rational (subi (ncar a) (muli b (ncdr a))) (ncdr a)))))
            (type-inexact
               (fsub a b)) ; casting inexact -> inexact is ok
            (type-complex
               (case (type b)
                  (type-complex
                     (let*((ar ai a)
                           (br bi b)
                           (r (sub ar br))
                           (i (sub ai bi)))
                        (if (eq? i 0) r (complex r i))))
                  (type-inexact
                     (let*((ar ai a))
                        (complex (fsub ar b) ai)))
                  (else
                     (let*((ar ai a))
                        (complex (sub ar b) ai)))))
            (else
               (big-bad-args '- a b))))

      ;; todo: complex construction should be a macro that checks for the nonimaginary part
      ;; todo: no different multiplication for known up to rational etc

      ;; todo: analyze the places for change mul to muli
      ;; removed optimization (mul 0) => 0
      (define (mul a b)
         (if (or (eq? a 0) (eq? b 0))
            0 ; don't remove. required.
         ;else
         (case (type a)
            (type-enum+
               (case (type b)
                  (type-enum+ (mult-fixnums a b))                 ; +a * +b
                  (type-int+ (mult-num-big a b 0))               ; +a * +B
                  (type-enum- (negative (mult-fixnums a b)))      ; +a * -b
                  (type-int- (negative (mult-num-big a b 0)))    ; +a * -B
                  (type-rational  (divide (mul a (ncar b)) (ncdr b)))
                  (type-inexact  (fmul a b))
                  (type-complex
                     (lets ((br bi b) (r (mul a br)) (i (mul a bi)))
                        (if (eq? i 0) r (complex r i))))
                  (else (big-bad-args 'mul a b))))
            (type-enum-
               (case (type b)
                  (type-enum+ (negative (mult-fixnums a b)))      ; -a * +b -> -c | -C
                  (type-int+ (vm:cast (mult-num-big a b 0) type-int-))   ; -a * +B -> -C
                  (type-enum- (mult-fixnums a b))                  ; -a * -b -> +c | +C
                  (type-int- (mult-num-big a b 0))            ; -a * -B -> +C
                  (type-rational  (divide (mul a (ncar b)) (ncdr b)))
                  (type-inexact  (fmul a b))
                  (type-complex
                     (lets ((br bi b) (r (mul a br)) (i (mul a bi)))
                        (if (eq? i 0) r (complex r i))))
                  (else (big-bad-args 'mul a b))))
            (type-int+
               (case (type b)
                  (type-enum+ (mult-num-big b a 0))            ; +A * +b -> +C
                  (type-int+ (mult-big a b))               ; +A * +B -> +C
                  (type-enum- (vm:cast (mult-num-big b a 0) type-int-))    ; +A * -b -> -C
                  (type-int- (vm:cast (mult-big a b) type-int-))      ; +A * -B -> -C
                  (type-rational  (divide (mul a (ncar b)) (ncdr b)))
                  (type-inexact  (fmul a b))
                  (type-complex
                     (lets ((br bi b) (r (mul a br)) (i (mul a bi)))
                        (if (eq? i 0) r (complex r i))))
                  (else (big-bad-args 'mul a b))))
            (type-int-
               (case (type b)
                  (type-enum+ (vm:cast (mult-num-big b a 0) type-int-))      ; -A * +b -> -C
                  (type-int+ (vm:cast (mult-big a b) type-int-))      ; -A * +B -> -C
                  (type-enum- (mult-num-big b a 0))               ; -A * -b -> +C
                  (type-int- (mult-big a b))                  ; -A * -B -> +C
                  (type-rational  (divide (mul a (ncar b)) (ncdr b)))
                  (type-inexact  (fmul a b))
                  (type-complex
                     (lets ((br bi b) (r (mul a br)) (i (mul a bi)))
                        (if (eq? i 0) r (complex r i))))
                  (else (big-bad-args 'mul a b))))
            (type-rational
               (case (type b)
                  (type-rational
                     (divide (mul (ncar a) (ncar b)) (mul (ncdr a) (ncdr b))))
                  (type-inexact  (fmul a b))
                  (type-complex
                     (lets ((br bi b) (r (mul a br)) (i (mul a bi)))
                        (if (eq? i 0) r (complex r i))))
                  (else
                     (divide (mul (ncar a) b) (ncdr a)))))
            (type-inexact
               (fmul a b)) ; casting inexact -> inexact is ok
            (type-complex
               (case (type b)
                  (type-complex
                     (let*((ar ai a)
                           (br bi b)
                           (r (sub (mul ar br) (mul ai bi)))
                           (i (add (mul ai br) (mul ar bi))))
                        (if (eq? i 0) r (complex r i))))
                  (type-inexact
                     (let*((ar ai a))
                        (complex (fmul ar b)
                                 (fmul ai b))))
                  (else
                     (let*((ar ai a)
                           (r (mul ar b))
                           (i (mul ai b)))
                        (if (eq? i 0) r (complex r i))))))
            (else
               (big-bad-args '* a b)))))

      ;; todo: division lacks short circuits
      (define (/ a b)
         (cond
            ; any inexact division always produces inexact number
            ((eq? (type a) type-inexact)
               (fdiv a b))
            ((eq? (type b) type-inexact)
               (fdiv a b))
            ((eq? b 0)
               (cond ; old: (runtime-error "division by zero " (list '/ a b)))
                  ((or (eq? a 0) (eqv? a +nan.0))
                     +nan.0)
                  ((< a 0)
                     -inf.0)
                  (else
                     +inf.0)))
            ((eq? (type a) type-complex)
               (if (eq? (type b) type-complex)
                  (let*((ar ai a)
                        (br bi b)
                        (x (add (mul br br) (mul bi bi)))
                        (r (/ (add (mul ar br) (mul ai bi)) x))
                        (i (/ (sub (mul ai br) (mul ar bi)) x)))
                     (if (eq? i 0) r (complex r i)))
                  (let*((ar ai a)
                        (x (mul b b))
                        (r (/ (mul ar b) x))
                        (i (/ (mul ai b) x)))
                     (if (eq? i 0) r (complex r i)))))
            ((eq? (type b) type-complex)
               (let*((br bi b)
                     (x (add (mul br br) (mul bi bi)))
                     (re (/ (mul a br) x))
                     (im (/ (sub 0 (mul a bi)) x)))
                  (if (eq? im 0) re (complex re im))))
            ((eq? (type a) type-rational)
               (if (eq? (type b) type-rational)
                  ; a'/a" / b'/b" = a'b" / a"b'
                  (divide
                     (mul (ncar a) (ncdr b))
                     (mul (ncdr a) (ncar b)))
                  ; a'/a" / b = a'/ba"
                  (divide (ncar a) (mul (ncdr a) b))))
            ((eq? (type b) type-rational)
               ; a / b'/b" = ab"/n
               (divide (mul a (ncdr b)) (ncar b)))
            (else
               (divide a b))))


      ;;;
      ;;; Basic math extra stuff
      ;;;

      (define (abs n)
         (case (type n)
            (type-enum+ n)
            (type-enum- (vm:cast n type-enum+))
            (type-int+ n)
            (type-int- (ncons (ncar n) (ncdr n)))
            (type-rational (if (negative? n) (sub 0 n) n))
            (else (runtime-error "bad math: " (list 'abs n)))))

      (define (floor n)
         (case (type n)
            (type-rational
               (let* ((a b n))
                  (if (negative? a)
                     (negate (nat-succ (div (abs a) b)))
                     (div a b))))
            (type-inexact
               (ffloor n))
            (else
               n)))

      (define (ceiling n)
         (if (eq? (type n) type-rational)
            (lets ((a b n))
               (if (negative? a)
                  (div a b)
                  (nat-succ (floor n))))
            n))

      (define (truncate n)
         (if (eq? (type n) type-rational)
            (lets ((a b n))
               (if (negative? a)
                  (negate (div (negate a) b))
                  (div a b)))
            n))

      (define (round n)
         (if (eq? (type n) type-rational)
            (lets ((a b n))
               (if (eq? b 2)
                  (if (negative? a)
                     (>> (sub a 1) 1)
                     (>> (nat-succ a) 1))
                  (div a b)))
            n))

      (define (sum l) (fold add (car l) (cdr l)))
      (define (product l) (fold mul (car l) (cdr l)))

      ;;;
      ;;; Alternative names
      ;;;

      (define quot div) ; switch the other way around later
      (define ceil ceiling)
      (define quotient quot)

      ; for all numbers n == (/ (numerator n) (denumerator n))

      (define (numerator n)
         (case (type n)
            (type-rational (ncar n))
            (else n)))

      (define (denumerator n)
         (case (type n)
            (type-rational (ncdr n))
            (else 1)))



      ;;;
      ;;; logarithms, here meaning (ilog n a) = m, being least natural number such that n^m >= a
      ;;;

      ;; naive version, multiply successively until >=
      (define (ilog-loop n a m i)
         (if (< m a)
            (ilog-loop n a (mul m n) (add i 1))
            i))

      ;; least m such that n^m >= a
      (define (ilog-naive n a)
         (ilog-loop n a 1 0))

      ;; same, but double initial steps (could recurse on remaining interval, cache steps etc for further speedup)
      (define (ilogd-loop n a m i)
         (if (< m a)
            (let ((mm (mul m m)))
               (if (< mm a)
                  (ilogd-loop n a mm (add i i))
                  (ilog-loop n a (mul m n) (add i 1))))
            i))

      (define (ilogn n a)
         (cond
            ((>= 1 a) 0)
            ((< a n) 1)
            (else (ilogd-loop n a n 1))))

      ;; special case of ilog2

      ; could do in 8 comparisons with a tree
      (define (ilog2-fixnum n)
         (let loop ((i 0))
            (if (< (<< 1 i) n)
               (loop (add i 1))
               i)))

      (define (ilog2-msd n)
         (let loop ((i 0))
            (if (<= (<< 1 i) n)
               (loop (add i 1))
               i)))

      (define (ilog2-big n digs)
         (let ((tl (ncdr n)))
            (if (null? tl)
               (add (ilog2-msd (ncar n)) (mul digs (vm:valuewidth)))
               (ilog2-big tl (add digs 1)))))

      (define (ilog2 n)
         (cond
            ((eq? (type n) type-int+) (ilog2-big (ncdr n) 1))
            ((eq? (type n) type-enum+)
               (if (< n 0) 1 (ilog2-fixnum n)))
            (else (ilogn 2 n))))

      (define (ilog n a)
         (cond
            ((eq? n 2) (ilog2 a))
            ((<= n 1) (big-bad-args 'ilog n a))
            (else (ilogn n a))))


      ; note: it is safe to use div, which is faster for bignums, because by definition
      ; the product is divisble by the gcd. also, gcd 0 0 is not safe, but since (lcm
      ; a a) == a, handlin this special case and and a small optimization overlap nicely.

      (define (lcm a b)
         (if (eq? a b)
            a
            (div (abs (mul a b)) (gcd a b))))

      (define (modulo a b)
         (if (negative? a)
            (if (negative? b)
               (remainder a b)
               (let ((r (remainder a b)))
                  (if (eq? r 0)
                     r
                     (add b r))))
            (if (negative? b)
               (let ((r (remainder a b)))
                  (if (eq? r 0)
                     r
                     (add b r)))
               (remainder a b))))

      (define mod modulo)


      ;;;
      ;;; Rendering numbers
      ;;;

      (define (char-of digit)
         (add digit (if (< digit 10) 48 87)))

      (define (render-digits num tl base)
         (fold (λ (a b) (cons b a)) tl
            (unfold (λ (n) (lets ((q r (quotrem n base))) (values (char-of r) q))) num zero?)))

      ;; move to math.scm
      (define i-zero (inexact 0)) ; TODO: change to |0.| that is already present

      (define (render-number num tl base)
         (cond
            ((eq? (type num) type-rational)
               (render-number (ref num 1)
                  (cons #\/
                     (render-number (ref num 2) tl base))
                  base))
            ((eq? (type num) type-complex)
               ;; todo: imaginary number rendering looks silly, written in a hurry
               (lets ((real imag num))
                  (render-number real
                     (cond
                        ((eq? imag 1) (ilist #\+ #\i tl))
                        ((eq? imag -1) (ilist #\- #\i tl))
                        ((< imag 0) ;; already has sign
                           (render-number imag (cons #\i tl) base))
                        (else
                           (cons #\+
                              (render-number imag (cons #\i tl) base))))
                     base)))
            ((eq? (type num) type-inexact)
               (cond ; for inf and nan should use equal?, because
                     ;  this numbers can be returned from ffi
                  ((equal? num i-zero) (ilist #\0 #\. #\0 tl))
                  ((equal? num +inf.0) (ilist #\+ #\i #\n #\f #\. #\0 tl))
                  ((equal? num -inf.0) (ilist #\- #\i #\n #\f #\. #\0 tl))
                  ((equal? num +nan.0) (ilist #\+ #\n #\a #\n #\. #\0 tl))
                  (else
                     (let*((- sub) (* mul)
                           (sign num (if (fless? num 0)
                              (values #t (negate (exact num)))
                              (values #f (exact num)))))
                     (cond
                        ((< 1000000000 num)
                           (let ((number (ilist #\B #\I #\G #\. tl)))
                              (if sign (cons #\- number) number)))
                        ((< num 0.00000001)
                           (let ((number (ilist #\. #\0 #\0 #\0 #\0 #\0 #\0 #\0 #\0 #\0 tl)))
                              (if sign (cons #\- number) number)))
                        (else
                           (let*((int (floor num))
                                 (frac (- num int))
                                 (number (reverse
                                    (let loop ((i (* frac 10)) (n (subi 10 (ilog 10 int))) (l #null))
                                       (cond
                                          ((eq? n 1) l)
                                          ((< i 0.00000001) (if (null? l) '(#\0) l))
                                          (else
                                             (loop (* (- i (floor i)) 10) (- n 1) (cons (char-of (floor i)) l)))))))
                                 (number (render-number int (cons #\. (append number tl)) base)))
                              (if sign (cons #\- number) number))))))))
            ((< num 0)
               (cons #\-
                  (render-number (negate num) tl base)))
            ((< num base)
               (cons (char-of num) tl))
            (else
               (render-digits num tl base))))


      ;;;
      ;;; Variable arity versions
      ;;;

      ;; FIXME: these need short circuiting

      ;; + → add
      (define + (case-lambda
         ((a b) (add a b))
         ((a . xs) (fold add a xs))
         (() 0)))

      ;; * → mul
      (define * (case-lambda
         ((a b) (mul a b))
         ((a . xs) (fold mul a xs))
         (() 1)))

      ;; - → sub
      (define - (case-lambda
         ((a) (negate a))
         ((a b) (sub a b))
         ((a . xs)
            (fold sub a xs))))

      (define bin-div /)

      (define /
         (case-lambda
            ((a b) (bin-div a b))
            ((a) (bin-div 1 a))
            ((a . bs) (bin-div a (product bs)))))

      ;; fold but stop on first false
      (define (each op x xs)
         (cond
            ((null? xs) #true)
            ((op x (car xs))
               (each op (car xs) (cdr xs)))
            (else #false)))

      ;; the rest are redefined against the old binary ones

      (define (vararg-predicate op) ;; turn into a macro
         (case-lambda
            ((a b) (op a b))
            ((a . bs) (each op a bs))))

      (define = (vararg-predicate =)) ;; short this later
      (define < (vararg-predicate <))
      (define > (vararg-predicate >))

      (define <= (vararg-predicate <=))
      (define >= (vararg-predicate >=))

      ;; ditto for foldables
      (define (vararg-fold op zero)
         (case-lambda
            ((a b) (op a b))
            ((a) a)
            ((a . bs) (fold op a bs))
            (() (or zero (runtime-error "No arguments for " op)))))

      (define min (vararg-fold min #false))
      (define max (vararg-fold max #false))
      (define gcd (vararg-fold gcd 0))
      (define lcm (vararg-fold lcm 1))

      (define (square x) (* x x))
))
