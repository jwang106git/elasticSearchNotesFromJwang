# query
## query_and fetch
1. coordinating node选择分片，每个主从里随机选择一个，并转发请求
2. 每个分片返回from+size个数据
3. node 获取id列表，合并，再去分片取数据，然后返回

## 相关性算分
lucene是相关性算分的单位，一个分片就是一个完整的lucene

- 算分不同的解决方案
    1.  set 分片数 = 1, using when number of docs is around ten millions or less.
    2. use DFS Query-then-Fetch 拿到所有文档，重新算分、性能低，一般不建议用


## sort doc values field data

```
GET index/_search
{
    "query":{
        "match": {
            "name": "hello"
        }
    },
    "sort": {
        "birth": "desc"
    }
}

GET index/_search
{
    "query":{
        "match": {
            "name": "hello"
        }
    },
    "sort": [
        {   
            "birth": "desc"
        },
        {
            "_score": "desc"
        },
        {
            "_doc": "desc"
        }
    ]
}
```

### text 不能sort 因为分词了 keyword可以sort

