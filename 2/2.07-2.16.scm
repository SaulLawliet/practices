;; 2.7
(define (make-interval a b) (cons a b))
(define (upper-bound i) (max (car i) (cdr i)))
(define (lower-bound i) (min (car i) (cdr i)))


;; 2.8
(define (sub-interval x y)
  (make-interval (- (lower-bound x) (upper-bound y))
                 (- (upper-bound x) (lower-bound y))))


;; 2.9
#|
假设 x = [a1, b1], y = [a2, b2]

加法: z = [a1 + a2, b1 + b2]
width(z) = ((b1 + b2) - (a1 + a2)) / 2
         = (b1 + b2 - a1 - a2) / 2
         = (b1 - a1) / 2 + (b2 - a2) / 2
         = width(x) + width(y)

减法: z = [a1 - b2, b1 - a2]
width(z) = ((b1 - a2) - (a1 - b2)) / 2
         = (b1 - a2 - a1 + b2) / 2
         = (b1 - a1) / 2 + (b2 - a2) / 2
         = width(x) + width(y)
|#
(define (add-interval x y)
  (make-interval (+ (lower-bound x) (lower-bound y))
                 (+ (upper-bound x) (upper-bound y))))
(define (mul-interval x y)
  (let ((p1 (* (lower-bound x) (lower-bound y)))
        (p2 (* (lower-bound x) (upper-bound y)))
        (p3 (* (upper-bound x) (lower-bound y)))
        (p4 (* (upper-bound x) (upper-bound y))))
    (make-interval (min p1 p2 p3 p4) (max p1 p2 p3 p4))))
(define (div-interval x y)
  (mul-interval x (make-interval (/ 1.0 (upper-bound y))
                                 (/ 1.0 (lower-bound y)))))

(define (width-interval i)
  (/ (- (upper-bound i) (lower-bound i)) 2))

;; Testing
(define x (make-interval 1 3))
(define y (make-interval 2 5))
(define sum-width (+ (width-interval x) (width-interval y)))

(= sum-width (width-interval (add-interval x y)))
(= sum-width (width-interval (sub-interval x y)))
(not (= sum-width (width-interval (mul-interval x y))))
(not (= sum-width (width-interval (div-interval x y))))


;; 2.10
(define (div-interval x y)
  (if (and (<= (lower-bound y) 0) (>= (upper-bound y) 0))
      (error "division error(zero):" y)
      (mul-interval x (make-interval (/ 1.0 (upper-bound y))
                                     (/ 1.0 (lower-bound y))))))


;; 2.11
(define (mul-interval-new x y)
  (let ((a1 (lower-bound x)) (b1 (upper-bound x))
        (a2 (lower-bound y)) (b2 (upper-bound y)))
    (cond ((and (>= a1 0) (>= b1 0))
           (cond ((and (>= a2 0) (>= b2 0)) (make-interval (* a1 a2) (* b1 b2)))
                 ((and (<= a2 0) (<= b2 0)) (make-interval (* b1 a2) (* a1 b2)))
                 (else (make-interval (* b1 a2) (* b1 b2)))))
          ((and (<= a1 0) (<= b1 0))
           (cond ((and (>= a2 0) (>= b2 0)) (make-interval (* a1 b2) (* b1 a2)))
                 ((and (<= a2 0) (<= b2 0)) (make-interval (* b1 b2) (* a1 a2)))
                 (else (make-interval (* a1 b2) (* a1 a2)))))
          (else
           (cond ((and (>= a2 0) (>= b2 0)) (make-interval (* a1 b2) (* b1 b2)))
                 ((and (<= a2 0) (<= b2 0)) (make-interval (* b1 a2) (* a1 a2)))
                 (else (make-interval (min (* a1 b2) (* b1 a2))
                                      (max (* a1 a2) (* b1 b2)))))))))

;; Testing
(define a (make-interval 1 3))
(define b (make-interval -4 -2))
(define c (make-interval -7 5))

(define (check-mul x y)
  (let ((v1 (mul-interval x y))
        (v2 (mul-interval-new x y)))
    (and (= (lower-bound v1) (lower-bound v2))
         (= (upper-bound v1) (upper-bound v2)))))

(check-mul a a) (check-mul a b) (check-mul a c)
(check-mul b a) (check-mul b b) (check-mul b c)
(check-mul c a) (check-mul c b) (check-mul c c)


;; 2.12
(define (make-center-width c w)
  (make-interval (- c w) (+ c w)))
(define (center i)
  (/ (+ (lower-bound i) (upper-bound i)) 2))
(define (width i)
  (/ (- (upper-bound i) (lower-bound i)) 2))

(define (make-center-percent c p)
  (make-center-width c (* c (/ p 100.0))))

(define (percent i)
  (* (/ (width i) (center i)) 100.0))

;; Testing
(= 15 (percent (make-center-percent 100 15)))


;; 2.13
#|
p = (percent (mul-interval (make-center-percent c1 p1) (make-center-percent c2 p2)))
  = (percent (mul-interval (make-interval (* c1 (- 1 (/ p1 100))) (* c1 (+ 1 (/ p1 100))))
                           (make-interval (* c2 (- 1 (/ p2 100))) (* c2 (+ 1 (/ p2 100))))))
-> 由于全是正数, 所以 [a1, b1] * [a2, b2] = [a1*a2, b1*b2]
  = (percent (make-interval (* (* c1 (- 1 (/ p1 100))) (* c2 (- 1 (/ p2 100))))
                            (* (* c1 (+ 1 (/ p1 100))) (* c2 (+ 1 (/ p2 100))))))
  = (percent (make-interval (* c1 c2 (- 1 (/ p1 100)) (- 1 (/ p2 100)))
                            (* c1 c2 (+ 1 (/ p1 100)) (+ 1 (/ p2 100)))))
-> to Math
  = ((c1 * c2 * (1 + p1/100) * (1 + p2/100)) - (c1 * c2 * (1 - p1/100) * (1 - p2/100))) /
    ((c1 * c2 * (1 + p1/100) * (1 + p2/100)) + (c1 * c2 * (1 - p1/100) * (1 - p2/100))) * 100
  = ((1 + p1/100) * (1 + p2/100) - (1 - p1/100) * (1 - p2/100)) /
    ((1 + p1/100) * (1 + p2/100) + (1 - p1/100) * (1 - p2/100)) * 100
  = ((1 + p1/100 + p2/100 + p1/100 * p2/100) - (1 - p1/100 - p2/100 + p1/100 * p2/100) /
    ((1 + p1/100 + p2/100 + p1/100 * p2/100) + (1 - p1/100 - p2/100 + p1/100 * p2/100) * 100
  = (2 * p1/100 + 2 * p2/100) / (2 + 2 * p1/100 * p2/100) * 100
  = (p1/100 + p2/100) / (1 + p1/100 * p2/100) * 100
  = (p1 + p2) / (1 + p1/100 * p2/100)
-> 当 p1 p2 足够小的时候, p1/100 * p2/100 约等于 0
  = (p1 + p2) / (1 + 0)
  = p1 + p2
|#


;; 2.14-2.16 略
