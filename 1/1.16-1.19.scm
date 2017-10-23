;; 1.16
(define (fast-expt b n)
  (define (iter a b n)
    (cond ((= n 0) a)
          ((even? n) (iter a (square b) (/ n 2)))
          (else (iter (* a b) b (- n 1)))))
    (iter 1 b n))

;; Testing
(= (fast-expt 2 5) 32)
(= (fast-expt 2 10) 1024)


;; 1.17
(define (double n) (+ n n))
(define (halve n) (/ n 2))

(define (fast-mult a b)
  (cond ((= b 0) 0)
        ((even? b) (fast-mult (double a) (halve b)))
        (else (+ a (fast-mult a (- b 1))))))

;; Testing
(= (fast-mult 10 99) (* 10 99))


;; 1.18
(define (fast-mult2 a b)
  (define (iter n a b)
    (cond ((= b 0) n)
          ((even? b) (iter n (double a) (halve b)))
          (else (iter (+ n a) (double a) (halve (- b 1))))
          )
    )
  (iter 0 a b)
  )

;; Testing
(= (fast-mult2 10 99) (* 10 99))


;; 1.19
#|
Tpq(a, b) = (bq + aq + ap, bp + aq)

Tp'q'(a, b) = Tpq(Tpq(a, b))
            = Tpq(bq + aq + ap, bp + aq)
            = ((bp + aq)q + (bq + aq + ap)q + (bq + aq + ap)p, (bp + aq)p + (bq + aq + ap)q)
            = (bpq + aqq + bqq + aqq + apq + bqp + aqp + app, bpp + aqp + bqq + aqq + apq)
            = (b(pq + qq + qp) + a(qq + pq + qp) + a(qq + pp), b(pp + qq) + a(qp + qq + pq))
            = (b(2pq + qq) + a(2pq + qq) + a(pp + qq), b(pp + qq) + a(2pq + qq))
p' = pp + qq
q' = 2pq + qq
|#
(define (fib n)
  (define(fib-iter a b p q count)
    (cond ((= count 0) b)
          ((even? count)
           (fib-iter
            a
            b
            (+ (square p) (square q))
            (+ (* 2 p q) (square q))
            (/ count 2)))
          (else
           (fib-iter
            (+ (* b q) (* a q) (* a p))
            (+ (* b p) (* a q))
            p
            q
            (- count 1)))))
  (fib-iter 1 0 0 1 n))

;; Testing
(= (fib 10) 55)
