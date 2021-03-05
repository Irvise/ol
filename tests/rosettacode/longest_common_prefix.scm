; http://www.rosettacode.org/wiki/Longest_common_prefix#Ol

(define (lcp . args)
   (if (null? args)
      ""
      (let loop ((args (map string->list args)) (out #null))
         (if (or (has? args #null)
               (not (apply = (map car args))))
            (list->string (reverse out))
            (loop (map cdr args) (cons (caar args) out))))))

(print "> " (lcp "interspecies" "interstellar" "interstate"))
(print "> " (lcp "throne" "throne"))
(print "> " (lcp "throne" "dungeon"))
(print "> " (lcp "throne" "" "throne"))
(print "> " (lcp "cheese"))
(print "> " (lcp ""))
(print "> " (lcp))
(print "> " (lcp "prefix" "suffix"))
(print "> " (lcp "foo" "foobar"))
