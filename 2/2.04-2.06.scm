;; 2.4
(define (cons x y)
  (lambda (m) (m x y)))

(define (car z)
  (z (lambda (p q) p)))

(define (cdr z)
  (z (lambda (p q) q)))

#|
(cdr (cons x y))
(cdr (lambda (m) (m x y)))
((lambda (m) (m x y)) (lambda (p q) q))
((lambda (p q) q) x y)
y
|#


;; 2.5
(define (cons a b) (* (expt 2 a) (expt 3 b)))

(define (div-count n d)
  (define (iter n count)
    (if (= 0 (remainder n d))
        (iter (/ n d) (+ count 1))
        count))
  (iter n 0))

(define (car x) (div-count x 2))
(define (cdr x) (div-count x 3))

;; Testing
(define x (cons 5 7))
(= 5 (car x))
(= 7 (cdr x))


;; 2.6
(define zero (lambda (f) (lambda (x) x)))
(define (add-1 n)
  (lambda (f) (lambda (x) (f ((n f) x)))))

#| 推导 one
(add-1 zero)
(add-1 (lambda (f) (lambda (x) x)))
(lambda (f) (lambda (x) (f (((lambda (f) (lambda (x) x)) f) x))))
(lambda (f) (lambda (x) (f ((lambda (x) x)) x)))
(lambda (f) (lambda (x) (f x)))
|#
(define one (lambda (f) (lambda (x) (f x))))

#| 推导 two
(add-1 one)
(add-1 (lambda (f) (lambda (x) (f x))))
(lambda (f) (lambda (x) (f (((lambda (f) (lambda (x) (f x))) f) x))))
(lambda (f) (lambda (x) (f ((lambda (x) (f x)) x))))
(lambda (f) (lambda (x) (f (f x))))
|#
(define two (lambda (f) (lambda (x) (f (f x)))))

(define (church-plus a b)
  (lambda (f) (lambda (x) ((a f) ((b f) x)))))

;; Testing
(define (inc x) (+ x 1))

(= 11 ((one inc) 10))
(= 12 ((two inc) 10))
(= 13 (((church-plus one two) inc) 10))
(= 14 (((church-plus two two) inc) 10))
