;; 1.15
#|
                                                                     (count-change 11)
                                                                             |
                                                                          (cc 11 5)
                                                                         /         \
                                                              (cc 11 4)               (cc -39 5)
                                                           /             \
                                               (cc 11 3)                   (cc -14 4)
                                       /                      \
                         (cc 11 2)                                 (cc 1 3)
                       /           \                              /        \
             (cc 11 1)               (cc 6 2)                 (cc 1 2)     (cc -9 3)
            /    |                  /        \                    |   \
   (cc 11 0) (cc 10 1)          (cc 6 1)  (cc 1 2)            (cc 1 1) (cc -4 2)
            /    |             /    |         |   \               |   \
   (cc 10 0) (cc 9 1)  (cc 6 0) (cc 5 1)  (cc 1 1) (cc -4 2)  (cc 1 0) (cc 0 1)
            /    |             /    |         |   \                        |
    (cc 9 0) (cc 8 1)  (cc 5 0) (cc 4 1)  (cc 1 0) (cc 0 1)                1
            /    |             /    |                  |
    (cc 8 0) (cc 7 1)  (cc 4 0) (cc 3 1)               1
            /    |             /    |
    (cc 7 0) (cc 6 1)  (cc 3 0) (cc 2 1)
            /    |             /    |
    (cc 6 0) (cc 5 1)  (cc 2 0) (cc 1 1)
            /    |                  |   \
    (cc 5 0) (cc 4 1)           (cc 1 0) (cc 0 1)
            /    |                           |
    (cc 4 0) (cc 3 1)                        1
            /    |
    (cc 3 0) (cc 2 1)
            /    |
    (cc 2 0) (cc 1 1)
                 |   \
             (cc 1 0) (cc 0 1)
                          |
                          1
|#


;; 1.16
#|
(sine 12.15)
(p (sine 4.05))
(p (p (sine 1.35)))
(p (p (p (sine 0.45))))
(p (p (p (p (sine 0.15)))))
(p (p (p (p (p (sine 0.05))))))
(p (p (p (p (p 0.05)))))

;; a) 5次
;; b) 略
|#
