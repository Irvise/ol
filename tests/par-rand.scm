(import (owl random))

;; check that threads which return a given value after n context switches return them
;; when computed via par in the same order as if the values were sorted by n.

(define (step-down r n)
   (if (eq? n 0)
      r
      (begin
         (sleep 0) ;; force thread switch
         (step-down r (- n 1)))))

(define (stepper r n) 
   (λ () (step-down r n)))

(define seed (time-ms))

(define rs (seed->rands seed))

(define-values (rs n) (rand-range rs 10 100))

(define-values (rs nums)  (random-numbers rs 1000 n))

(define-values (rs steps) (random-permutation rs (lrange 0 1 n)))

(define step-order (map car (sort (λ (a b) (< (cdr a) (cdr b))) (map cons nums steps))))

(define par-order (force-ll (par* (map stepper nums steps))))

(if (equal? step-order par-order)
   (print "good")
   (print "failed with seed " seed))

