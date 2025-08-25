package kv

func GetKeys(indexer BlockerIndexer) [][]byte {

	var keys [][]byte

	itr, err := indexer.store.Iterator(nil, nil)
	if err != nil {
		panic(err)
	}
	defer itr.Close()
	for ; itr.Valid(); itr.Next() {
		keys = append(keys, itr.Key())
	}
	return keys
}
