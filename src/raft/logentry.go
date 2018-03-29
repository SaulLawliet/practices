package raft

import (
	"errors"
)

type LogEntry struct {
	Index   int
	Term    int
	Command interface{}
}

type logEntries struct {
	entries   []LogEntry
	lastIndex int
}

// 算出 entries 的数组索引，因为本地日志的第一个 Index 可能不是 1
func (log *logEntries) _realIndex(index int) (int, error) {
	if index == 0 || index > log.lastIndex {
		return 0, errors.New("Not found")
	}
	return index - log.entries[0].Index, nil
}

func (log *logEntries) append(entries ...LogEntry) {
	l := len(entries)
	if l > 0 {
		if log.lastIndex+1 < entries[0].Index {
			panic("log.lastIndex+1 < entries[0].Index")
		}
		if log.lastIndex+1 > entries[0].Index {
			log.delete(entries[0].Index)
		}
		log.entries = append(log.entries, entries...)
		log.lastIndex = entries[l-1].Index
	}
}

func (log *logEntries) delete(index int) {
	realIndex, err := log._realIndex(index)
	if err != nil {
		panic(err)
	}
	log.entries = log.entries[0:realIndex]
	log.lastIndex = index - 1
}

func (log *logEntries) getTerm(index int) int {
	var err error
	if index, err = log._realIndex(index); err != nil {
		return 0
	}
	return log.entries[index].Term
}

func (log *logEntries) getCommand(index int) interface{} {
	var err error
	if index, err = log._realIndex(index); err != nil {
		return nil
	}
	return log.entries[index].Command
}

func (log *logEntries) rest(index int) []LogEntry {
	index, err := log._realIndex(index)
	if err != nil {
		return nil
	}
	l := len(log.entries)
	entries := make([]LogEntry, l-index)
	copy(entries, log.entries[index:]) // 一定要 copy()，不然会引起 DATA RACE
	return entries
}
