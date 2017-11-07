;; 2.1
(define (make-rat n d)
  (let ((g (gcd n d)))
    (if (< d 0)
        (cons (* -1 (/ n g)) (* -1 (/ d g)))
        (cons (/ n g) (/ d g)))))

(define (numer x) (car x))
(define (denom x) (cdr x))

(define (print-rat x)
  (newline)
  (display (numer x))
  (display "/")
  (display (denom x)))

;; Testing
(print-rat (make-rat 6 9))
(print-rat (make-rat -6 -9))
(print-rat (make-rat 6 -9))
(print-rat (make-rat -6 9))
