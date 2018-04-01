# 6.824: Distributed Systems Labs

## Lab 1: MapReduce
  - Part I: Map/Reduce input and output
    [[37b2ce7]](https://github.com/SaulLawliet/practices/commit/37b2ce7)
    - [src/mapreduce/common_map.go](src/mapreduce/common_map.go)
    - [src/mapreduce/common_reduce.go](src/mapreduce/common_reduce.go)
    
  - Part II: Single-worker word count
    [[b029088]](https://github.com/SaulLawliet/practices/commit/b029088)
    - [src/main/wc.go](src/main/wc.go)
    
  - Part III: Distributing MapReduce tasks
    [[3f6e33f]](https://github.com/SaulLawliet/practices/commit/3f6e33f)
    - [src/mapreduce/schedule.go](src/mapreduce/schedule.go)
    
  - Part IV: Handling worker failures
    [[8e5d45c]](https://github.com/SaulLawliet/practices/commit/8e5d45c)
    - [src/mapreduce/schedule.go](src/mapreduce/schedule.go)
    
  - Part V: Inverted index generation
    [[7329eb0]](https://github.com/SaulLawliet/practices/commit/7329eb0)
    - [src/main/ii.go](src/main/ii.go)
    
## Lab 2: Raft
  - Part 2A [[ed45c0d]](https://github.com/SaulLawliet/practices/commit/ed45c0d)
    - [src/raft/raft.go](src/raft/raft.go)
    ```
    $ go test -race -run 2A
    Test (2A): initial election ...
      ... Passed --   2.5  3   44    0
    Test (2A): election after network failure ...
      ... Passed --   4.5  3  126    0
    PASS
    ok  	raft	8.014s
    ```
  - Part 2B [[37a693c]](https://github.com/SaulLawliet/practices/commit/37a693c)
    - [src/raft/raft.go](src/raft/raft.go)
    - [src/raft/logentry.go](src/raft/logentry.go)
    ```
    $ go test -race -run 2B
    Test (2B): basic agreement ...
      ... Passed --   0.9  5   32    3
    Test (2B): agreement despite follower disconnection ...
      ... Passed --   4.8  3   96    7
    Test (2B): no agreement if too many followers disconnect ...
      ... Passed --   3.6  5  200    3
    Test (2B): concurrent Start()s ...
      ... Passed --   0.7  3   12    6
    Test (2B): rejoin of partitioned leader ...
      ... Passed --   6.4  3  184    4
    Test (2B): leader backs up quickly over incorrect follower logs ...
      ... Passed --  27.2  5 2256  102
    Test (2B): RPC counts aren't too high ...
      ... Passed --   2.4  3   44   12
    PASS
    ok  	raft	47.061s
    ```
  - Part 2C [[a524754]](https://github.com/SaulLawliet/practices/commit/a524754)
    - [src/raft/raft.go](src/raft/raft.go)
    - [src/raft/logentry.go](src/raft/logentry.go)
    ```
    go test -race -run 2C
    Test (2C): basic persistence ...
      ... Passed --   4.3  3   82    6
    Test (2C): more persistence ...
      ... Passed --  17.2  5  960   16
    Test (2C): partitioned leader and one follower crash, leader restarts ...
      ... Passed --   2.1  3   38    4
    Test (2C): Figure 8 ...
      ... Passed --  28.9  5  848    8
    Test (2C): unreliable agreement ...
      ... Passed --  12.9  5  500  251
    Test (2C): Figure 8 (unreliable) ...
      ... Passed --  31.4  5 2672  456
    Test (2C): churn ...
      ... Passed --  16.5  5  732   98
    Test (2C): unreliable churn ...
      ... Passed --  16.5  5  648  157
    PASS
    ok  	raft	130.868s
    ```
## Lab 3: KV Raft
## Lab 4: Sharded KV
