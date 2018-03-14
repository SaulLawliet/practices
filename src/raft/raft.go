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

	// Persistent state on all servers:
	currentTerm int
	votedFor    int
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
	Term        int
	CandidateID int
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

	if args.Term < rf.currentTerm {
		reply.Term = rf.currentTerm
		return
	}
	if args.Term > rf.currentTerm {
		rf.currentTerm = args.Term
		rf.state = stateFollower
		rf.votedFor = -1
	}

	if rf.votedFor == -1 || rf.votedFor == args.CandidateID {
		rf.votedFor = args.CandidateID
		reply.VoteGranted = true
		rf.heartbeat <- struct{}{}
	}
}

type AppendEntriesArgs struct {
	Term     int
	LeaderID int
}
type AppendEntriesReply struct {
	Term    int
	Success bool
}

func (rf *Raft) AppendEntries(args *AppendEntriesArgs, reply *AppendEntriesReply) {
	rf.mu.Lock()
	defer rf.mu.Unlock()

	if args.Term < rf.currentTerm {
		reply.Success = false
		reply.Term = rf.currentTerm
		return
	}

	if args.Term > rf.currentTerm {
		rf.currentTerm = args.Term
		rf.state = stateFollower
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
	index := -1
	term := -1
	isLeader := true

	// Your code here (2B).

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
	DPrintf("[server: %d, term: %2d] "+format,
		append([]interface{}{rf.me, rf.currentTerm}, a...)...)
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
	rf.heartbeat = make(chan struct{})

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
				rf.currentTerm++
				rf.votedFor = rf.me
				rf.voteCount = 1
				rf.DPrintf("loop() --- election timeout, turning to CANDIDATE")
				rf.mu.Unlock()
			}
		}
	}()

	return rf
}

func (rf *Raft) doLeaderElection() {
	rf.DPrintf("doLeaderElection()")
	size := len(rf.peers)
	rf.mu.Lock()
	args := RequestVoteArgs{
		Term:        rf.currentTerm,
		CandidateID: rf.me,
	}
	rf.mu.Unlock()

	for i := 0; i < size; i++ {
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

				if reply.Term > rf.currentTerm {
					rf.DPrintf("doLeaderElection()  -> discover high term, convert to FOLLOW")
					rf.currentTerm = reply.Term
					rf.state = stateFollower
					rf.heartbeat <- struct{}{}
				} else if reply.VoteGranted {
					rf.voteCount++
					rf.DPrintf("doLeaderElection()  -> recived vote, now votes:%d", rf.voteCount)
					if rf.voteCount > size/2 {
						rf.DPrintf("doLeaderElection()  -> success, convert to LEADER")
						rf.state = stateLeader
						rf.heartbeat <- struct{}{}
					}
				}
			}
		}()
	}
}

func (rf *Raft) doHeartbeats() {
	rf.DPrintf("doHeartbeats()")
	rf.mu.Lock()
	args := AppendEntriesArgs{
		Term:     rf.currentTerm,
		LeaderID: rf.me,
	}
	rf.mu.Unlock()

	for i := 0; i < len(rf.peers); i++ {
		if i == rf.me {
			continue
		}
		i := i
		go func() {
			reply := AppendEntriesReply{}
			if rf.sendAppendEntries(i, &args, &reply) {
				rf.mu.Lock()
				defer rf.mu.Unlock()
				rf.DPrintf("doHeartbeats()  -> ask to server:%d", i)

				if rf.state != stateLeader {
					rf.DPrintf("doHeartbeats()  -> not LEADER, skip")
					return
				}

				if reply.Term > rf.currentTerm {
					rf.DPrintf("doHeartbeats()  -> discover high term, turing to FOLLOW")
					rf.currentTerm = reply.Term
					rf.state = stateFollower
				}
			}
		}()
	}

	time.Sleep(time.Millisecond * 100)
	rf.heartbeat <- struct{}{}
}
