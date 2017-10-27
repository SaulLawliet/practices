;; 1.21
(define (smallest-divisor n)
  (find-divisor n 2))
(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
        ((divides? test-divisor n) test-divisor)
        (else (find-divisor n (+ test-divisor 1)))))
(define (divides? a b)
  (= (remainder b a) 0))

;; Testing
(= 199 (smallest-divisor 199))
(= 1999 (smallest-divisor 1999))
(= 7 (smallest-divisor 19999))


;; 1.22
;; 修改示例, 使其返回消耗时间, 同时只打印素数
(define (prime? n)
  (= n (smallest-divisor n)))
(define (timed-prime-test n)
  (define (report-prime elapsed-time)
    (newline)
    (display n )
    (display " *** ")
    (display elapsed-time)
    elapsed-time)
  (define (start-prime-test start-time)
    (if (prime? n)
        (report-prime (- (runtime) start-time))
        0))
  (start-prime-test (runtime)))

;; 返回 计算三次素数时间的平均值
(define (search-for-primes n)
  (define (sum last-time n start end)
    (+ last-time
       (iter (+ n 2)
             (+ start (if (> last-time 0) 1 0))
             end)))
  (define (iter n start end)
    (if (even? n)
        (iter (+ n 1) start end)
        (if (< start end)
            (sum (timed-prime-test n) n start end)
            0)))
  (/ (iter n 0 3) 3))

;; Testing
;; 现代的电脑计算 10^3, 10^4, 10^5, 10^6 的时间很快, 看不出效果
;; 所以改为计算 10^10, 10^11, 10^12, 10^13
(define a10 (search-for-primes (expt 10 10)))
(define a11 (search-for-primes (expt 10 11)))
(define a12 (search-for-primes (expt 10 12)))
(define a13 (search-for-primes (expt 10 13)))

;; 计算比率, 发现跟 √10(=3.16227766017) 很接近
(/ a11 a10)
(/ a12 a11)
(/ a13 a12)


;; 1.23
;; 重写 find-divisor
(define (next n)
  (if (= n 2) 3 (+ n 2)))
(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
        ((divides? test-divisor n) test-divisor)
        (else (find-divisor n (next test-divisor)))))

;; Testing
(define b10 (search-for-primes (expt 10 10)))
(define b11 (search-for-primes (expt 10 11)))
(define b12 (search-for-primes (expt 10 12)))
(define b13 (search-for-primes (expt 10 13)))

;; 我的测试比率大概在 1.6 左右
;; 可能的原因是: 1: 额外的函数开销, 2: 额外的逻辑判断(if)
(/ a10 b10)
(/ a11 b11)
(/ a12 b12)
(/ a13 b13)


;; 1.24
(define (expmod base exp m)
  (cond ((= exp 0) 1)
        ((even? exp) (remainder (square (expmod base (/ exp 2) m)) m))
        (else (remainder (* base (expmod base (- exp 1) m)) m))))

(define (prime? n)
  (define (fermat-test)
    (define (try-it a)
      (= (expmod a n n) a))
    (try-it (+ 1 (random (- n 1)))))

  (define (fast-prime? times)
    (cond ((= times 0) true)
          ((fermat-test) (fast-prime? (- times 1)))
          (else false)))

  (fast-prime? 100))

;; Testing
(define c10 (search-for-primes (expt 10 10)))
(define c11 (search-for-primes (expt 10 11)))
(define c12 (search-for-primes (expt 10 12)))
(define c13 (search-for-primes (expt 10 13)))

;; 计算比率, 发现跟 log10(=1) 很接近
(/ c11 c10)
(/ c12 c11)
(/ c13 c12)


;; 1.25
;; 根据脚注46: 求一个数的余数可以根据公式 (x*y) % m == ((x % m) * (y % m)) % m
;; 原方法每次计算平方时, 基数一定小于m
;; 而采用1.25的方法计算平方时, 基数可能会是一个很大的数


;; 1.26
;; 每一次计算平方的时候, expmod的计算量跟原来相比都会翻倍, 所以运行时间会变慢


;; 1.27
(define (carmichael-test n)
  (define (iter a)
    (cond ((= a n) true)
          ((= (expmod a n n) a) (iter (+ a 1)))
          (else false)))
  (iter 2))

;; Testing
(carmichael-test 561)
(carmichael-test 1105)
(carmichael-test 1729)
(carmichael-test 2465)
(carmichael-test 2821)
(carmichael-test 6601)


;; 1.28
(define (nontrivial-square-root? a n)
  (and (not (= a 1))
       (not (= a (- n 1)))
       (= 1 (remainder (square a) n))))

(define (miller-rabin-expmod base exp m)
  (cond ((= exp 0) 1)
        ((nontrivial-square-root? base m) 0)
        ((even? exp) (remainder (square (miller-rabin-expmod base (/ exp 2) m)) m))
        (else (remainder (* base (miller-rabin-expmod base (- exp 1) m)) m))))

(define (prime? n)
  (define (miller-rabin-test)
    (define (try-it a)
      (= (miller-rabin-expmod a (- n 1) n) 1))
    (try-it (+ 1 (random (- n 1)))))

  (define (fast-prime? times)
    (cond ((= times 0) true)
          ((miller-rabin-test) (fast-prime? (- times 1)))
          (else false)))

  (fast-prime? (ceiling (/ n 2))))

;; Testing
(prime? 2)
(prime? 13)

(not (prime? 561))
(not (prime? 1105))
(not (prime? 1729))
(not (prime? 2465))
(not (prime? 2821))
(not (prime? 6601))
