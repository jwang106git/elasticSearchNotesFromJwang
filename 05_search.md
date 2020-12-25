# Search API

## 基本用法

```
GET /_search
GET /my_index/_search
GET /my_index1,my_index_2/_search
GET /my_*/_search
```

## 两种查询
### URI Search
    - 简单
    - 仅包含部分

### Query DSL
* 基于JSON定义的查询语言，主要包括：
	- 字段类查询
		- 如 term、 match、range等，针对某一个字段进行查询
		- term针对词 match针对全文检索 range做范围查询
	- 复合查询
		- 如bool查询，对一个活多个字段类查询或者复合查询


## Query DSL
### 字段类查询
1. 全文检索
	* 针对text类型的字段进行全文检索，会对查询语句先进行分词处理，如match， match_phrase等query类型
2. 单词匹配
	* 不会对查询语句做分词处理，直接拿着查询语句的内容去匹配字段的倒排索引，如term，terms，range等query类型

### Match Query
```
GET index/_search
{
	"query": {
		"match": {   // 关键词
			"name": "test"   // 字段名： 待查询语句
		}
	}
}
```

### copy_to

```
DELETE /blogs_completion
PUT /blogs_completion
{
  "settings": {
    "number_of_shards": 2
  }, 
  "mappings": {
    "tech": {
      "properties": {
        "body": {
          "type": "keyword",
          "copy_to": ["body_completion", "body_text"]
        },
        "body_completion": {
          "type": "completion"
        },
        "body_text": {
          "type": "text",
          "analyzer": "ik_smart"
        }
        
      }
    }
  }
}




POST _bulk/?refresh=true
{ "index" : { "_index" : "blogs_completion", "_type" : "tech" } }
{ "body": "春天花会开"}
{ "index" : { "_index" : "blogs_completion", "_type" : "tech" } }
{ "body": "春天里的故事"}
{ "index" : { "_index" : "blogs_completion", "_type" : "tech" } }
{ "body": "在春天里"}
{ "index" : { "_index" : "blogs_completion", "_type" : "tech" } }
{ "body": "春天是"}
{ "index" : { "_index" : "blogs_completion", "_type" : "tech" } }
{ "body": "一个春天的故事"}
{ "index" : { "_index" : "blogs_completion", "_type" : "tech" } }
{ "body": "哈哈哈哈"}


# keyword必须是一模一样
GET blogs_completion/_search 
{
   "profile": true,
  "query" : {
    "match": {
      "body": "春天是" 
    }
  }
}

GET blogs_completion/_search 
{
   "profile": true,
  "query" : {
    "match": {
      "body_text": "春天"
    }
  }
}

POST blogs_completion/_search?pretty
{ 
  "size": 6,
  "suggest": {
    "blog-suggest": {
      "prefix": "春天",
      "completion": {
        "field": "body_completion"
      }
    }
  }
}
```
		
 ### And
 
 ```
 GET blogs_completion/_search 
{
  "profile": true,
  "query" : {
    "match": {
      "body_text": {
        "query": "春天 是",
        "operator": "and"
      }
    }
  }
}
 ```
 
### minimum_should_match
```
 GET blogs_completion/_search 
{
  "profile": true,
  "query" : {
    "match": {
      "body_text": {
        "query": "春天 好听  故事",
        "minimum_should_match": 3
      }
    }
  }
}
```

## 相关性算分
* 相关性算分指的是文档与查询语句之间的相关度， 英文 relevance
* 如何查询最符合用户查询的文档
* 本质是排序问题
* 重要概念
	- Term Frequency(TF) 词频 单词在文档中出现的次数
	- Document Frequency（DF） 文档频率，即单词出现的文档数
	- Inverse  Document Frequency（IDF）逆向文档频率， 简单理解成 1/DF， 单词在总文档集出现的次数越少，相关度越高
	- Field Length Norm， 文档越短，相关性越高

##  Match Phrase Query
* 对字段做检索，有顺序要求

```
GET index/_search
{
	"query": {
		"match_phrase": {
			"body": "春天 故事"
		}
	}
}

# 改顺序 查不到
GET index/_search
{
	"query": {
		"match_phrase": {
			"body": "故事 春天"
		}
	}
}

# 改成match 查得到
GET index/_search
{
	"query": {
		"match": {
			"body": "故事 春天"
		}
	}
}
```

## Query String Query
* 类似于URI Search中的q参数
```
GET index/_search
{
	"query": {
		"query_string": {
			"default_field": "body",
			"query": "春天 AND 故事"
		}
	}
}
```

