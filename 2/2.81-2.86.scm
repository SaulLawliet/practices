(load "2.77-2.80.scm")

(define coercion-table (make-table))
(define get-coercion (coercion-table 'lookup-proc))
(define put-coercion (coercion-table 'insert-proc!))

(define (scheme-number->complex n)
  (make-complex-from-real-imag (contents n) 0))
(put-coercion 'scheme-number 'complex scheme-number->complex)

(define (apply-generic op . args)
  (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (if proc
          (apply proc (map contents args))
          (if (= (length args) 2)
              (let ((type1 (car type-tags))
                    (type2 (cadr type-tags))
                    (a1 (car args))
                    (a2 (cadr args)))
                (let ((t1->t2 (get-coercion type1 type2))
                      (t2->t1 (get-coercion type2 type1)))
                  (cond (t1->t2
                         (apply-generic op (t1->t2 a1) a2))
                        (t2->t1
                         (apply-generic op a1 (t2->t1 a2)))
                        (else
                         (error "No method for these types"
                                (list op type-tags))))))
              (error "No method for these types"
                     (list op type-tags)))))))

;; 2.81
;; a) apply-generic 会不断调用自己, 最后导致死循环
;; b) Louis 的做法没有效果. apply-generic 不能正确工作
;; c)
(define (apply-generic op . args)
  (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (if proc
          (apply proc (map contents args))
          (if (= (length args) 2)
              (let ((type1 (car type-tags))
                    (type2 (cadr type-tags))
                    (a1 (car args))
                    (a2 (cadr args)))
                ;; Add here
                (if (equal? type1 type2)
                    (error "No method for these types"
                           (list op type-tags))
                    (let ((t1->t2 (get-coercion type1 type2))
                          (t2->t1 (get-coercion type2 type1)))
                      (cond (t1->t2
                             (apply-generic op (t1->t2 a1) a2))
                            (t2->t1
                             (apply-generic op a1 (t2->t1 a2)))
                            (else
                             (error "No method for these types"
                                    (list op type-tags)))))))
              (error "No method for these types"
                     (list op type-tags)))))))

