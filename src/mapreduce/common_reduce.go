package mapreduce

import (
	"encoding/json"
	"os"
)

func doReduce(
	jobName string, // the name of the whole MapReduce job
	reduceTask int, // which reduce task this is
	outFile string, // write the output here
	nMap int, // the number of map tasks that were run ("M" in the paper)
	reduceF func(key string, values []string) string,
) {
	//
	// doReduce manages one reduce task: it should read the intermediate
	// files for the task, sort the intermediate key/value pairs by key,
	// call the user-defined reduce function (reduceF) for each key, and
	// write reduceF's output to disk.
	//
	// You'll need to read one intermediate file from each map task;
	// reduceName(jobName, m, reduceTask) yields the file
	// name from map task m.
	//
	// Your doMap() encoded the key/value pairs in the intermediate
	// files, so you will need to decode them. If you used JSON, you can
	// read and decode by creating a decoder and repeatedly calling
	// .Decode(&kv) on it until it returns an error.
	//
	// You may find the first example in the golang sort package
	// documentation useful.
	//
	// reduceF() is the application's reduce function. You should
	// call it once per distinct key, with a slice of all the values
	// for that key. reduceF() returns the reduced value for that key.
	//
	// You should write the reduce output as JSON encoded KeyValue
	// objects to the file named outFile. We require you to use JSON
	// because that is what the merger than combines the output
	// from all the reduce tasks expects. There is nothing special about
	// JSON -- it is just the marshalling format we chose to use. Your
	// output code will look something like this:
	//
	// enc := json.NewEncoder(file)
	// for key := ... {
	// 	enc.Encode(KeyValue{key, reduceF(...)})
	// }
	// file.Close()
	//
	// Your code here (Part I).
	//

	// 依次读取中间文件的数据, 写入 kvsMap 中
	kvsMap := make(map[string][]string)
	var kv KeyValue
	for i := 0; i < nMap; i++ {
		f, _ := os.Open(reduceName(jobName, i, reduceTask))
		defer f.Close()
		dec := json.NewDecoder(f)
		for {
			if err := dec.Decode(&kv); err != nil { // 已读完文件
				break
			}
			_, ok := kvsMap[kv.Key]
			if ok {
				kvsMap[kv.Key] = append(kvsMap[kv.Key], kv.Value)
			} else {
				kvsMap[kv.Key] = []string{kv.Value}
			}
		}
	}

	// reduceF() 每个 kvsMap 中的数据, 写入结果文件中
	f, _ := os.Create(outFile)
	defer f.Close()
	enc := json.NewEncoder(f)
	for k, v := range kvsMap {
		enc.Encode(KeyValue{k, reduceF(k, v)})
	}
}
