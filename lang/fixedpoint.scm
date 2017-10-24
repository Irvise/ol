
;; todo: vararg lambdas cannot get self as last parameter!

(define-library (lang fixedpoint)

   (export fix-points)

   (import
      (r5rs core)
      (lang ast)
      (owl math)
      (owl list)
      (owl equal)
      (owl list-extra)
      (owl io)
      (lang env))

   (begin

      ; return the least score by pred 
      (define (least pred lst)
         (if (null? lst)
            #false   
            (cdr
               (for (cons (pred (car lst)) (car lst)) (cdr lst)
                  (λ (lead x)
                     (let ((this (pred x)))
                        (if (< this (car lead)) (cons this x) lead)))))))

      (define (free-vars exp env)

         (define (take sym found bound)
            (if (or (has? bound sym) (has? found sym))
               found
               (cons sym found)))

         (define (walk-list exp bound found)
            (fold
               (lambda (found thing)
                  (walk thing bound found))
               found exp))

         (define (walk exp bound found)
            (tuple-case exp
               ((var exp)
                  (take exp found bound))
               ((lambda formals body)
                  (walk body (union formals bound) found))
               ((lambda-var fixed? formals body)
                  (walk body (union formals bound) found))
               ((ifeq a b then else)
                  (walk-list (list a b then else) bound found))
               ((either fn else)
                  (walk fn bound
                     (walk else bound found)))
               ((call rator rands)
                  (walk rator bound
                     (walk-list rands bound found)))
               ((value val) found)
               ((values vals)
                  (walk-list vals bound found))
               ((values-apply op fn)
                  (walk op bound
                     (walk fn bound found)))
               (else
                  (print "free-vars: unknown node type: " exp)
                  found)))

         (walk exp null null))

      (define (lambda? exp env)
         (eq? (ref exp 1) 'lambda))

      (define (set-deps node deps) (set-ref node 3 deps))
      (define (deps-of node) (ref node 3))
      (define (name-of node) (ref node 1))

      ; pick a set of bindings for binding
      (define (pick-binding deps env)

         (define (maybe type vals)
            (if (null? vals) #false  (tuple type vals)))

         (or
            ; things which have no dependences
            (maybe 'trivial
               (keep (lambda (node) (null? (deps-of node))) deps))

            ; things which only depend on themselvs (simply recursive)
            (maybe 'simple
               (keep
                  (lambda (node)
                     (and
                        (lambda? (value-of node) env)
                        (equal? (deps-of node) (list (name-of node)))))
                  deps))

            ; since the dependencies have been inherited, the smallest
            ; set of dependencies is always shared by the things. therefore
            ; they form a partition ready for mutual recursive binding.

            (maybe 'mutual
               ; grab the first lambda node with least number of dependencies
               (let
                  ((node
                     (least
                        (lambda (node) (length (deps-of node)))
                        (keep (lambda (node) (lambda? (value-of node) env)) deps))))
                  (if node
                     (let ((partition (deps-of node)))
                        (keep
                           (lambda (node) (has? partition (name-of node)))
                           deps))
                     null)))
            
            (runtime-error "unable to resolve dependencies for mutual recursion. remaining bindings are " deps)))

      ;;; remove nodes and associated deps
      (define (remove-deps lost deps)
         (map
            (lambda (node)
               (set-deps node
                  (diff (deps-of node) lost)))
            (remove
               (lambda (node)
                  (has? lost (name-of node)))
               deps)))

      (define (make-bindings names values body)
         (mkcall
            (mklambda names body)
            values))

      (define (var-eq? node sym)
         (tuple-case node
            ((var s) (eq? s sym))
            (else #false)))

      ; convert all (name ..) to (name .. name), and make wrappers when name 
      ; is used as a value

      (define (carry-simple-recursion exp name deps)
         (define (walk exp)
            (tuple-case exp
               ((call rator rands)
                  (if (var-eq? rator name)
                     (tuple 'call rator                     ; <- converted call
                        (append (map walk rands) (list rator)))
                     (tuple 'call
                        (walk rator)
                        (map walk rands))))
               ((lambda formals body)
                  (if (has? formals name)
                     exp
                     (tuple 'lambda formals (walk body))))
               ((ifeq a b then else)
                  (tuple 'ifeq (walk a) (walk b) (walk then) (walk else)))
               ((values vals) 
                  (tuple 'values (map walk vals)))
               ((values-apply op fn)
                  (tuple 'values-apply (walk op) (walk fn)))
               ((value val) exp)
               ((var sym)
                  (if (eq? sym name)
                     (begin
                        ;(print " making a wrapper for " name)
                        ;(print "   - with deps " deps)
                        (tuple 'lambda (reverse (cdr (reverse deps))) (tuple 'call exp (map mkvar deps))))
                     exp))
               (else
                  (runtime-error "carry-simple-recursion: what is this node type: " exp))))
         (walk exp))


      (define (carry-bindings exp env)
         (tuple-case exp
            ((call rator rands)  ;;; have to emulate (call (var sym) rands) for now
               (tuple-case rator
                  ((var sym)
                     (tuple-case (lookup env sym)
                        ((recursive formals deps)
                           (if (not (= (length formals) (length rands)))
                              (runtime-error 
                                 "Wrong number of arguments: "
                                 (list 'call exp 'expects formals)))
                           (let ((sub-env (env-bind env formals)))
                              (mkcall rator
                                 (append
                                    (map 
                                       (lambda (arg) (carry-bindings arg sub-env))
                                       rands)
                                    (map mkvar deps)))))
                        (else
                           (mkcall (carry-bindings rator env)
                              (map(lambda (exp) (carry-bindings exp env)) rands)))))
                  (else
                     (mkcall (carry-bindings rator env)
                        (map (lambda (exp) (carry-bindings exp env)) rands)))))
            ((lambda formals body)
               (mklambda formals
                  (carry-bindings body
                     (env-bind env formals))))
            ((ifeq a b then else)
               (let
                  ((a (carry-bindings a env))
                   (b (carry-bindings b env))
                   (then (carry-bindings then env))
                   (else (carry-bindings else env)))
                  (tuple 'ifeq a b then else)))
            ((var sym)
               (tuple-case (lookup env sym)
                  ((recursive formals deps)
                     (let 
                        ((lexp 
                           (mklambda formals 
                              (mkcall exp (map mkvar (append formals deps))))))
                        ; (print "carry-bindings: made local closure " lexp)
                        lexp))
                  (else exp)))
            ((value val) exp)
            ((values vals)
               (tuple 'values
                  (map (lambda (exp) (carry-bindings exp env)) vals)))
            ((values-apply op fn)
               (let
                  ((op (carry-bindings op env))
                   (fn (carry-bindings fn env)))
                  (tuple 'values-apply op fn)))
            (else
               (runtime-error "carry-bindings: strage expression: " exp))))

      ;;; ((name (lambda (formals) body) deps) ...) env 
      ;;; -> ((lambda (formals+deps) body') ...)

      (define (handle-recursion nodes env)
         ; convert the lambda and carry bindings in the body
         (map
            (lambda (node)
               (lets
                  ((lexp (value-of node))
                   (formals (ref lexp 2))
                   (body (ref lexp 3)))
                  (mklambda
                     (append formals (deps-of node))
                     (carry-bindings body env))))
            nodes))

      (define (make-wrapper node)
         (lets
            ((name (name-of node))
             (lexp (value-of node))
             (deps (deps-of node))
             (formals (ref lexp 2))
             (body (ref lexp 3)))
            (mklambda formals
               (mkcall
                  (mkvar name)
                  (map mkvar
                     (append formals deps))))))

      ; bind all things from deps using possibly several nested head lambda calls

      (define (generate-bindings deps body env)
         (define (second x) (ref x 2))
         (define (first x) (ref x 1))
         (if (null? deps)
            body
            (tuple-case (pick-binding deps env)

               ; no dependecies, so bind with ((lambda (a ...) X) A ...)
               ((trivial nodes) 
                  (make-bindings (map first nodes) (map second nodes)
                     (generate-bindings
                        (remove-deps (map first nodes) deps)
                        body env)))

               ; bind one or more functions which are simply recursive
               ((simple nodes)
                  (let
                     ((env-rec
                        (fold
                           (lambda (env node)
                              (let ((formals (ref (value-of node) 2)))
                                 (env-put-raw env  
                                    (name-of node) 
                                    (tuple 'recursive formals 
                                       (list (name-of node))))))
                           env nodes)))
                     ; bind all names to extended functions (think (let ((fakt (lambda (fakt x fakt) ...) ...))))
                     (make-bindings
                        (map first nodes)
                        (handle-recursion nodes env-rec)
                        ; then in the body bind them to (let ((fakt (lambda (x) (fakt x fakt))) ...) ...)
                        (let 
                           ((body
                              (generate-bindings
                                 (remove-deps (map first nodes) deps)
                                 body
                                 (env-bind env (map first nodes)))))
                           ; one option is to bind all to wrapper functions. we'll try another alternative now
                           ; and convert all uses to use the extended functions instead, since they all just 
                           ; require passing the same value as the operator as an arument and thus are quaranteed
                           ; not to grow the closures (unlike mutual recursive functions)
                           ; plan A, (original) make the function look like the original
                           ;(make-bindings
                           ;   (map first nodes)
                           ;   (map make-wrapper nodes)
                           ;   body)
                           ; plan B, convert to direct calls to the wrapper
                           ; remember, the change is just to append the function name to the call 
                           ; and make a (lambda (v ...) (self v .. self)) if it is used as a value
                           (fold
                              (lambda (body node)
                                 (lets ((name val deps node))
                                    (carry-simple-recursion body name 
                                       (append (ref val 2) deps)))) ; add self to args
                              body nodes)
                           ))))

               ((mutual nodes)
                  ;;; variable order must be preserved across functions
                  (lets
                     ((partition (deps-of (car nodes)))
                      (nodes
                        (map
                           (lambda (node)
                              (if (null? (diff (deps-of node) partition))
                                 (set-deps node partition)
                                 (runtime-error 
                                    "mutual recursion bug, partitions differ: " 
                                    (list 'picked partition 'found node))))
                           nodes))
                      (env-rec
                        (fold
                           (lambda (env node)
                              (let ((formals (ref (value-of node) 2)))
                                 (env-put-raw env 
                                    (name-of node) 
                                    (tuple 'recursive formals partition))))
                           env nodes)))
                     (make-bindings
                        (map first nodes)
                        (handle-recursion nodes env-rec)
                        (make-bindings
                           (map first nodes)
                           (map make-wrapper nodes)
                           (generate-bindings
                              (remove-deps (map first nodes) deps)
                              body
                              (env-bind env (map first nodes)))))))

               (else
                  (runtime-error "generate-bindings: cannot bind anything from " deps)))))


      (define (dependency-closure deps)

         (define (third x) (ref x 3))
         (define (grow current deps)
            (lets
               ((related
                  (keep (lambda (x) (has? current (name-of x))) deps))
                (new-deps
                  (fold union current
                     (map third related))))
               (if (= (length current) (length new-deps))
                  current
                  (grow new-deps deps))))

         (map
            (lambda (node)
               (set-deps node
                  (grow (deps-of node) deps)))
            deps))

      ; walk the term and translate all bind's to lambdas
      (define (unletrec exp env)
         (define (unletrec-list exps)
            (map (lambda (exp) (unletrec exp env)) exps))

         (tuple-case exp
            ((var value) exp)
            ((call rator rands)
               (tuple 'call
                  (unletrec rator env)
                  (unletrec-list rands)))
            ((lambda formals body)
               (mklambda formals
                  (unletrec body (env-bind env formals))))
            ((lambda-var fixed? formals body)
               (mkvarlambda formals
                  (unletrec body (env-bind env formals))))
            ((evaluate names values body)
               (let*((env (env-bind env names))
                     (handle (lambda (exp) (unletrec exp env)))
                     (values (map handle values))
                     (body (handle body)))
                  (generate-bindings
                     (dependency-closure (zip
                        (lambda (name value)
                           (tuple name value
                              (intersect names
                                 (free-vars value env))))
                        names values))
                  body env)))

            ((value val) exp)
            ((values vals)
               (tuple 'values
                  (unletrec-list vals)))
            ((values-apply op fn)
               (tuple 'values-apply (unletrec op env) (unletrec fn env)))
            ((ifeq a b then else)
               (let
                  ((a (unletrec a env))
                   (b (unletrec b env))
                   (then (unletrec then env))
                   (else (unletrec else env)))
                  (tuple 'ifeq a b then else)))
            ((either func else)
               (tuple 'either
                  (unletrec func env)
                  (unletrec else env)))
            (else
               (runtime-error "Funny AST node in unletrec: " exp))))

      ;; exp env -> #(ok exp' env)
      (define (fix-points exp env)
         (let ((result (unletrec exp env)))
            (tuple 'ok result env)))

   ))