## Simple Query String Query

不使用AND OR NOT 改成 + ｜ - 
AND OR NOT几个符合会被识别为字符串

## Term Query ｜ Terms Query
* 将查询语句作为整个单词进行查询，即不对查询语句做分词处理，如下
* 下边是查询“一个春天”， 查不到的。 因为虽然有“一个春天的故事”这条数据，但是倒排索引拆成了“一个“、春天、故事， 没有“一个春天”这个索引

```
GET blogs_completion/_search 
{
  "profile": true,
  "query" : {
    "term": {
      "body_text": "一个春天"
    }
  }
}
```

* terms query

```
GET blogs_completion/_search 
{
  "profile": true,
  "query" : {
    "terms": {
      "body_text": [
        "一个",
        "春天"
        ]
    }
  }
}
```


## Range Query
* int range

	```
	GET xng_user_0/_search
	{
		"query": {
			"range": {
				"age": {
					"gte": 10,
					"lte": 20
				}
			}
		}
	}
	```

* date range

```
GET xng_user_0/_search
{
	"query": {
		"range": {
			"birth": {
				"gte": "2020-01-01",
			}
		}
	}
}

GET xng_user_0/_search
{
	"query": {
		"range": {
			"birth": {
				"gte": "now-20y",
			}
		}
	}
}
```

### date math
now = "2020-01-02 12:00:00"
now+1h        13:00
now-1h        11:00
now-1h/d  按日期取整， 0 点
2016-01-01||+1M/d 2016-02-01 00:00:00
直接用日期字符串 要加双竖线

## Query DSL 复合查询
- constant_score query
- bool query
- dis_max query
- function_score query
- boosting query 

### const score query
* 把查询结果文档得分都设定为1或者boost的值
	- 多用于结合bool查询实现自定义得分

```
关键词constant_score
指定一个，只能有一个filter，
最后score 都是1 

GET blogs_completion/_search 
{
  "profile": true,
  "query" : {
    "constant_score": {
      "filter": {
        "match": {
          "body_text": "春天"
        }
      }
    }
  }
}
```


### bool 查询
* filter查询只过滤符合条件的文档，不会进行相关性算分
* es对filter查询会智能缓存，因此效率很高
* 做假单查询，不考虑算分时，推荐使用filter替代query


```
会查出来数据 但score都是0
GET blogs_completion/_search 
{
  "profile": true,
  "query" : {
    "bool": {
      "filter": {
        "match": {
          "body_text": "春天"
        }
      }
    }
  }
}
```

### must 把多个查询分数加起来

### should
* 文档必须满足至少一个条件
* minimum_should_match可以控制满足条件的个数或者百分比

```
GET blogs_completion/_search 
{
  "profile": true,
  "query" : {
    "bool": {
      "should": [
        {
          "term": {
            "body_text": "春天"
          }
        },
        {
          "term": {
            "body_text": "故事"
          }
        }
      ],
      "minimum_should_match": 2
    }
  }
}
```

* 同时包含should和must时，不必满足should中的条件，但是如果满足条件，会增加相关性得分
* 可以使用minimum_should_match要求至少满足一个should的条件
```
# should must同时存在
GET blogs_completion/_search 
{
  "profile": true,
  "query" : {
    "bool": {
      "should": [
        {
          "term": {
            "body_text": "春天"
          }
        }
      ],
      "minimum_should_match": 1,
      "must": [
        {
          "term": {
            "body_text": "故事"
          }
        }
      ]
    }
  }
}
```

## query context VS filter context
query : 查询、相关性算分并排序，bool中的must should
filter: 查找匹配的文档，bool中的filter与must_not constant_score 中的filter


## Count API
* 获取符合条件的文档数
*  只返回数量，没有其他信息
```
GET blogs_completion/_count
{
  "query": {
    "match": {
      "body_text": "故事"
    }
  }
}
```

## Source Filtering
```
GET  plp_filter_music/_search
{
  "query": {
    "match": {
      "name": "周"
    }
  },
  "_source": ["name", "qid"]
}

# 不返回source
GET  plp_filter_music/_search
{
  "query": {
    "match": {
      "name": "周"
    }
  },
  "_source": false
}


GET  plp_filter_music/_search
{
  "query": {
    "match": {
      "name": "周"
    }
  },
  "_source": {
    "includes": "*ng*"
  }
}
```