(define (make-leaf symbol weight) (list 'leaf symbol weight))
(define (leaf? object) (eq? (car object) 'leaf))
(define (symbol-leaf x) (cadr x))
(define (weight-leaf x) (caddr x))

(define (make-code-tree left right)
  (list left
        right
        (append (symbols left) (symbols right))
        (+ (weight left) (weight right))))

(define (left-branch tree) (car tree))
(define (right-branch tree) (cadr tree))
(define (symbols tree) (if (leaf? tree) (list (symbol-leaf tree)) (caddr tree)))
(define (weight tree) (if (leaf? tree) (weight-leaf tree) (cadddr tree)))

(define (decode bits tree)
  (define (choose-branch bit branch)
    (cond ((= bit 0) (left-branch branch))
          ((= bit 1) (right-branch branch))
          (else (error "bad bit -- CHOOSE-BRANCH" bit))))

  (define (decode-1 bits current-branch)
    (if (null? bits)
        '()
        (let ((next-branch (choose-branch (car bits) current-branch)))
          (if (leaf? next-branch)
              (cons (symbol-leaf next-branch) (decode-1 (cdr bits) tree))
              (decode-1 (cdr bits) next-branch)))))

  (decode-1 bits tree))

;; 2.67
(define sample-tree
  (make-code-tree (make-leaf 'A 4)
                  (make-code-tree
                   (make-leaf 'B 2)
                   (make-code-tree (make-leaf 'D 1)
                                   (make-leaf 'C 1)))))
sample-tree
(define sample-message '(0 1 1 0 0 1 0 1 0 1 1 1 0))
;;                       A D     A B   B   C     A
(decode sample-message sample-tree)


;; 2.68
(define (encode message tree)
  (if (null? message)
      '()
      (append (encode-symbol (car message) tree)
              (encode (cdr message) tree))))

(define (in-branch? symbol branch)
  (if (leaf? branch)
      (eq? symbol (symbol-leaf branch))
      (memq symbol (caddr branch))))

(define (encode-symbol symbol tree)
  (cond ((leaf? tree) '())
        ((in-branch? symbol (left-branch tree))
         (cons 0 (encode-symbol symbol (left-branch tree))))
        ((in-branch? symbol (right-branch tree))
         (cons 1 (encode-symbol symbol (right-branch tree))))
        (else (error "bad symbol -- ENCODE-SYMBOL" symbol))))

(encode '(a d a b b c a) sample-tree)


;; 2.69
(define (adjoin-set x set)
  (cond ((null? set) (list x))
        ((< (weight x) (weight (car set))) (cons x set))
        (else (cons (car set) (adjoin-set x (cdr set))))))

(define (make-leaf-set pairs)
  (if (null? pairs)
      '()
      (let ((pair (car pairs)))
        (adjoin-set (make-leaf (car pair)    ; symbol
                               (cadr pair))  ; frequency
                    (make-leaf-set (cdr pairs))))))

(define (generate-huffman-tree pairs)
  (successive-merge (make-leaf-set pairs)))

(define (successive-merge leaf-pairs)
  (if (<= (length leaf-pairs) 1)
      (car leaf-pairs)
      (successive-merge (adjoin-set (make-code-tree (car leaf-pairs) (cadr leaf-pairs))
                              (cddr leaf-pairs)))))

;; Testing
sample-tree
(generate-huffman-tree '((a 4) (b 2) (d 1) (c 1)))


;; 2.70
(define tree-2.70 (generate-huffman-tree '((a 2) (na 16) (boom 1) (sha 3) (get 2) (yip 9) (job 2) (wah 1))))
(define song-2.70 '(Get a job
                   Sha na na na na na na na na
                   Get a job
                   Sha na na na na na na na na
                   Wah yip yip yip yip yip yip yip yip yip
                   Sha boom))

;; Testing
;; Huffman 编码长度
(length (encode song-2.70 tree-2.70))
;; 定长编码长度
(* 3 (length song-2.70))


;; 2.71
#|
       abcde 31
          /    \
      abcd 15   e 16
        /    \
     abc 7    d 8
      /   \
    ab 3   c 4
    /   \
   a 1   b 2

最频繁的符号: 1个二进制位
最不频繁的符号: (n-1)个二进制位
|#


;; 2.72 略
