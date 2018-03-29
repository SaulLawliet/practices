package raft

//
// this is an outline of the API that raft must expose to
// the service (or tester). see comments below for
// each of these functions for more details.
//
// rf = Make(...)
//   create a new Raft server.
// rf.Start(command interface{}) (index, term, isleader)
//   start agreement on a new log entry
// rf.GetState() (term, isLeader)
//   ask a Raft for its current term, and whether it thinks it is leader
// ApplyMsg
//   each time a new entry is committed to the log, each Raft peer
//   should send an ApplyMsg to the service (or tester)
//   in the same server.
//

import (
	"labrpc"
	"math/rand"
	"sync"
	"time"
)

// import "bytes"
// import "labgob"
const (
	stateFollower = iota
	stateCandidate
	stateLeader
)

//
// as each Raft peer becomes aware that successive log entries are
// committed, the peer should send an ApplyMsg to the service (or
// tester) on the same server, via the applyCh passed to Make(). set
// CommandValid to true to indicate that the ApplyMsg contains a newly
// committed log entry.
//
// in Lab 3 you'll want to send other kinds of messages (e.g.,
// snapshots) on the applyCh; at that point you can add fields to
// ApplyMsg, but set CommandValid to false for these other uses.
//
type ApplyMsg struct {
	CommandValid bool
	Command      interface{}
	CommandIndex int
}

//
// A Go object implementing a single Raft peer.
//
type Raft struct {
	mu        sync.Mutex          // Lock to protect shared access to this peer's state
	peers     []*labrpc.ClientEnd // RPC end points of all peers
	persister *Persister          // Object to hold this peer's persisted state
	me        int                 // this peer's index into peers[]

	// Your data here (2A, 2B, 2C).
	// Look at the paper's Figure 2 for a description of what
	// state a Raft server must maintain.
	state     int
	voteCount int
	heartbeat chan struct{}
	stoped    bool
	applyCh   chan ApplyMsg

	// Persistent state on all servers:
	currentTerm int
	votedFor    int
	log         logEntries
	// Volatile state on all servers:
	commitIndex int
	lastApplied int
	// Volatile state on leaders:
	nextIndex  []int
	matchIndex []int
}

func (rf *Raft) convertToFollower(term int) {
	rf.currentTerm = term
	rf.state = stateFollower
	rf.votedFor = -1
}

// return currentTerm and whether this server
// believes it is the leader.
func (rf *Raft) GetState() (int, bool) {
	// Your code here (2A).
	rf.mu.Lock()
	defer rf.mu.Unlock()
	return rf.currentTerm, rf.state == stateLeader
}

//
// save Raft's persistent state to stable storage,
// where it can later be retrieved after a crash and restart.
// see paper's Figure 2 for a description of what should be persistent.
//
func (rf *Raft) persist() {
	// Your code here (2C).
	// Example:
	// w := new(bytes.Buffer)
	// e := labgob.NewEncoder(w)
	// e.Encode(rf.xxx)
	// e.Encode(rf.yyy)
	// data := w.Bytes()
	// rf.persister.SaveRaftState(data)
}

//
// restore previously persisted state.
//
func (rf *Raft) readPersist(data []byte) {
	if data == nil || len(data) < 1 { // bootstrap without any state?
		return
	}
	// Your code here (2C).
	// Example:
	// r := bytes.NewBuffer(data)
	// d := labgob.NewDecoder(r)
	// var xxx
	// var yyy
	// if d.Decode(&xxx) != nil ||
	//    d.Decode(&yyy) != nil {
	//   error...
	// } else {
	//   rf.xxx = xxx
	//   rf.yyy = yyy
	// }
}

//
// example RequestVote RPC arguments structure.
// field names must start with capital letters!
//
type RequestVoteArgs struct {
	// Your data here (2A, 2B).
	Term         int
	CandidateID  int
	LastLogIndex int
	LastLogTerm  int
}

//
// example RequestVote RPC reply structure.
// field names must start with capital letters!
//
type RequestVoteReply struct {
	// Your data here (2A).
	Term        int
	VoteGranted bool
}

