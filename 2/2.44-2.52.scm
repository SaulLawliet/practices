;; You need RACKET(http://racket-lang.org) to run.
#lang racket
(require (planet "sicp.ss" ("soegaard" "sicp.plt" 2 1)))

;; 2.44
(define (up-split painter n)
  (if (= n 0)
      painter
      (let ((smaller (up-split painter (- n 1))))
        (below painter (beside smaller smaller)))))

;; Testing
(paint (up-split einstein 3))


;; 2.45
(define (split step1 step2)
  (lambda (painter n)
    (if (= n 0)
        painter
        (let ((smaller ((split step1 step2) painter (- n 1))))
          (step1 painter (step2 smaller smaller))))))
(define new-right-split (split beside below))
(define new-up-split (split below beside))

;; Testing 
(paint (new-right-split einstein 3))
(paint (new-up-split einstein 3))


;; 2.46
(define (make-vect x y) (cons x y))
(define (xcor-vect v) (car v))
(define (ycor-vect v) (cdr v))
(define (add-vect v1 v2)
  (make-vect (+ (xcor-vect v1) (xcor-vect v2))
             (+ (ycor-vect v1) (ycor-vect v2))))
(define (sub-vect v1 v2)
  (make-vect (- (xcor-vect v1) (xcor-vect v2))
             (- (ycor-vect v1) (ycor-vect v2))))
(define (scale-vect s v)
  (make-vect (* s (xcor-vect v)) (* s (ycor-vect v))))

;; Testing
;; (4 6)
(add-vect (make-vect 1 2) (make-vect 3 4))
;; (-2 -2)
(sub-vect (make-vect 1 2) (make-vect 3 4))
;; (3 6)
(scale-vect 3 (make-vect 1 2))


;; 4.47
(define (make-frame origin edge1 edge2)
  (list origin edge1 edge2))
(define (origin-frame f) (car f))
(define (edge1-frame f) (cadr f))
(define (edge2-frame f) (caddr f))

(define (make-frame-2 origin edge1 edge2)
  (cons origin (cons edge1 edge2)))
(define (origin-frame-2 f) (car f))
(define (edge1-frame-2 f) (cadr f))
(define (edge2-frame-2 f) (cddr f))

;; Testing
(define f1 (make-frame (make-vect 0 0) (make-vect 1 2) (make-vect 3 4)))
(origin-frame f1)
(edge1-frame f1)
(edge2-frame f1)

(define f2 (make-frame-2 (make-vect 0 0) (make-vect 1 2) (make-vect 3 4)))
(origin-frame-2 f2)
(edge1-frame-2 f2)
(edge2-frame-2 f2)


;; 2.48
(define (make-segment v1 v2) (cons v1 v2))
(define (start-segment segment) (car segment))
(define (end-segment segment) (cdr segment))

;; Testing
(define s (make-segment (make-vect 1 2) (make-vect 3 4)))
(start-segment s)
(end-segment s)


;; 2.49
(define (origin2-frame frame)
  (sub-vect (add-vect (edge1-frame frame) (edge2-frame frame))
            (origin-frame frame)))

(define (segments-a frame)
  (let ((origin2 (origin2-frame frame)))
    (list (make-segment (origin-frame frame) (edge1-frame frame))
          (make-segment (origin-frame frame) (edge2-frame frame))
          (make-segment origin2 (edge1-frame frame))
          (make-segment origin2 (edge2-frame frame)))))

(define (segments-b frame)
  (list (make-segment (origin-frame frame) (origin2-frame frame))
        (make-segment (edge1-frame frame) (edge2-frame frame))))

(define (segments-c frame)
  (define (mid v1 v2)
    (scale-vect 1/2 (add-vect v1 v2)))
  (segments-a (make-frame
               (mid (origin-frame frame) (edge1-frame frame))
               (mid (origin-frame frame) (edge2-frame frame))
               (mid (origin2-frame frame) (edge1-frame frame)))))

;; d) 略

;; Testing
(define f (make-frame (make-vect 0.5 0.0) (make-vect 0.0 0.5) (make-vect 1.0 0.5)))
(paint (segments->painter (append (segments-a f)
                                  (segments-b f)
                                  (segments-c f))))


;; 2.50
(define (flip-horiz painter)
  ((transform-painter (make-vect 1.0 0.0)
                      (make-vect 0.0 0.0)
                      (make-vect 1.0 1.0))
   painter))

(define (rotate-180 painter)
  ((transform-painter (make-vect 1.0 1.0)
                      (make-vect 0.0 1.0)
                      (make-vect 1.0 0.0))
   painter))

(define (rotate-270 painter)
  ((transform-painter (make-vect 0.0 1.0)
                      (make-vect 0.0 0.0)
                      (make-vect 1.0 1.0))
   painter))

;; Testing
(paint einstein)
(paint (flip-horiz einstein))
(paint (rotate-180 einstein))
(paint (rotate-270 einstein))


;; 2.51
(define (my-below-1 painter1 painter2)
  (let ((split-point (make-vect 0.0 0.5)))
    (let ((paint-bottom
           ((transform-painter (make-vect 0.0 0.0)
                               (make-vect 1.0 0.0)
                               split-point
                               )
           painter1))
          (paint-top
           ((transform-painter split-point
                               (make-vect 1.0 0.5)
                               (make-vect 0.0 1.0))
           painter2)))
      (lambda (frame)
        (paint-bottom frame)
        (paint-top frame)))))

(define (my-below-2 painter1 painter2)
  (define (rotate-90 painter)
    ((transform-painter (make-vect 1.0 0.0)
                        (make-vect 1.0 1.0)
                        (make-vect 0.0 0.0))
    painter))
  (rotate-270 (beside (rotate-90 painter1) (rotate-90 painter2))))

;; Testing
(paint (my-below-1 einstein einstein))
(paint (my-below-2 einstein einstein))


;; 2.52
;; a) 略
;; b)
(define (corner-split painter n)
  (if (= n 0)
      painter
      (beside (below painter (new-up-split painter (- n 1)))
              (below (new-right-split painter (- n 1)) (corner-split painter (- n 1))))))
;; c)
(define (square-limit painter n)
  (let ((tr (corner-split painter (- n 1))))
    (let ((left (below (rotate-180 (flip-horiz tr)) tr)))
      (beside (flip-horiz left) left))))

;; Testing
(paint (corner-split einstein 3))
(paint (square-limit einstein 3))
