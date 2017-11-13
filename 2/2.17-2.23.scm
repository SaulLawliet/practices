;; 2.17
(define (last-pair items)
  (if (null? (cdr items))
      (car items)
      (last-pair (cdr items))))

;;Testing
(= 34 (last-pair (list 23 72 149 34)))

(define (append list1 list2)
  (if (null? list1)
      list2
      (cons (car list1) (append (cdr list1) list2))))

(append (list 1 2) (list 3 4))


;; 2.18
(define (reverse items)
  (if (null? (cdr items))
      items
      (append (reverse (cdr items)) (list (car items)))))

;; Testing
(reverse (list 1 4 9 16 25))


;; 2.19
(define (cc amount coin-values)
  (cond ((= amount 0) 1)
        ((or (< amount 0) (no-more? coin-values)) 0)
        (else (+ (cc amount (expect-first-denomination coin-values))
                 (cc (- amount (first-denomination coin-values)) coin-values)))))

(define (first-denomination coin-values) (car coin-values))
(define (expect-first-denomination coin-values) (cdr coin-values))
(define (no-more? coin-values) (null? coin-values))

;; Testing
(= 292
   (cc 100 (list 50 25 10 5 1))
   (cc 100 (list 1 5 10 25 50))
   (cc 100 (list 1 10 50 25 5)))


;; 2.20
(define (same-parity first . rest)
  (define (iter result rest)
    (if (null? rest)
        result
        (iter
         (if (= (remainder first 2) (remainder (car rest) 2))
             (append result (list (car rest)))
             result)
         (cdr rest))))
  (iter (list first) rest))

;; Testing
(same-parity 1 2 3 4 5 6 7)
(same-parity 2 3 4 5 6 7)


;; 2.21
(define (square-list items)
  (if (null? items)
      ()
      (cons (square (car items)) (square-list (cdr items)))))

(define (square-list-b items)
  (map square items))

;; Testing
(square-list (list 1 2 3 4))
(square-list-b (list 1 2 3 4))


;; 2.22
;; a) 由于 cons 操作时, answer 是第二个参数, 所以先计算的元素会在列表的后面
;; b) 由于 cons 第一个参数是列表, 所以最后的结果不可能是列表, 虽然顺序正确


;; 2.23
;; 使用 if 会有作用于的问题, 所以用 cond 代替
(define (for-each proc items)
  (cond ((null? items) true)
        (else (proc (car items))
              (for-each proc (cdr items)))))

(for-each (lambda (x) (newline) (display x))
          (list 57 321 88))