//
// example RequestVote RPC handler.
//
func (rf *Raft) RequestVote(args *RequestVoteArgs, reply *RequestVoteReply) {
	// Your code here (2A, 2B).
	rf.mu.Lock()
	defer rf.mu.Unlock()
	reply.VoteGranted = false

	// 1. Reply false if term < currentTerm (§5.1)
	if args.Term < rf.currentTerm {
		reply.Term = rf.currentTerm
		return
	}

	if args.Term > rf.currentTerm {
		rf.convertToFollower(args.Term)
	}

	// 2. If votedFor is null or candidateId, and candidate’s log is at
	//    least as up-to-date as receiver’s log, grant vote (§5.2, §5.4)
	if rf.votedFor == -1 || rf.votedFor == args.CandidateID {
		compare := args.LastLogTerm - rf.log.getTerm(rf.log.lastIndex)
		if compare > 0 || (compare == 0 && args.LastLogIndex >= rf.log.lastIndex) {
			rf.votedFor = args.CandidateID
			reply.VoteGranted = true
		}
	}

	if reply.VoteGranted {
		rf.heartbeat <- struct{}{}
	}
}

type AppendEntriesArgs struct {
	Term         int
	LeaderID     int
	PrevLogIndex int
	PrevLogTerm  int
	Entries      []LogEntry
	LeaderCommit int
}
type AppendEntriesReply struct {
	Term    int
	Success bool
}

func (rf *Raft) AppendEntries(args *AppendEntriesArgs, reply *AppendEntriesReply) {
	rf.mu.Lock()
	defer rf.mu.Unlock()
	reply.Success = false

	// 1. Reply false if term < currentTerm (§5.1)
	if args.Term < rf.currentTerm {
		reply.Term = rf.currentTerm
		return
	}

	if args.Term > rf.currentTerm || rf.state != stateFollower {
		rf.convertToFollower(args.Term)
	}

	// 2. Reply false if log doesn’t contain an entry at prevLogIndex
	//    whose term matches prevLogTerm (§5.3)
	if args.PrevLogIndex > 0 {
		entryTerm := rf.log.getTerm(args.PrevLogIndex)
		if entryTerm != args.PrevLogTerm {
			if entryTerm > 0 {
				// 3. If an existing entry conflicts with a new one (same index
				//    but different terms), delete the existing entry and all that
				//    follow it (§5.3)
				rf.log.delete(args.PrevLogIndex)
			}
			rf.heartbeat <- struct{}{}
			return
		}
	}

	// 4. Append any new entries not already in the log
	rf.log.append(args.Entries...)

	// 5. If leaderCommit > commitIndex, set commitIndex =
	//    min(leaderCommit, index of last new entry)
	if args.LeaderCommit > rf.commitIndex {
		if rf.log.lastIndex < args.LeaderCommit {
			args.LeaderCommit = rf.log.lastIndex
		}

		if rf.commitIndex < args.LeaderCommit {
			rf.commitIndex = args.LeaderCommit
			go rf.applyLogEntry()
		}
	}

	reply.Success = true
	rf.heartbeat <- struct{}{}
}

//
// example code to send a RequestVote RPC to a server.
// server is the index of the target server in rf.peers[].
// expects RPC arguments in args.
// fills in *reply with RPC reply, so caller should
// pass &reply.
// the types of the args and reply passed to Call() must be
// the same as the types of the arguments declared in the
// handler function (including whether they are pointers).
//
// The labrpc package simulates a lossy network, in which servers
// may be unreachable, and in which requests and replies may be lost.
// Call() sends a request and waits for a reply. If a reply arrives
// within a timeout interval, Call() returns true; otherwise
// Call() returns false. Thus Call() may not return for a while.
// A false return can be caused by a dead server, a live server that
// can't be reached, a lost request, or a lost reply.
//
// Call() is guaranteed to return (perhaps after a delay) *except* if the
// handler function on the server side does not return.  Thus there
// is no need to implement your own timeouts around Call().
//
// look at the comments in ../labrpc/labrpc.go for more details.
//
// if you're having trouble getting RPC to work, check that you've
// capitalized all field names in structs passed over RPC, and
// that the caller passes the address of the reply struct with &, not
// the struct itself.
//
func (rf *Raft) sendRequestVote(server int, args *RequestVoteArgs, reply *RequestVoteReply) bool {
	ok := rf.peers[server].Call("Raft.RequestVote", args, reply)
	return ok
}

