# mapping
## 自定义

```
PUT learn_index 
{
  "mappings": {
    "_doc": {  
      "properties": {
        "title": {
          "type": "text"
        },
        "name": {
          "type": "keyword"
        },
        "age": {
          "type": "integer"
        }
      }
    }
    
  }
}
```

- mapping一旦设置好就不能再改了，因为Lucene的倒排索引生成后是不能再改的
- 可以建立新的索引 然后reindex
- 允许新增字段， 通过dynamic来控制新增的方式
	- true（默认），允许自动新增字段
	- false，不允许新增，但允许插入，意味着你不能对这个字段查询
	- strict 文档有其他字段，写入的时候直接报错
	- 一般建议设置为false，定期查看文档，需要时更新mapping，然后reindex老的文档。
	- 可以设置某一个对象的dynamic，比如index设置false，下边的某对象可以为true

## index 参数
```
## index false即不可搜索，用来保护一些敏感的数据
PUT learn_index 
{
  "mappings": {
    "_doc": {  
      "properties": {
        "title": {
          "type": "text"，
          "index_options": "offsets"
        },
        "name": {
          "type": "keyword"
        },
        "age": {
          "type": "integer"
        },
        "cookie": {
          "type": "text",
          "index": false
        }
      }
    }
  }
}

POST learn_index/_doc
{
  "title": "hello",
  "cookie": "hello"
}

GET learn_index/_search
{
  "query": {
    "match": {
      "title": "hello"
    }
  }
}

# 报错
GET learn_index/_search
{
  "query": {
    "match": {
      "cookie": "hello"
    }
  }
}
```

## index option参数
* index option用于控制倒排索引记录的内容，有如下4种配置
	- docs 只记录doc id
	- freqs记录doc id 和 term frequencies （词频，单词在文档里出现的次数，不记录顺序）
	- positions记录doc id、 term frequencies 和 term postion （通常用来距离查询）（term在当前文档中是第几个位置出现的，支持phrase match这种词语的查询，因为词语涉及前后顺序，仅靠词频是没办法match的）
	- offsets 记录doc id、 term frequencies、 term postion和charater offsets（词在文档中出现的开始和结束位置、用于高亮）

* text类型默认配置为postions， 其他默认为docs
* 记录内容多的，空间更大


```
  "index_options": "docs
```


### null_value
以下核心的常用字段都支持：null_value。

- Arrays
- Boolean

- Date

- geo_point

- IP

- Keyword

- Numeric

- point

text 不支持keyword。

```
PUT my-index-000001
{
  "mappings": {
    "properties": {
      "status_code": {
        "type": "keyword"
      },
      "title": {
        "type": "text",
        "fields": {
          "keyword": {
            "type": "keyword",
            "null_value": "NULL"
          }
        }
      }
    }
  }
}
```

### null value

对于 text 类型的字段，实战业务场景下，我们经常会需要同时设置：multi_fields, 将 text 和 keyword 组合设置。

text 类型用于全文检索，keyword用于聚合和排序。

同时，multi_fields 是 Elastic 认证工程师的核心考点之一，大家务必要掌握

todo:
https://blog.csdn.net/laoyang360/article/details/109712672


## 数据类型
### 字符串类型		
- text 类型
    当一个字段是要被全文搜索的，比如Email内容、产品描述，应该使用text类型。设置text类型以后，字段内容会被分析，在生成倒排索引以前，字符串会被分析器分成一个一个词项。text类型的字段不用于排序，很少用于聚合。

- keyword
    类型适用于索引结构化的字段，比如email地址、主机名、状态码和标签。如果字段需要进行过滤(比如查找已发布博客中status属性为published的文章)、排序、聚合。keyword类型的字段只能通过精确值搜索到。


	**需要分词使用text，否则使用keyword**

- 某些字段有text和keyword的原因

	在ElasticSearch 5.x 之后，字符串类型有了重大改动，移除了String类型，而拆分成了两个新类型：“text”类型用于全文搜索，“keyword”类型用于关键词搜索
	
	这就是造成部分字段还会自动生成一个与之对应的“.keyword”字段的原因。

