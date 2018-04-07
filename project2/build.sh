#!/bin/bash

# start the service by running "sudo service elasticsearch start"

# In case you use the provided ParseJSON.java code for preprocessing the wikipedia dataset, 
# uncomment the following two commands to compile and execute your modified code in this script.
#
javac ParseJSON.java

# TASK 1A:
# Create index "task1a" with "wikipage" type using BM25Similarity
taskName="task1a"
outputFile="data/$taskName.txt"
java ParseJSON $taskName $outputFile
curl -XPOST 'localhost:9200/_bulk?pretty' --data-binary @"$outputFile"  > /dev/null

# TASK 1B:
# Create index "task1b" with "wikipage" type using ClassicSimilarity (Lucene's version of TFIDF implementation)
taskName="task1b"
outputFile="data/$taskName.txt"
curl -XPUT 'localhost:9200/task1b?pretty' -H 'Content-Type: application/json' -d'
{
    "settings": {
        "index": {
          "similarity": {
            "default": {
              "type": "classic"
            }
          }
        }
    }
}
' > /dev/null
java ParseJSON $taskName $outputFile
curl -XPOST 'localhost:9200/_bulk?pretty' --data-binary @"$outputFile"  > /dev/null

# TASK 2:
# Create index "task2" with "wikipage" type using BM25Similarity with the best k1 and b values that you found
# taskName="task2"
# outputFile="data/$taskName.txt"
# java ParseJSON $taskName $outputFile

# k1_list="0.00 0.80 1.20 1.60 2.00"
# b_list="0.00 0.25 0.50 0.75 1.00"

# best_precision=0.0000
# optimal_k1=0.00
# optimal_b=0.00
# curl -XDELETE "localhost:9200/"$taskName"?pretty" > /dev/null
# for k1 in $k1_list; do
#     for b in $b_list; do
#     	echo "k1= $k1, b= $b"
#     	curl -XDELETE "localhost:9200/"$taskName"?pretty" > /dev/null
#       curl -XPUT "localhost:9200/"$taskName"?pretty" -H 'Content-Type: application/json' -d "
#       {
#           \"settings\": {
#               \"similarity\" : {
#                   \"default\" : {
#                       \"type\" : \"BM25\",
#                       \"k1\" : "$k1",
#                       \"b\" : "$b"
#                   }
#               }
#           },
# 				 	\"mappings\": {
# 				 			\"wikipage\" : {
# 						      \"properties\" : {
# 						        \"clicks\": {
# 						          \"type\" :   \"long\"
# 						        },
# 						        \"abstract\" : {
# 						          \"type\" :    \"text\",
# 			                \"similarity\": \"BM25\"
# 						        },
# 						        \"title\" : {
# 						          \"type\" :   \"text\",
# 			                \"similarity\": \"BM25\"
# 						        },
# 						        \"url\": {
# 						          \"type\" :   \"text\",
# 			                \"similarity\": \"BM25\"
# 						        },
# 						        \"sections\": {
# 						          \"type\" :   \"text\",
# 			                \"similarity\": \"BM25\"
# 						        }
# 						      }
# 				   		}
# 			    }
#       }
#       " > /dev/null
#       curl -XPOST 'localhost:9200/_bulk?pretty' --data-binary @"$outputFile"  > /dev/null
#       x=$(./benchmark.sh $taskName | awk '{print $3}')
#       echo "k1:$k1, b:$b, precision@10: $x"
#       if [[ $x > $best_precision ]]; then
#         best_precision=$x
#         optimal_k1=$k1
#         optimal_b=$b
#       fi
#     done
# done
# echo "k1=$optimal_k1, b=$optimal_b best optimizes precision@10 to $best_precision"

# Set task2 index to the actual optimal values
# (Assuming the above search for k1 & b is done)
taskName="task2"
outputFile="data/$taskName.txt"
java ParseJSON $taskName $outputFile
optimal_k1=0.80
optimal_b=0.50
curl -XDELETE "localhost:9200/"$taskName"?pretty" > /dev/null
curl -XPUT "localhost:9200/"$taskName"?pretty" -H 'Content-Type: application/json' -d "
{
    \"settings\": {
        \"similarity\" : {
            \"default\" : {
                \"type\" : \"BM25\",
                \"k1\" : "$optimal_k1",
                \"b\" : "$optimal_b"
            }
        }
    },
	 	\"mappings\": {
	 			\"wikipage\" : {
			      \"properties\" : {
			        \"clicks\": {
			          \"type\" :   \"long\"
			        },
			        \"abstract\" : {
			          \"type\" :    \"text\",
                \"similarity\": \"BM25\"
			        },
			        \"title\" : {
			          \"type\" :   \"text\",
                \"similarity\": \"BM25\"
			        },
			        \"url\": {
			          \"type\" :   \"text\",
                \"similarity\": \"BM25\"
			        },
			        \"sections\": {
			          \"type\" :   \"text\",
                \"similarity\": \"BM25\"
			        }
			      }
	   		}
    }
}
" > /dev/null
curl -XPOST 'localhost:9200/_bulk?pretty' --data-binary @"$outputFile"  > /dev/null

# Task 3:
# Create index "task3" with "wikipage"
taskName="task3b"
outputFile="data/$taskName.txt"
java ParseJSON $taskName $outputFile
curl -XPUT 'localhost:9200/task3b?pretty' -H 'Content-Type: application/json' -d'
{
    "settings": {
        "index": {
          "similarity": {
            "default": {
              "type": "cs246-similarity"
            }
          }
        }
    },
	 	"mappings": {
	 			"wikipage" : {
			      "properties" : {
			        "clicks": {
			          "type" :   "long",
          			"index":   "not_analyzed"
			        },
			        "abstract" : {
			          "type" :    "text"
			        },
			        "title" : {
			          "type" :   "text"
			        },
			        "url": {
			          "type" :   "text"
			        },
			        "sections": {
			          "type" :   "text"
			        }
			      }
	   		}
    }
}
'
curl -XPOST 'localhost:9200/_bulk?pretty' --data-binary @"$outputFile"  > /dev/null