func (rf *Raft) sendAppendEntries(server int, args *AppendEntriesArgs, reply *AppendEntriesReply) bool {
	ok := rf.peers[server].Call("Raft.AppendEntries", args, reply)
	return ok
}

//
// the service using Raft (e.g. a k/v server) wants to start
// agreement on the next command to be appended to Raft's log. if this
// server isn't the leader, returns false. otherwise start the
// agreement and return immediately. there is no guarantee that this
// command will ever be committed to the Raft log, since the leader
// may fail or lose an election.
//
// the first return value is the index that the command will appear at
// if it's ever committed. the second return value is the current
// term. the third return value is true if this server believes it is
// the leader.
//
func (rf *Raft) Start(command interface{}) (int, int, bool) {
	// Your code here (2B).
	rf.mu.Lock()
	defer rf.mu.Unlock()
	index := -1
	term := rf.currentTerm
	isLeader := rf.state == stateLeader
	if isLeader {
		index = rf.log.lastIndex + 1
		rf.log.append(LogEntry{Index: index, Term: term, Command: command})
	}
	return index, term, isLeader
}

//
// the tester calls Kill() when a Raft instance won't
// be needed again. you are not required to do anything
// in Kill(), but it might be convenient to (for example)
// turn off debug output from this instance.
//
func (rf *Raft) Kill() {
	// Your code here, if desired.
	rf.mu.Lock()
	defer rf.mu.Unlock()
	rf.stoped = true
	rf.heartbeat <- struct{}{} // 防止状态切换为 candidate
}

func (rf *Raft) DPrintf(format string, a ...interface{}) {
	DPrintf("[term: %2d, server: %d] "+format,
		append([]interface{}{rf.currentTerm, rf.me}, a...)...)
}

//
// the service or tester wants to create a Raft server. the ports
// of all the Raft servers (including this one) are in peers[]. this
// server's port is peers[me]. all the servers' peers[] arrays
// have the same order. persister is a place for this server to
// save its persistent state, and also initially holds the most
// recent saved state, if any. applyCh is a channel on which the
// tester or service expects Raft to send ApplyMsg messages.
// Make() must return quickly, so it should start goroutines
// for any long-running work.
//
func Make(peers []*labrpc.ClientEnd, me int,
	persister *Persister, applyCh chan ApplyMsg) *Raft {
	rf := &Raft{}
	rf.peers = peers
	rf.persister = persister
	rf.me = me

	// Your initialization code here (2A, 2B, 2C).
	rf.state = stateFollower
	rf.heartbeat = make(chan struct{}, 10) // 不加缓冲区会导致 Livelocks
	rf.applyCh = applyCh

	// initialize from state persisted before a crash
	rf.readPersist(persister.ReadRaftState())

	go func() {
		for {
			rf.mu.Lock()
			if rf.stoped {
				break
			}
			state := rf.state
			rf.mu.Unlock()

			switch state {
			case stateCandidate:
				go rf.doLeaderElection()
			case stateLeader:
				go rf.doHeartbeats()
			}

			select {
			case <-rf.heartbeat:
			case <-time.After(time.Millisecond * time.Duration((rand.Intn(150) + 150))):
				rf.mu.Lock()
				rf.state = stateCandidate
				rf.DPrintf("loop() --- election timeout, turning to CANDIDATE")
				rf.mu.Unlock()
			}
		}
	}()

	return rf
}

