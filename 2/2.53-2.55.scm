;; 2.53
#|
(list 'a 'b 'c)                         ->  (a b c)
(list (list 'georage))                  -> ((georage))
(cdr '((x1 x2) (y1 y2)))                -> ((y1 y2))
(cadr '((x1 x2) (y1 y2)))               -> (y1 y2)
(pair? (car '(a short list)))           -> #f
(memq 'red '((red shoes) (blue socks))) -> #f
(memq 'red '(red shoes blue socks))     -> (red shoes blue socks)
|#


;; 2.54
(define (equal? a b)
  (cond ((and (pair? a) (pair? b))
         (and (equal? (car a) (car b)) (equal? (cdr a) (cdr b))))
        ((and (not (pair? a)) (not (pair? b)))
         (eq? a b))
        (else false)))

;; Testing
(equal? '(this is a list) '(this is a list))
(not (equal? '(this is a list) '(this (is a) list)))


;; 2.55
(car ''abracadabra)
(car (quote (quote abracadabra)))
;; 所以结果是 quota
