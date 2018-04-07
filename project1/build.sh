#!/bin/bash

echo "Compiling and running ParseJSON.java"
javac ParseJSON.java
echo ""

# Helper function to test each of the tests with the given words
testTask() {
	echo ""
	echo "Running test for $1 ..."
	testCaseWords=( "information%20retrieval" "the%20matrix" "algebra" "elasticity" "elizabeth" "April%205" "wrestler" )
	printf "%-30s%s\n" "Query" "#_of_matching_documents"
	echo "-----------------------------------------------------"
	for word in "${testCaseWords[@]}"; do
		count=$(curl -s -XGET "localhost:9200/$1/_search?q=$word&pretty"| grep "total" | head -2 | tail -1 | awk '{print $3}' | sed -e 's/,//g')
		printf "%-30s%s\n" "$word" "$count"
	done

}

# TASK 2A:
# Create and index the documents using the default standard analyzer
echo "2A. Creating/indexing the documents"
taskName="task2a"
outputFile="data/$taskName.txt"
java ParseJSON "$taskName" "$outputFile"
echo ""
curl -XPOST 'localhost:9200/_bulk?pretty' --data-binary @"$outputFile"  > /dev/null
testTask "task2a"

# TASK 2B:
# Create and index with a whitespace analyzer
echo ""
echo "2B. Creating/indexing w/ whitespace analyzer"
taskName="task2b"
outputFile="data/$taskName.txt"
echo ""
curl -XPUT 'localhost:9200/task2b?pretty' -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "wikipage" : {
      "_all" : {
        "type" : "string", 
        "analyzer" : "whitespace"
        },
      "properties" : {
        "abstract" : {
          "type" :    "string",
          "analyzer": "whitespace"
        },
        "title" : {
          "type" :   "string",
          "analyzer": "whitespace"
        },
        "url": {
          "type" :   "string",
          "analyzer": "whitespace"
        },
        "sections": {
          "type" :   "string",
          "analyzer": "whitespace"
        }
      }
    }
  }
}
'  > /dev/null
java ParseJSON "$taskName" "$outputFile"
curl -XPOST 'localhost:9200/_bulk?pretty' --data-binary @"$outputFile"  > /dev/null
testTask "task2b"

# TASK 2C:
# Create and index with a custom analyzer as specified in Task 2C
echo ""
echo "2C. Creating/indexing w/ custom analyzer"
taskName="task2c"
outputFile="data/$taskName.txt"
echo ""
curl -XPUT 'localhost:9200/task2c?pretty' -H 'Content-Type: application/json' -d'
{
    "settings": {
        "analysis": {
            "analyzer": {
                "my_analyzer": {
                    "type":         "custom",
                    "char_filter":  "html_strip",
                    "tokenizer":    "standard",
                    "filter":       [ "asciifolding", "lowercase", "stop", "snowball"]
            		}
            }
				}
		},
	 	"mappings": {
	 			"wikipage" : {
		   			"_all" : {
		     			"type" : "string", 
		     			"analyzer" : "my_analyzer"
		   			},
			      "properties" : {
			        "abstract" : {
			          "type" :    "string",
			          "analyzer": "my_analyzer"
			        },
			        "title" : {
			          "type" :   "string",
			          "analyzer": "my_analyzer"
			        },
			        "url": {
			          "type" :   "string",
			          "analyzer": "my_analyzer"
			        },
			        "sections": {
			          "type" :   "string",
			          "analyzer": "my_analyzer"
			        }
			      }
	   		}
    }
}
' > /dev/null

java ParseJSON "$taskName" "$outputFile"
curl -XPOST 'localhost:9200/_bulk?pretty' --data-binary @"$outputFile"  > /dev/null
testTask "task2c"

