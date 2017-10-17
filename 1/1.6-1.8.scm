;; 1.6
;; 堆栈溢出
;; 因为 mit-scheme 是应用序求值, 则 new-if 中所有的参数都会提前计算
;; 而 new-if 的 else-clause 会递归的调用自己
;; 所以程序会因为堆栈溢出而挂掉


;; 1.7
;; 修改 goods-enough?, 参数传入上一个猜测的值, 初始为0
(define (sqrt-iter guess previous-guess x)
  (if (good-enough? guess previous-guess)
      guess
      (sqrt-iter (sqrt-improve guess x) guess x)))

(define (sqrt-improve guess x)
  (/ (+ (/ x guess)
        guess)
     2))

(define (good-enough? guess previous-guess)
  (< (abs (- guess previous-guess)) 0.001))

(define (sqrt x)
  (sqrt-iter 1.0 0 x))

;; Testing
(< (abs (- (sqrt 2) 1.4142)) 0.001)
(< (abs (- (sqrt 4) 2)) 0.001)


;; 1.8
;; 使主要修改 improve, 这里可以用 1.7 的 good-enough?
(define (curt-iter guess previous-guess x)
  (if (good-enough? guess previous-guess)
      guess
      (curt-iter (curt-improve guess x) guess x)))

(define (curt-improve guess x)
  (/ (+ (/ x (square guess))
        (* 2 guess))
     3))

(define (curt x)
  (curt-iter 1.0 0 x))

;; Testing
(< (abs (- (curt 8) 2)) 0.001)