### 数值类型

类型	取值范围

byte	 
short	
integer
short

### date
- 日期格式的字符串，比如 “2018-01-13” 或 “2018-01-13 12:10:30”
- long类型的毫秒数( milliseconds-since-the-epoch，epoch就是指UNIX诞生的UTC时间1970年1月1日0时0分0秒)
- integer的秒数(seconds-since-the-epoch)

### binary
### boolean
true false

### array

* 字符数组: [ “one”, “two” ]
* 整数数组: productid:[ 1, 2 ]
* 对象（文档）数组: “user”:[ { “name”: “Mary”, “age”: 12 }, { “name”: “John”, “age”: 10 }]，
注意：lasticSearch不支持元素为多个数据类型：[ 10, “some string” ]

### object类型
JSON对象，文档会包含嵌套的对象

### ip类型
p类型的字段用于存储IPv4或者IPv6的地址

### 地理位置
 - geo_point
 - geo_shape
 
### 多字段特性 multi-fields
 - 允许对同一个字段采用不同的配置，比如分词，常见例子如对人名实现拼音搜索， 只需要在人名中新增一个子字段为pinyin即可
 
 ```
 {
 	"test_index": {
 		"mappings": {
 		
 	}
 }
 ```



## dynamic templates api


message开头且类型是string的，会被设置为text类型

```
PUT test_index
{
    "mappings": {
        "dynamic_templates": [
        {
            "message_as_text": {
                "match_mapping_type": "string",
                "match": "message",
                "mapping": {
                    "type": "text"
                }
            }
        }
        ]

    }
}
```

double类型会被自动识别为float

```
PUT test_index
{
    "mappings": {
        "dynamic_templates": [
        {
            "message_as_text": {
                "match_mapping_type": "double",
                "match": "message",
                "mapping": {
                    "type": "float"
                }
            }
        }
        ]

    }
}
```
## 安装分词器
以在es6.8.6安装pinyin分词器为例子

1. 先下载文件 [地址](https://github.com/medcl/elasticsearch-analysis-ik )
2. 解压后进入文件夹  elasticsearch-analysis-pinyin-6.x， 修改配置文件
pom.xml，修改  <elasticsearch.version>6.8.6</elasticsearch.version>
3. mvn打包(没有安装maven的自行安装)，运行命令：

    ``mvn package``
    
4.  打包成功以后，会生成一个target文件夹，在elasticsearch-analysis-pinyin-6.x/target/releases目录下，找到elasticsearch-analysis-pinyin-6.8.6.zip，这就是我们需要的安装文件。解压得到下面内容：
```
elasticsearch-analysis-pinyin-6.8.6.jar
nlp-lang-1.7.jar
plugin-descriptor.properties
```
5. 创建文件夹 /usr/local/Cellar/elasticsearch/6.8.6/libexec/plugins/pinyin
并把刚才解压后的文件复制过来
6. 重启es
7. 测试
	```
	curl -X POST "http://localhost:9200/_analyze" -H "Content-Type: application/json"  -d '{"analyzer":"pinyin", "text": "中华人民共和国"}'
	
	{"tokens":[{"token":"zhong","start_offset":0,"end_offset":0,"type":"word","position":0},{"token":"zhrmghg","start_offset":0,"end_offset":0,"type":"word","position":0},{"token":"hua","start_offset":0,"end_offset":0,"type":"word","position":1},{"token":"ren","start_offset":0,"end_offset":0,"type":"word","position":2},{"token":"min","start_offset":0,"end_offset":0,"type":"word","position":3},{"token":"gong","start_offset":0,"end_offset":0,"type":"word","position":4},{"token":"he","start_offset":0,"end_offset":0,"type":"word","position":5},{"token":"guo","start_offset":0,"end_offset":0,"type":"word","position":6}]}
	```
	
## 索引模版
提前定义一批模版的mapping
比如test开头的