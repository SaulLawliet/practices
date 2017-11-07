;; 2.2
(define (make-segment p1 p2) (cons p1 p2))
(define (start-segment s) (car s))
(define (end-segment s) (cdr s))

(define (make-point x y) (cons x y))
(define (x-point p) (car p))
(define (y-point p) (cdr p))

(define (print-point p)
  (newline)
  (display "(")
  (display (x-point p))
  (display ",")
  (display (y-point p))
  (display ")"))

(define (midpoint-segment s)
  (let ((p1 (start-segment s))
        (p2 (end-segment s)))
    (make-point
     (/ (+ (x-point p1) (x-point p2)) 2.0)
     (/ (+ (y-point p1) (y-point p2)) 2.0))))

;; Testing
(print-point (midpoint-segment
              (make-segment (make-point 0 0)
                            (make-point 5 5))))


;; 2.3
;; a) 根据对角线的两点, 创建矩形
(define (make-rect-a a b) (cons a b))
;; b) 根据左下坐标, 长, 高, 创建矩形
(define (make-rect-b p l h)
  (cons p (make-point (+ (x-point p) l) (+ (y-point p) h))))

(define (rect-l r)
  (abs (- (x-point (car r)) (x-point (cdr r)))))
(define (rect-h r)
  (abs (- (y-point (car r)) (y-point (cdr r)))))

(define (rect-perimeter r) (* 2 (+ (rect-l r) (rect-h r))))
(define (rect-area r) (* (rect-l r) (rect-h r)))

;; Testing
(= (rect-perimeter (make-rect-a (make-point 0 0) (make-point 2 3)))
   (rect-perimeter (make-rect-b (make-point 0 0) 2 3)))

(= (rect-area (make-rect-a (make-point 0 0) (make-point 2 3)))
   (rect-area (make-rect-b (make-point 0 0) 2 3)))