;; Testing
(define (exp x y) (apply-generic 'exp x y))
;; 现在 程序会提示找不到 (exp (scheme-number scheme-number)
(exp (make-scheme-number 2) (make-scheme-number 3))


;; 2.82
(define (apply-generic op . args)
  (define (coercion type)
    (lambda (x)
      (let ((t->t (get-coercion (type-tag x) type)))
        (if t->t (t->t x) x))))

  (let ((type-tags (map type-tag args)))
    (define (apply-coercion types)
      (if (null? types)
          (error "No method for these types" (list op type-tags))
          (let ((coercion-list (map (coercion (car types)) args)))
            (let ((proc (get op (map type-tag coercion-list))))
              (if proc
                  (apply proc (map contents coercion-list))
                  (apply-coercion (cdr types)))))))

    (let ((proc (get op type-tags)))
      (if proc
          (apply proc (map contents args))
          (apply-coercion type-tags)))))

;; Testing
(equal? (make-complex-from-real-imag 3 3)
        (add (make-scheme-number 1) (make-complex-from-real-imag 2 3)))


;; 2.83
#| 以下代码已经加入 2.77-2.80.scm 中的对应位置了

;; install-scheme-number-package
(put 'raise '(scheme-number)
     (lambda (x) (make-rational x 1)))

;; install-rational-package
(put 'raise '(rational)
     (lambda (x) (make-complex-from-real-imag (/ (numer x) (denom x)) 0)))

|#
;; 不能用下行的写法, 在 2.85 会导致死循环
;; (define (raise x) (apply-generic 'raise x))
(define (raise x)
  ((get 'raise (list (type-tag x)))
   (contents x)))

;; Testing
(equal? (make-rational 3 1) (raise (make-scheme-number 3)))
(equal? (make-complex-from-real-imag 3 0) (raise (make-rational 3 1)))


;; 2.84
(define (install-level-package)
  (put 'level 'scheme-number 1)
  (put 'level 'rational 2)
  (put 'level 'complex 4)
  (put 'level 'rectangular 4)
  (put 'level 'polar 4)
  'done)

(install-level-package)

(define (level type) (get 'level type))

(define (apply-generic op . args)
  (define (find-min-level-type types)
    (cond ((null? (cdr types)) (car types))
          ((< (level (car types)) (level (find-min-level-type (cdr types)))) (car types))
          (else (find-min-level-type (cdr types)))))

  (define (raise-arg type)
    (lambda (x)
      (if (equal? (type-tag x) type)
          (raise x)
          x)))

  (let ((type-tags (map type-tag args)))
    (define (apply-raise new-args)
      (let ((new-type-tags (map type-tag new-args)))
        (let ((min-type (find-min-level-type new-type-tags)))
          (if (get 'raise (list min-type))
              (let ((raise-list (map (raise-arg min-type) new-args)))
                (let ((proc (get op (map type-tag raise-list))))
                  (if proc
                      (apply proc (map contents raise-list))
                      (apply-raise raise-list))))
              (error "No method for these types" (list op type-tags))))))

    (let ((proc (get op type-tags)))
      (if proc
          (apply proc (map contents args))
          (apply-raise args)))))

;; Testing
(equal? (make-complex-from-real-imag 3 3)
        (add (make-scheme-number 1) (make-complex-from-real-imag 2 3)))


;; 2.85
#| 以下代码已经加入 2.77-2.80.scm 中的对应位置了

;; install-complex-package
(put 'project '(complex)
     (lambda (x)
       (let ((real (real-part x)))
         (make-rational (inexact->exact (numerator real))
                        (inexact->exact (denominator real))))))

;; install-rational-package
(put 'project '(rational)
     (lambda (x) (make-scheme-number (round (/ (numer x) (denom x))))))

|#

(define (drop x)
  (if (pair? x)
      (let ((project-proc (get 'project (list (type-tag x)))))
        (if project-proc
            (let ((new-x (project-proc (contents x))))
              (let ((raise-proc (get 'raise (list (type-tag new-x)))))
                (if raise-proc
                    (if (equ? x (raise-proc (contents new-x)))
                        (drop new-x)
                        x)
                    x)))
            x))
      x))

(define (apply-generic op . args)
  (define (find-min-level-type types)
    (cond ((null? (cdr types)) (car types))
          ((< (level (car types)) (level (find-min-level-type (cdr types)))) (car types))
          (else (find-min-level-type (cdr types)))))

  (define (raise-arg type)
    (lambda (x)
      (if (equal? (type-tag x) type)
          (raise x)
          x)))

  (let ((type-tags (map type-tag args)))
    (define (apply-raise new-args)
      (let ((new-type-tags (map type-tag new-args)))
        (let ((min-type (find-min-level-type new-type-tags)))
          (if (get 'raise (list min-type))
              (let ((raise-list (map (raise-arg min-type) new-args)))
                (let ((proc (get op (map type-tag raise-list))))
                  (if proc
                      (drop (apply proc (map contents raise-list)))  ;; change this line
                      (apply-raise raise-list))))
              (error "No method for these types" (list op type-tags))))))

    (let ((proc (get op type-tags)))
      (if proc
          (drop (apply proc (map contents args)))  ;; change this line
          (apply-raise args)))))

;; Testing
(equal? (drop (make-complex-from-real-imag 1.5 0)) (make-rational 3 2))
(equal? (drop (make-complex-from-real-imag 1 0)) (make-scheme-number 1))
(equal? (drop (make-complex-from-real-imag 2 3)) (make-complex-from-real-imag 2 3))

(equal? (sub (make-complex-from-real-imag 5 4) (make-complex-from-real-imag 3 4))
        (make-scheme-number 2))

(equal? (add (make-complex-from-real-imag 1.5 0) (make-rational 3 2))
        (make-scheme-number 3))


;; 2.85
#| 以下代码已经加入 2.77-2.80.scm 中的对应位置了

;; install-polar-package
(define (real-part z)
  (mul (magnitude z) (cos (angle z))))
(define (imag-part z)
  (mul (magnitude z) (sin (angle z))))

;; install-scheme-number-package
(put 'square '(scheme-number) square)
(put 'sin '(scheme-number) sin)
(put 'cos '(scheme-number) cos)
(put 'atan '(scheme-number scheme-number) atan)

;; install-rational-package
(lambda (x) (square (/ (numer x) (denom x)))))
(put 'sin '(rational)
     (lambda (x) (sin (/ (numer x) (denom x)))))
(put 'cos '(rational)
     (lambda (x) (cos (/ (numer x) (denom x)))))
(put 'atan '(rational rational)
     (lambda (x y) (atan (/ (numer x) (denom x))
                         (/ (numer y) (denom y)))))
|#
(define (square x) (apply-generic 'square x))
(define (sin x) (apply-generic 'sin x))
(define (cos x) (apply-generic 'cos x))
(define (atan x y) (apply-generic 'atan x y))

;; Testing
;; (define x (make-complex-from-real-imag (make-scheme-number 3) (make-rational 4 1)))
(define (check-from-real-imag x)
  (define r (real-part x))
  (define i (imag-part x))
  (define m (magnitude x))
  (define a (angle x))
  (define y (make-complex-from-mag-ang m a))
  (and (> 0.0000001 (abs (- r (real-part y))))
       (> 0.0000001 (abs (- i (imag-part y))))
       (> 0.0000001 (abs (- m (magnitude y))))
       (> 0.0000001 (abs (- a (angle y))))))

(define (check-from-mag-ang x)
  (define r (real-part x))
  (define i (imag-part x))
  (define m (magnitude x))
  (define a (angle x))
  (define y (make-complex-from-real-imag r i))
  (and (> 0.0000001 (abs (- r (real-part y))))
       (> 0.0000001 (abs (- i (imag-part y))))
       (> 0.0000001 (abs (- m (magnitude y))))
       (> 0.0000001 (abs (- a (angle y))))))

(check-from-real-imag (make-complex-from-real-imag (make-scheme-number 3) (make-rational 4 1)))
(check-from-mag-ang (make-complex-from-mag-ang (make-rational 10 1) (make-rational 0 10)))
