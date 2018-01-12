;; 2.24
#|
  ^
 / \
1   ^
   / \
  2   ^
     / \
    3   4
|#


;; 2.25
(= 7 (cadr (cadr (cdr (list 1 3 (list 5 7) 9)))))
(= 7 (car (car (list (list 7)))))
(= 7 (cadr (cadr (cadr (cadr (cadr (cadr (list 1 (list 2 (list 3 (list 4 (list 5 (list 6 7)))))))))))))


;; 2.26
#|
(append x y) -> (1 2 3 4 5 6)
(cons x y)   -> ((1 2 3) 4 5 6)
(list x y)   -> ((1 2 3) (4 5 6))
|#


;; 2.27
(define (deep-reverse x)
  (if (null? x)
      ()
      (append (deep-reverse (cdr x))
              (list (if (pair? (car x))
                        (deep-reverse (car x))
                        (car x))))))

;; Testing
(define x (list (list 1 2) (list 3 4)))
(equal? (deep-reverse x) (list (list 4 3) (list 2 1)))


;; 2.28
(define (fringe x)
  (if (null? x)
      ()
      (append (if (pair? (car x)) (fringe (car x)) (list (car x)))
              (fringe (cdr x)))))

;; Testing
(define x (list (list 1 2) (list 3 4)))
(equal? (fringe x) (list 1 2 3 4))
(equal? (fringe (list x x)) (list 1 2 3 4 1 2 3 4))


;; 2.29
(define (make-mobile left right) (list left right))
(define (make-branch length structure) (list length structure))
;; a)
(define (left-branch mobile) (car mobile))
(define (right-branch mobile) (cadr mobile))
(define (branch-length branch) (car branch))
(define (branch-structure branch) (cadr branch))
;; b)
(define (branch-weight branch)
  (let ((structure (branch-structure branch)))
    (if (pair? structure) (total-weight structure) structure)))
(define (total-weight mobile)
  (+ (branch-weight (left-branch mobile))
     (branch-weight (right-branch mobile))))
;; c)
(define (branch-torque branch)
  (* (branch-length branch) (branch-weight branch)))

(define (balance? mobile)
  (if (pair? mobile)
      (and (balance? (branch-structure (left-branch mobile)))
           (balance? (branch-structure (right-branch mobile)))
           (= (branch-torque (left-branch mobile))
              (branch-torque (right-branch mobile))))
      true))

;; Testing
(define a (make-mobile (make-branch 4 6) (make-branch 3 8)))
(define b (make-mobile (make-branch 1 2) (make-branch 1 4)))
(define c (make-mobile (make-branch 4 7) (make-branch 2 a)))
(define d (make-mobile (make-branch 4 b) (make-branch 2 c)))
(= 14 (total-weight a))
(= 6 (total-weight b))
(= 21 (total-weight c))
(= 27 (total-weight d))
(balance? a)
(not (balance? b))
(balance? c)
(not (balance? d))

;; d)
(define (make-mobile left right) (cons left right))
(define (make-branch length structure) (cons length structure))
;; 只修改这四个函数就可以了
(define (left-branch mobile) (car mobile))
(define (right-branch mobile) (cdr mobile))
(define (branch-length branch) (car branch))
(define (branch-structure branch) (cdr branch))

;; Testing
(define a (make-mobile (make-branch 4 6) (make-branch 3 8)))
(define b (make-mobile (make-branch 1 2) (make-branch 1 4)))
(define c (make-mobile (make-branch 4 7) (make-branch 2 a)))
(define d (make-mobile (make-branch 4 b) (make-branch 2 c)))
(= 14 (total-weight a))
(= 6 (total-weight b))
(= 21 (total-weight c))
(= 27 (total-weight d))
(balance? a)
(not (balance? b))
(balance? c)
(not (balance? d))


;; 2.30
;; a)
(define (square-tree tree)
  (cond ((null? tree) ())
        ((not (pair? tree)) (square tree))
        (else (cons (square-tree (car tree))
                    (square-tree (cdr tree))))))
;; Testing
(equal? (square-tree (list 1 (list 2 (list 3 4) 5) (list 6 7)))
        '(1 (4 (9 16) 25) (36 49)))

;; b)
(define (square-tree tree)
  (map (lambda (sub-tree)
         (if (pair? sub-tree)
             (square-tree sub-tree)
             (square sub-tree)))
       tree))
;; Testing
(equal? (square-tree (list 1 (list 2 (list 3 4) 5) (list 6 7)))
        '(1 (4 (9 16) 25) (36 49)))


;; 2.31
(define (tree-map proc tree)
  (map (lambda (sub-tree)
         (if (pair? sub-tree)
             (tree-map proc sub-tree)
             (proc sub-tree)))
       tree))

;; Testing
(define (square-tree tree) (tree-map square tree))
(equal? (square-tree (list 1 (list 2 (list 3 4) 5) (list 6 7)))
        '(1 (4 (9 16) 25) (36 49)))


;; 2.32
(define (subsets s)
  (if (null? s)
      (list '())
      (let ((rest (subsets (cdr s))))
        (append rest (map (lambda (x) (cons (car s) x))
                          rest)))))
;; Testing
(equal? (subsets (list 1 2 3))
        '(() (3) (2) (2 3) (1) (1 3) (1 2) (1 2 3)))
