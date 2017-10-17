;; 1.11
;; 递归
(define (f-a n)
  (if (< n 3)
      n
      (+ (f-a (- n 1))
         (* 2 (f-a (- n 2)))
         (* 3 (f-a (- n 3))))))
;; 迭代
(define (f-b n)
  (f-iter 2 1 0 n))

(define (f-iter a b c count)
  (if (= count 0)
      c
      (f-iter (+ a (* 2 b) (* 3 c)) a b (- count 1))))

;; Testing
(= (f-a 5) (f-b 5))
(= (f-a 10) (f-b 10))


;; 1.12
#|
1
1 1
1 2 1
1 3 3 1
1 4 6 4 1
...
|#
(define (pascal row col)
  (cond ((< row col) 0)
        ((or (= col 0) (= col row)) 1)
        (else (+ (pascal (- row 1) (- col 1))
                 (pascal (- row 1) col)))))

;; Testing
(= 1 (pascal 0 0))
(= 6 (pascal 4 2))
(= 252 (pascal 10 5))


;; 1.13
;; 略