func (rf *Raft) doLeaderElection() {
	rf.mu.Lock()
	rf.currentTerm++
	rf.votedFor = rf.me
	rf.voteCount = 1

	args := RequestVoteArgs{
		Term:        rf.currentTerm,
		CandidateID: rf.me,
	}
	if rf.log.lastIndex > 0 {
		args.LastLogIndex = rf.log.lastIndex
		args.LastLogTerm = rf.log.getTerm(rf.log.lastIndex)
	}
	rf.DPrintf("doLeaderElection() %+v", args)
	rf.mu.Unlock()

	for i := 0; i < len(rf.peers); i++ {
		if i == rf.me {
			continue
		}
		i := i
		go func() {
			reply := RequestVoteReply{}
			if rf.sendRequestVote(i, &args, &reply) {
				rf.mu.Lock()
				defer rf.mu.Unlock()
				rf.DPrintf("doLeaderElection()  -> ask to server:%d", i)

				if rf.state != stateCandidate {
					rf.DPrintf("doLeaderElection()  -> already done, skip")
					return
				}

				if args.Term != rf.currentTerm {
					rf.DPrintf("doLeaderElection()  -> expired, skip")
					return
				}

				if reply.Term > rf.currentTerm {
					rf.DPrintf("doLeaderElection()  -> discover high term, convert to FOLLOW")
					rf.convertToFollower(reply.Term)
					rf.heartbeat <- struct{}{}
				} else if reply.VoteGranted {
					rf.voteCount++
					rf.DPrintf("doLeaderElection()  -> recived vote by %d, now votes:%d", i, rf.voteCount)
					if rf.voteCount > len(rf.peers)/2 {
						rf.DPrintf("doLeaderElection()  -> success, convert to LEADER")
						rf.state = stateLeader
						rf.nextIndex = make([]int, len(rf.peers))
						rf.matchIndex = make([]int, len(rf.peers))
						for i := range rf.peers {
							rf.nextIndex[i] = rf.log.lastIndex + 1
							rf.matchIndex[i] = 0
						}
						rf.heartbeat <- struct{}{}
					}
				}
			}
		}()
	}
}

func (rf *Raft) doHeartbeats() {
	for i := 0; i < len(rf.peers); i++ {
		if i == rf.me {
			continue
		}
		i := i
		go func() {
			rf.mu.Lock()
			args := AppendEntriesArgs{
				Term:         rf.currentTerm,
				LeaderID:     rf.me,
				LeaderCommit: rf.commitIndex,
				PrevLogIndex: rf.nextIndex[i] - 1,
				PrevLogTerm:  rf.log.getTerm(rf.nextIndex[i] - 1),
				Entries:      rf.log.rest(rf.nextIndex[i]),
			}
			rf.mu.Unlock()

			reply := AppendEntriesReply{}
			if rf.sendAppendEntries(i, &args, &reply) {
				rf.mu.Lock()
				defer rf.mu.Unlock()
				rf.DPrintf("doHeartbeats()  -> ask to server:%d, args: %v", i, args)

				if rf.state != stateLeader {
					rf.DPrintf("doHeartbeats()  -> not LEADER, skip")
					return
				}

				if args.Term != rf.currentTerm {
					rf.DPrintf("doLeaderElection()  -> expired, skip")
					return
				}

				if reply.Term > rf.currentTerm {
					rf.DPrintf("doHeartbeats()  -> discover high term, turing to FOLLOW")
					rf.convertToFollower(reply.Term)
					return
				}

				if reply.Success {
					// update nextIndex and matchIndex for follower
					l := len(args.Entries)
					if l > 0 {
						rf.matchIndex[i] = args.Entries[l-1].Index
						rf.nextIndex[i] = rf.matchIndex[i] + 1
						if rf.matchIndex[i] > rf.commitIndex {
							count := 0
							for j := 0; j < len(rf.peers); j++ {
								if j == rf.me || j == i || rf.matchIndex[j] >= rf.matchIndex[i] {
									count++
									if count > len(rf.peers)/2 {
										rf.commitIndex = rf.matchIndex[i]
										go rf.applyLogEntry()
									}
								}
							}
						}
					}
				} else {
					rf.nextIndex[i] /= 2 // 简单暴力：half-way
				}
			}
		}()
	}

	time.Sleep(time.Millisecond * 100)
	rf.heartbeat <- struct{}{}
}

func (rf *Raft) applyLogEntry() {
	rf.mu.Lock()
	defer rf.mu.Unlock()
	for rf.commitIndex > rf.lastApplied {
		rf.lastApplied++
		rf.applyCh <- ApplyMsg{CommandValid: true, Command: rf.log.getCommand(rf.lastApplied), CommandIndex: rf.lastApplied}
		rf.DPrintf("applyLogEntry()  -> commitIndex: %d, lastApplied: %d, log: %v", rf.commitIndex, rf.lastApplied, rf.log)
	}
}
