;; 1.9
#| 过程1: 递归
(+ 4 5)
(inc (+ (dec 4) 5))
(inc (+ 3 5))
(inc (inc (+ (dec 3) 5)))
(inc (inc (+ 2 5)))
(inc (inc (inc (+ (dec 2) 5))))
(inc (inc (inc (+ 1 5))))
(inc (inc (inc (inc (+ (dec 1) 5)))))
(inc (inc (inc (inc (+ 0 5)))))
(inc (inc (inc (inc 5))))
(inc (inc (inc 6)))
(inc (inc 7))
(inc 8)
(9)
|#

#| 过程2: 迭代
(+ 4 5)
(+ (dec 4) (inc 5))
(+ 3 6)
(+ (dec 3) (inc 6))
(+ 2 7)
(+ (dec 2) (inc 7))
(+ 1 8)
(+ (dec 1) (inc 8))
(+ 0 9)
9
|#


;; 1.10
#|
(A 1 10) -> 1024
(A 2 4)  -> 65536
(A 3 3)  -> 65536

(define (f n) (A 0 n))
-> 2n

(define (g n) (A 1 n))
-> 当 n=0 时: 0
   当 n>0 时: 2^n

(define (h n) (A 2 n))
-> 当 n=0 时: 0
   当 n>0 时: 2^(h(n-1))
#|
