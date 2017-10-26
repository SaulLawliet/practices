;; 1.20
;; 正则序: 18次 (1 + 2 + 4 + 7 + 4)
(gcd 206 40)
  (if (= 40 0) ...)
(gcd 40
     (remainder 206 40))
  (if (= (remainder 206 40) 0) ...) ;; 1
  (if (= 6 0) ...)
(gcd (remainder 206 40)
     (remainder 40 (remainder 206 40)))
  (if (= (remainder 40 (remainder 206 40)) 0) ...) ;; 2
  (if (= 4 0) ...)
(gcd (remainder 40 (remainder 206 40))
     (remainder (remainder 206 40) (remainder 40 (remainder 206 40))))
  (if (= (remainder (remainder 206 40) (remainder 40 (remainder 206 40))) 0) ...) ;; 4
  (if (= 2 0) ...)
(gcd (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))
     (remainder (remainder 40 (remainder 206 40)) (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))))
  (if (= (remainder (remainder 40 (remainder 206 40)) (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))) 0) ...) ;; 7
  (if (= 0 0) ...)
(remainder (remainder 206 40) (remainder 40 (remainder 206 40))) ;; 4

;; 应用序: 4次
(gcd 206 40)
(gcd 40 (remainder 206 40))
(gcd 40 6)
(gcd 6 (remainder 40 6))
(gcd 6 4)
(gcd 4 (remainder 6 4))
(gcd 4 2)
(gcd 2 (remainder 4 2))
(gcd 2 0)
2
