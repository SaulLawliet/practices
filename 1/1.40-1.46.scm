;; 1.40
(define (cubic a b c)
  (lambda (x) (+ (* x x x) (* a x x) (* b x) c)))


;; 1.41
(define (double f)
  (lambda (x) (f (f x))))

(define (inc x) (+ x 1))

;; Testing
(= 21 (((double (double double)) inc) 5))


;; 1.42
(define (compose f g)
  (lambda (x) (f (g x))))

;; Testing
(= 49 ((compose square inc) 6))


;; 1.43
(define (repeated f n)
  (if (< n 2)
      f
      (compose f (repeated f (- n 1)))))

;; Testing
(= (square (square 5)) ((repeated square 2) 5))


;; 1.44
(define dx 0.00001)
(define (smooth f)
  (lambda (x) (/ (+ (f (- x dx))
                    (f x)
                    (f (+ x dx)))
                 3)))

(define (smooth-n-times f n)
  ((repeated smooth n) f))

;; Testing
( = ((smooth (smooth (smooth (smooth sqrt)))) 2)
    ((smooth-n-times sqrt 4) 2))


;; 1.45
;; 最大次数: log2(n)
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

(define (average a b)
  (/ (+ a b) 2))
(define (average-damp f)
  (lambda (x) (average x (f x))))

(define (root-nth x n)
  (fixed-point ((repeated average-damp (/ (log x) (log 2)))
                (lambda (y) (/ x (expt y (- n 1)))))
               1.0))

;; Testing
(root-nth 1024 10)

;; 1.46
(define (iteratie-improve enough? improve)
  (lambda (x)
    (if (enough? x)
        x
        ((iteratie-improve enough? improve) (improve x)))))

;; 改进 1.1.7
(define (sqrt x)
  ((iteratie-improve (lambda (guess) (< (abs (- (square guess) x)) 0.001))
                     (lambda (guess) (average guess (/ x guess))))
   1.0))

(sqrt 9)

;; 改进 1.3.3
(define (fixed-point f first-guess)
  ((iteratie-improve (lambda (x) (< (abs (- x (f x))) tolerance))
                     (lambda (x) (f x)))
   first-guess))

(fixed-point cos 1.0)
