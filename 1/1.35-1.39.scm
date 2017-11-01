;; 1.35
(define tolerance 0.00001)

(define (fixed-point f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2)) tolerance))
  (define (try guess)
    (let ((next (f guess)))
      (if (close-enough? guess next)
          next
          (try next))))
  (try first-guess))

(fixed-point (lambda (x) (+ 1 (/ 1 x))) 1.0)


;; 1.36
(define (fixed-point f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2)) tolerance))
  (define (try guess)
    (let ((next (f guess)))
      (newline)
      (display next)
      (if (close-enough? guess next)
          next
          (try next))))
  (try first-guess))

(fixed-point (lambda (x) (/ (log 1000) (log x))) 2)


;; 1.37
;; a) 递归, 需要11次(下同)
(define (cont-frac n d k)
  (define (iter i)
    (/ (n i)
       (+ (d i)
          (if (= i k) 0 (iter (+ i 1))))))
  (iter 1))

(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 11)

;; b) 迭代
(define (cont-frac n d k)
  (define (iter i result)
    (if (= i 0)
        result
        (iter (- i 1) (/ (n i) (+ (d i) result)))))
  (iter k 0))

(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 11)


;; 1.38
(define (e k)
  (+ 2 (cont-frac (lambda (x) 1)
                  (lambda (x)
                    (if (= (remainder x 3) 2)
                        (/ (+ x 1) 1.5)
                        1))
                  k)))
(e 100)


;; 1.39
(define (tan-cf x k)
  (cont-frac (lambda (i) (if (= i 1) x (- (square x))))
             (lambda (i) (- (* 2 i) 1.0))
             k))
(tan-cf 45 100)
