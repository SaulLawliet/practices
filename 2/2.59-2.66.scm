;; 2.59
(define (element-of-set? x set)
  (cond ((null? set) false)
        ((equal? x (car set)) true)
        (else (element-of-set? x (cdr set)))))

(define (adjoin-set x set)
  (if (element-of-set? x set)
      set
      (cons x set)))

(define (intersection-set set1 set2)
  (cond ((or (null? set1) (null? set2))
         '())
        ((element-of-set? (car set1) set2)
         (cons (car set1) (intersection-set (cdr set1) set2)))
        (else
         (intersection-set (cdr set1) set2))))

(define (union-set set1 set2)
  (if (null? set2)
      set1
      (union-set (adjoin-set (car set2) set1) (cdr set2))))

;; Testing
(union-set (list 1 2 3) (list 0 3 4))


;; 2.60
(define (adjoin-set x set) (cons x set))
(define (union-set set1 set2) (append set1 set2))

;; Testing
(adjoin-set 2 (list 2 3 2 1 3 2 2))
(union-set (list 1 1 1) (list 1 2 3))
(intersection-set (list 1 1 1) (list 1 2 3))
(intersection-set (list 1 2 3) (list 1 1 1))


;; 2.61
(define (adjoin-set x set)
  (cond ((null? set) (list x))
        ((= x (car set)) set)
        ((< x (car set)) (cons x set))
        (else (cons (car set) (adjoin-set x (cdr set))))))

;; Testing
(adjoin-set 0 (list 1 2 4))
(adjoin-set 2 (list 1 2 4))
(adjoin-set 3 (list 1 2 4))
(adjoin-set 5 (list 1 2 4))


;; 2.62
(define (intersection-set set1 set2)
  (if (or (null? set1) (null? set2))
      '()
      (let ((x1 (car set1)) (x2 (car set2)))
        (cond ((= x1 x2)
               (cons x1
                     (intersection-set (cdr set1)
                                       (cdr set2))))
              ((< x1 x2)
               (intersection-set (cdr set1) set2))
              ((< x2 x1)
               (intersection-set set1 (cdr set2)))))))

(define (union-set set1 set2)
  (cond ((null? set1) set2)
        ((null? set2) set1)
        (else (let ((x1 (car set1)) (x2 (car set2)))
                (cond ((= x1 x2)
                       (cons x1 (union-set (cdr set1) (cdr set2))))
                      ((< x1 x2)
                       (cons x1 (union-set (cdr set1) set2)))
                      ((< x2 x1)
                       (cons x2 (union-set set1 (cdr set2)))))))))

;; Testing
(union-set (list 1 3 5 7) (list 2 4 6 7))


;; 2.63
(define (make-tree entry left right) (list entry left right))
(define (entry tree) (car tree))
(define (left-branch tree) (cadr tree))
(define (right-branch tree) (caddr tree))

(define tree1 '(7 (3 (1 () ()) (5 () ())) (9 () (11 () ()))))
(define tree2 '(3 (1 () ()) (7 (5 () ()) (9 () (11 () ())))))
(define tree3 '(5 (3 (1 () ()) ()) (9 (7 () ()) (11 () ()))))

(define (tree->list-1 tree)
  (if (null? tree)
      '()
      (append (tree->list-1 (left-branch tree))
              (cons (entry tree) (tree->list-1 (right-branch tree))))))

(define (tree->list-2 tree)
  (define (copy-to-list tree result-list)
    (if (null? tree)
        result-list
        (copy-to-list (left-branch tree)
                      (cons (entry tree)
                            (copy-to-list (right-branch tree) result-list)))))
  (copy-to-list tree '()))

;; a) Testing 相同的结果, 都是(1 3 5 7 9 11)
(tree->list-1 tree1)
(tree->list-2 tree1)
(tree->list-1 tree2)
(tree->list-2 tree2)
(tree->list-1 tree3)
(tree->list-2 tree3)

;; b)
#|
tree->list-1: T(n) = 2T(n/2) + O(n/2) = O(nlog(n))  | append: O(n/2)
tree->list-2: T(n) = 2T(n/2) + O(1)   = O(n)        | cons: O(1)
|#


;; 2.64
(define (list->tree elements)
  (car (partial-tree elements (length elements))))

(define (partial-tree elts n)
  (if (= n 0)
      (cons '() elts)
      (let ((left-size (quotient (- n 1) 2)))
        (let ((left-result (partial-tree elts left-size)))
          (let ((left-tree (car left-result))
                (non-left-elts (cdr left-result))
                (right-size (- n (+ left-size 1))))
            (let ((this-entry (car non-left-elts))
                  (right-result (partial-tree (cdr non-left-elts) right-size)))
              (let ((right-tree (car right-result))
                    (remaining-elts (cdr right-result)))
                (cons (make-tree this-entry left-tree right-tree)
                      remaining-elts))))))))

(list->tree (list 1 3 5 7 9 11))
#|
a) partial-tree 将 list 分割成3部分, entry/left/right, 其中 left/right 会递归的调用 partial-tree
     5
   /   \
  1     7
   \   / \
    3 9   11
b) T(n) = 2T(n/2) + O(1) = O(n)
|#


;; 2.65
(define (union-set-tree tree1 tree2)
  (list->tree (union-set (tree->list-2 tree1) (tree->list-2 tree2))))
(define (intersection-set-tree tree1 tree2)
  (list->tree (intersection-set (tree->list-2 tree1) (tree->list-2 tree2))))

;; Testing
(union-set-tree (list->tree (list 1 2 3 4 5)) (list->tree (list 3 4 5 6 7)))
(intersection-set-tree (list->tree (list 1 2 3 4 5)) (list->tree (list 3 4 5 6 7)))


;; 2.66
(define (lookup given-key set-of-records)
  (if (null? set-of-records)
      false
      (let ((k (key (entry set-of-records))))
        (cond ((= given-key k) (entry set-of-records))
              ((< given-key k) (lookup given-key (left-branch set-of-records)))
              ((> given-key k) (lookup given-key (right-branch set-of-records)))))))
