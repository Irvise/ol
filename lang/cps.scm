; http://en.wikipedia.org/wiki/Continuation-passing_style
; http://c2.com/cgi/wiki?ContinuationPassingStyle
; http://matt.might.net/articles/by-example-continuation-passing-style/
(define-library (lang cps)

   (export cps)

   (import
      (r5rs core)
      (lang ast)
      (owl list)
      (owl list-extra)
      (owl math)
      (lang gensym)
      (owl io)
      (lang primop))

   (begin
      ;; fixme: information about cps-special primops could be stored elsewhere

      (define (ok exp env) (tuple 'ok exp env))
      (define (fail reason) (tuple 'fail reason))

      (define (fresh free)
         (values free (gensym free)))

      (define (cps-literal exp env cont free)
         (values
            (mkcall cont (list exp))
            free))

      (define (cps-just-lambda cps formals fixed? body env free)
         (lets
            ((cont-sym free (fresh free))
             (body free (cps body env (mkvar cont-sym) free)))
            (values
               (if fixed?  ;; <- fixme, merge with node having fixedness later
                  (mklambda (cons cont-sym formals) body)
                  (mkvarlambda (cons cont-sym formals) body))
               free)))

      (define (cps-lambda cps formals fixed? body env cont free)
         (lets ((lexp free (cps-just-lambda cps formals fixed? body env free)))
            (values (mkcall cont (list lexp)) free)))

      (define (cps-args cps args call env free)
         (if (null? args)
            (lets
               ((call (reverse call))
                (rator (car call))
                (rands (cdr call)))
               (values (mkcall rator rands) free))
            (tuple-case (car args)
               ((lambda formals body)
                  (lets ((lexp free (cps-just-lambda cps formals #true body env free)))
                     (cps-args cps (cdr args) (cons lexp call) env free)))
               ((lambda-var fixed? formals body)
                  (lets ((lexp free (cps-just-lambda cps formals fixed? body env free)))
                     (cps-args cps (cdr args) (cons lexp call) env free)))
               ((value foo)
                  (cps-args cps (cdr args) (cons (car args) call) env free))
               ((var foo)
                  (cps-args cps (cdr args) (cons (car args) call) env free))
               (else
                  (lets
                     ((this free (fresh free))
                      (rest free 
                        (cps-args cps (cons (mkvar this) (cdr args)) call env free)))
                     (cps (car args)
                        env
                        (mklambda (list this) rest)
                        free))))))

      (define (cps-values cps vals env cont free)
         (cps-args cps vals (list cont) env free))

      ;; fixme: check - assuming tuple exp is already cps'd
      (define (cps-bind cps rator rands env cont free)
         (if (= (length rands) 2)
            (tuple-case (cadr rands)
               ((lambda formals body)
                  (lets ((body free (cps body env cont free)))
                     (cps-args cps (list (car rands))
                        (list (mklambda formals body) rator)
                        env free)))
               (else
                  (runtime-error "bad arguments for tuple bind: " rands)))
            (runtime-error "bad arguments for tuple bind: " rands)))


      ;; (a0 .. an) → (cons a0 (cons .. (cons an null))), modulo AST
      (define (enlist-tail args)
         (foldr
            (λ (x tl) 
               (mkcall (tuple 'value cons) (list x tl)))
            (tuple 'value null)
            args))

      ;; (f0 .. fn) (a0 ... am) → #false | (a0 ... an-1 (cons an (cons ... (cons am null))))
      (define (enlist-improper-args formals args)
         (cond
            ((null? (cdr formals)) 
               (list (enlist-tail args)))
            ((null? args) #false) ;; too few args
            ((enlist-improper-args (cdr formals) (cdr args)) =>
               (λ (tail) (cons (car args) tail)))
            (else #false)))

      (define (cps-call cps rator rands env cont free)
         (tuple-case rator
            ((lambda formals body)
               (lets
                  ((body free (cps body env cont free)))
                  (if (null? formals)
                     ;;; drop lambdas from ((lambda () X))
                     (values body free)
                     (cps-args cps rands
                        (list (mklambda formals body))
                        env free))))
            ((lambda-var fixed? formals body)
               (cond
                  (fixed? ;; downgrade to a regular lambda
                     (cps-call cps
                        (tuple 'lambda formals body)
                        rands env cont free))
                  ((enlist-improper-args formals rands) => ;; downgrade to a regular lambda converting arguments
                     (λ (rands)
                        (cps-call cps 
                           (tuple 'lambda formals body)
                           rands env cont free)))
                  (else
                     (runtime-error "Bad head lambda arguments:" (list 'args formals 'rands rands)))))
            ((call rator2 rands2)
               (lets
                  ((this free (fresh free))
                   (call-exp free 
                     (cps-args cps rands (list cont (mkvar this)) env free)))
                  (cps rator env
                     (mklambda (list this) call-exp)
                     free)))
            ((ifeq a b then else)
               (lets ((this free (fresh free)))
                  (cps
                     (mkcall (mklambda (list this) (mkcall (mkvar this) rands))
                        (list rator))
                     env cont free)))
            ((value val)
               (let ((pop (primop-of val)))
                  (if (special-bind-primop? pop)
                     (cps-bind cps rator rands env cont free)
                     (cps-args cps rands (list cont rator) env free))))
            (else
               (cps-args cps rands (list cont rator) env free))))

      (define (cps-ifeq cps a b then else env cont free)
         (cond
            ((not (var? cont))
               (lets
                  ((this free (fresh free))
                   (exp free
                     (cps-ifeq cps a b then else env (mkvar this) free)))
                  (values
                     (mkcall
                        (mklambda (list this) exp)
                        (list cont))
                     free)))
            ((call? a)
               (lets
                  ((this free (fresh free))
                   (rest free
                     (cps-ifeq cps (mkvar this) b then else env cont free)))
                  (cps a env (mklambda (list this) rest) free)))
            ((call? b)
               (lets
                  ((this free (fresh free))
                   (rest free 
                     (cps-ifeq cps a (mkvar this) then else env cont free)))
                  (cps b env (mklambda (list this) rest) free)))
            (else
               (lets
                  ((then free (cps then env cont free))
                   (else free (cps else env cont free)))
                  (values
                     (tuple 'ifeq a b then else)
                     free)))))

      (define (cps-values-apply cps exp semi-cont env cont free)
         (tuple-case semi-cont
            ((lambda formals body)
               (lets ((body-cps free (cps body env cont free)))
                  (cps exp env 
                     (mklambda formals body-cps)
                     free)))
            ;; FIXME: this ends up as operator, but doesn't go through the call operator variable lambda conversion and thus confuses rtl-* which assume all operator lambdas are already taken care of by CPS
            ((lambda-var fixed? formals  body)
               (lets ((body-cps free (cps body env cont free)))
                  (cps exp env 
                     (tuple 'lambda-var fixed? formals body-cps)
                     free)))
            (else
               (runtime-error "values-apply: receiver is not a lambda. " semi-cont))))

      ;; translate a chain of lambdas as if they were at operator position
      ;; note! also cars are handled as the same jump, which is silly
      (define (cps-either cps node env cont free)
         (tuple-case node
            ((either fn else)
               (lets 
                  ((fn free (cps-either cps fn env cont free))
                   (else free (cps-either cps else env cont free)))
                  (values (tuple 'either fn else) free)))
            ((lambda formals body)
               (cps-just-lambda cps formals #true body env free))
            ((lambda-var fixed? formals body)
               (cps-just-lambda cps formals fixed? body env free))
            (else
               (runtime-error "either: " (list node "argument should be function")))))

      (define (cps-exp exp env cont free)
         (tuple-case exp
            ((value val)
               (cps-literal exp env cont free))
            ((var sym)
               (cps-literal exp env cont free))
            ((lambda formals body)
               (cps-lambda cps-exp formals #true body env cont free))
            ((lambda-var fixed? formals body)
               (cps-lambda cps-exp formals fixed? body env cont free))
            ((call rator rands)
               (cps-call cps-exp rator rands env cont free))
            ((values vals)
              (cps-values cps-exp vals env cont free))
            ((values-apply exp target)
              (cps-values-apply cps-exp exp target env cont free))
            ((ifeq a b then else)
               (cps-ifeq cps-exp a b then else env cont free))
            ((either fn else)
               (lets ((res free (cps-either cps-exp exp env cont free)))
                  (values (mkcall cont (list res)) free)))
            (else
               (runtime-error "CPS does not do " exp))))

      (define (val-eq? node val)
         (tuple-case node
            ((value this)
               (eq? this val))
            (else #false)))

      ; pass fail to cps later and exit via it on errors
      (define (cps exp env) ; continuation-passing style
         (or
            (call/cc
               (lambda (fail)
                  (let ((cont-sym (gensym exp)))	
                     ; a hack to be able to define code sans cps 	
                     ; a better solution would be ability to change the	
                     ; compiler chain interactively
                     (if (and 			
                           (call? exp) 
                           (val-eq? (ref exp 2) '_sans_cps)	
                           (= (length (ref exp 3)) 1))
                        (ok
                           (mklambda (list cont-sym) 
                              (mkcall (mkvar cont-sym)
                                 (list (car (ref exp 3)))))
                           env)
                        (lets ((exp free (cps-exp exp env (mkvar cont-sym) (gensym cont-sym))))
                           (ok
                              (mklambda (list cont-sym) exp)
                              env))))))
            (fail "cps failed")))
))
