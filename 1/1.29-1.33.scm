;; 1.29
(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
         (sum term (next a) next b))))

(define (simpson-integral f a b n)
  (define h (* 1.0 (/ (- b a) n))) ;; 转化为小数

  (define (inc k) (+ k 1))

  (define (term k)
    (* (f (+ a (* k h)))
       (cond ((or (= k 0) (= k n)) 1)
             ((even? k) 2)
             (else 4))))
  (* (/ h 3)
     (sum term 0 inc n)))

(define (cube x) (* x x x))

;; Testing
;; 结果同样接近 1/4
(simpson-integral cube 0 1 100)
(simpson-integral cube 0 1 1000)


;; 1.30
(define (sum term a next b)
  (define (iter a result)
    (if (> a b)
        result
        (iter (next a) (+ result (term a)))))
  (iter a 0))

;; Testing
(simpson-integral cube 0 1 100)


;; 1.31
;; a) 递归
(define (product term a next b)
  (if (> a b)
      1
      (* (term a)
         (product term (next a) next b))))

(define (pi n)
  (define (inc a) (+ a 1))
  (define (term a)
    (if (even? a)
        (/ (+ a 2) (+ a 1))
        (/ (+ a 1) (+ a 2))))
  (* 4.0 (product term 1 inc n)))

(pi 1000)

;; b) 迭代
(define (product term a next b)
  (define (iter a result)
    (if (> a b)
        result
        (iter (next a) (* result (term a)))))
  (iter a 1))

(pi 1000)

;; 1.31
;; a) 递归
(define (accumulate combiner null-value term a next b)
  (if (> a b)
      null-value
      (combiner (term a)
         (accumulate combiner null-value term (next a) next b))))

(define (sum term a next b)
  (accumulate + 0 term a next b))

(define (product term a next b)
  (accumulate * 1 term a next b))

;; Testing
(simpson-integral cube 0 1 100)
(pi 1000)

;; b) 迭代
(define (accumulate combiner null-value term a next b)
  (define (iter a result)
    (if (> a b)
        result
        (iter (next a) (combiner result (term a)))))
  (iter a null-value))

;; Testing
(simpson-integral cube 0 1 100)
(pi 1000)


;; 1.32
(define (filtered-accumulate filter? combiner null-value term a next b)
  (if (> a b)
      null-value
      (combiner (if (filter? a) (term a) null-value)
                (filtered-accumulate filter? combiner null-value term (next a) next b))))

;; a)
(define (sum-prime a b)
  (define (prime? n)
    (define (smallest-divisor n)
      (find-divisor n 2))
    (define (find-divisor n test-divisor)
      (cond ((> (square test-divisor) n) n)
            ((divides? test-divisor n) test-divisor)
            (else (find-divisor n (+ test-divisor 1)))))
    (define (divides? a b)
      (= (remainder b a) 0))

    (and (> n 1) (= n (smallest-divisor n))))

  (define (identity x) x)
  (define (inc x) (+ x 1))

  (filtered-accumulate prime? + 0 identity a inc b))

;; Testing
(= (+ 2 3 5 7) (sum-prime 1 10))

;; b)
(define (product-relatively-prime n)
  (define (relatively-prime? a)
    (define (gcd a b)
      (if (= b 0) a (gcd b (remainder a b))))
    (= 1 (gcd a n)))

  (define (identity x) x)
  (define (inc x) (+ x 1))

  (filtered-accumulate relatively-prime? * 1 identity 1 inc n))

;; Testing
(= (* 1 3 7 9) (product-relatively-prime 10))











