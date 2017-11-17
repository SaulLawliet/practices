(define nil '())
(define (accumulate op initial sequence)
  (if (null? sequence)
      initial
      (op (car sequence) (accumulate op initial (cdr sequence)))))

;; 2.33
(define (map-my p sequence)
  (accumulate (lambda (x y) (cons (p x) y)) nil sequence))
(define (append-my seq1 seq2)
  (accumulate cons seq2 seq1))
(define (length-my sequence)
  (accumulate (lambda (x y) (+ y 1)) 0 sequence))

;; Testing
;; (1 4 9 16)
(map-my square (list 1 2 3 4))
;; (1 2 3 4)
(append-my (list 1 2) (list 3 4))
;; 4
(length-my (list 1 2 3 4))


;; 2.34
(define (horner-eval x coefficient-sequence)
  (accumulate (lambda (this-coeff higher-terms) (+ (* higher-terms x) this-coeff))
              0
              coefficient-sequence))

;; Testing 1 + 3*x + 5*x^3 + x^5, x = 2
(= (+ 1 (* 3 (expt 2 1)) (* 5 (expt 2 3)) (expt 2 5))
   (horner-eval 2 (list 1 3 0 5 0 1)))


;; 2.35
(define (count-leaves t)
  (accumulate (lambda (x y) (+ x y)) 0
              (map (lambda (x) (if (pair? x) (count-leaves x) 1)) t)))

;; Testing
(= 0 (count-leaves (list)))
(= 4 (count-leaves (list 1 2 3 4)))
(= 8 (count-leaves (list (list 1 2 3 4) (list 1 2 3 4))))


;; 2.36
(define (accumulate-n op init seqs)
  (if (null? (car seqs))
      nil
      (cons (accumulate op init (map car seqs))
            (accumulate-n op init (map cdr seqs)))))

;; Testing (22 26 30)
(accumulate-n + 0 (list (list 1 2 3) (list 4 5 6) (list 7 8 9) (list 10 11 12)))


;; 2.37
(define (dot-product v w) (accumulate + 0 (map * v w)))

(define (matrix-*-vecotr m v) (map (lambda (w) (dot-product v w)) m))

(define (transpose mat) (accumulate-n cons nil mat))

(define (matrix-*-matrix m n)
  (let ((cols (transpose n)))
    (map (lambda (x) (matrix-*-vecotr cols x)) m)))

;; Testing
;; 11
(dot-product (list 1 2) (list 3 4))
;; (50 122)
(matrix-*-vecotr (list (list 1 2 3) (list 4 5 6)) (list 7 8 9))
;; ((1 4 7) (2 5 8) (3 6 9))
(transpose (list (list 1 2 3) (list 4 5 6) (list 7 8 9)))
;; ((5 1) (4 2))
(matrix-*-matrix (list (list 1 0 2) (list -1 3 1)) (list (list 3 1) (list 2 1) (list 1 0)))


;; 2.38
(define fold-right accumulate)
(define (fold-left op initial sequence)
  (define (iter result rest)
    (if (null? rest)
        result
        (iter (op result (car rest)) (cdr rest))))
  (iter initial sequence))

;; Testing
;; op 需要满足交换律时, fold-right 和 fold-left 的结果相同
;; 3/1 = 3, 2/3 = 2/3, 1/(2/3) = 3/2
(fold-right / 1 (list 1 2 3))
;; 1/1 = 1, 1/2 = 1/2, 1/2/3 = 1/6
(fold-left / 1 (list 1 2 3))
;; (3 ()) -> (2 (3 ())) -> (1 (2 (3 ())))
(fold-right list nil (list 1 2 3))
;; (() 1) -> ((() 1) 2) -> (((() 1) 2) 3)
(fold-left list nil (list 1 2 3))


;; 2.39
(define (reverse-right sequence)
  (fold-right (lambda (x y) (append y (list x))) nil sequence))
(define (reverse-left sequence)
  (fold-left (lambda (x y) (cons y x)) nil sequence))

;; Testing
(reverse-right (list 1 2 3))
(reverse-left (list 1 2 3))


;; 2.40
(define (enumerate-interval low high)
  (if (> low high)
      nil
      (cons low (enumerate-interval (+ low 1) high))))

(define (flatmap proc seq) (accumulate append nil (map proc seq)))

(define (prime? n)
  (define (smallest-divisor n)
    (find-divisor n 2))
  (define (find-divisor n test-divisor)
    (cond ((> (square test-divisor) n) n)
          ((divides? test-divisor n) test-divisor)
          (else (find-divisor n (+ test-divisor 1)))))
  (define (divides? a b)
    (= (remainder b a) 0))

  (and (> n 1) (= n (smallest-divisor n))))

(define (prime-sum? pair)
  (prime? (+ (car pair) (cadr pair))))

(define (make-pair-sum pair)
  (list (car pair) (cadr pair) (+ (car pair) (cadr pair))))

(define (unique-pairs n)
  (flatmap (lambda (i) (map (lambda (j) (list i j)) (enumerate-interval 1 (- i 1))))
           (enumerate-interval 1 n)))

(define (prime-sum-pairs n)
  (map make-pair-sum (filter prime-sum? (unique-pairs n))))

;; Testing
(prime-sum-pairs 6)


;; 2.41
(define (unique-triples n)
  (flatmap (lambda (i)
             (flatmap (lambda (j)
                        (map (lambda (k)
                               (list i j k))
                             (enumerate-interval 1 (- j 1))))
                      (enumerate-interval 1 (- i 1))))
           (enumerate-interval 1 n)))

(define (ordered-triples-sum n s)
  (filter (lambda (triple) (= s (accumulate + 0 triple)))
          (unique-triples n)))

;; Testing
(ordered-triples-sum 6 12)


;; 2.42
(define (queens board-size)
  (define (queen-cols k)
    (if (= k 0)
        (list empty-board)
        (filter
         (lambda (positions) (safe? k positions))
         (flatmap
          (lambda (rest-of-queens)
            (map (lambda (new-row)
                   (adjoin-position new-row k rest-of-queens))
                 (enumerate-interval 1 board-size)))
          (queen-cols (- k 1))))))
  (queen-cols board-size))

;; 存储结构: 列表依次是每一列的行数
(define empty-board nil)

(define (adjoin-position row col positions) (append positions (list row)))

(define (safe? col positions)
  (define last-element (list-ref positions (- col 1)))
  (define (iter i)
    (cond ((= i col) true)
          (else (let ((dis (abs (- last-element
                                   (list-ref positions (- i 1))))))
                  (and (not (= dis 0))
                       (not (= dis (- col i)))
                       (iter (+ i 1)))))))
  (iter 1))

;; Testing
(= 92 (length (queens 8)))


;; 2.43 略
