# 分词器 Analyzer

## 分词器
**es里专门处理分词的组件，英文 Analyzer**

1. Character Filters
   - 针对原始文本进行处理，比如出去html特殊标记符
- Tokenizer
   - 将原市文本按照规则切分为单词
- Token Filters
   - 单词再加工， 转小写、删除、新增等


## Analyze API
### 测试分词的api接口，方便验证分词效果，endpoint是_analyze
  - 可以指定analyzer
  - 可以指定索引中的字段
  - 可以自定义分词器

1. 指定分词器

	```
	POST _analyze
	{
	  "analyzer": "standard",
	  "text": "Hello world"
	}
	```
2. 指定索引中的字段
	
	```
	POST blogs/_analyze
	{
	  "field": "body",
	  "text": "今天是个好日子"
	}
	```
	
3. 自定义分词器
		
	```
	POST _analyze
	{
	  "tokenizer": "standard",
	  "filter": ["lowercase"],
	  "text": "Hello World"
	}
		
	POST _analyze
	{
	  "tokenizer": "keyword",
	  "text": "Hello World"
	}
		
	POST _analyze
	{
	    "analyzer": "ik_max_word",
	    "text": "上海自来水来自海上"
	}
		
	POST _analyze
	{
	    "analyzer": "standard",
	    "text": "上海自来水来自海上"
	}
		
	POST _analyze
	{
	    "analyzer": "ik_smart",
	    "text": "上海自来水来自海上"
	}
	```

### 下载中文分词器ik
* 下载分词器 [github地址](https://github.com/medcl/elasticsearch-analysis-ik/releases)
* 注意分词器版本必须与es版本一致, 查看es版本： ``curl -XGET localhost:9200``
* 解压后把整个文件夹放到es的plugin下，我的路径是 /usr/local/Cellar/elasticsearch/6.8.6/libexec/plugins