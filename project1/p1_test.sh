#!/bin/bash

queries=( "information%20retrieval" "the%20matrix" "algebra" "elasticity" "elizabeth" "April%205" "wrestler" )
TMP_DIR=/tmp/p1grading/
REQUIRED_FILES="GetWebpage.java build.sh task3.txt"

task2a=' "count" : 502,
  "count" : 69559,
  "count" : 55,
  "count" : 9,
  "count" : 202,
  "count" : 3487,
  "count" : 85,'

task2b=' "count" : 343,
  "count" : 62496,
  "count" : 26,
  "count" : 3,
  "count" : 0,
  "count" : 2635,
  "count" : 21,'

task2c=' "count" : 788,
  "count" : 25,
  "count" : 74,
  "count" : 23,
  "count" : 203,
  "count" : 3487,
  "count" : 111,'
# usage
if [ $# -ne 1 ]
then
     echo "Usage: $0 project1.zip" 1>&2
     exit
fi

if [ `hostname` != "cs246" ]; then
     echo "ERROR: You need to run this script within the class virtual machine" 1>&2
     exit
fi

ZIP_FILE=$1

# clean any existing files
rm -rf ${TMP_DIR}
mkdir ${TMP_DIR}

# unzip the submission zip file 
if [ ! -f ${ZIP_FILE} ]; then
    echo "ERROR: Cannot find $ZIP_FILE" 1>&2
    rm -rf ${TMP_DIR}
    exit 1
fi
unzip -q -d ${TMP_DIR} ${ZIP_FILE}
if [ "$?" -ne "0" ]; then 
    echo "ERROR: Cannot unzip ${ZIP_FILE} to ${TMP_DIR}"
    rm -rf ${TMP_DIR}
    exit 1
fi

# change directory to the grading folder
cd ${TMP_DIR}

# check the existence of the required files
for FILE in ${REQUIRED_FILES}
do
    if [ ! -f ${FILE} ]; then
        echo "ERROR: Cannot find ${FILE} in the root folder of your zip file" 1>&2
        rm -rf ${TMP_DIR}
        exit 1
    fi
done

echo "Compiling GetWebpage.java..."

javac GetWebpage.java
if [ "$?" -ne "0" ] 
then
    echo "ERROR: Compilation of GetWebpage.java failed" 1>&2
    rm -rf ${TMP_DIR}
    exit 1
fi

echo "Testing GetWebpage.java..."
java GetWebpage http://stackoverflow.com > result1.txt
curl -s http://stackoverflow.com > result2.txt

diff -w result1.txt result2.txt > /dev/null

if [ $? -eq 0 ]
then
    echo "SUCCESS!" 1>&2
else
    echo "ERROR: GetWebpage didn't print the right page." 1>&2
    rm -rf ${TMP_DIR}
    exit 1
fi


mkdir data

echo
echo "Running build.sh..."
curl -s "http://oak.cs.ucla.edu/classes/cs246/projects/simplewiki-abstract.json" > data/simplewiki-abstract.json
curl -s -XDELETE 'localhost:9200/*?pretty' > /dev/null
chmod a+rx ./build.sh
./build.sh > /dev/null

curl -s -XPOST 'localhost:9200/_refresh?pretty' > /dev/null

echo
echo "Testing Task2A..."
for query in "${queries[@]}"
do
    curl -s -XGET "localhost:9200/task2a/_count?q=$query&pretty" | grep count >> task2a.txt
done

diff -w task2a.txt <(echo "$task2a") > /dev/null
if [ $? -eq 0 ]
then
    echo "SUCCESS!" 1>&2
else
    echo "ERROR: Query results from task2a incorrect." 1>&2
    rm -rf ${TMP_DIR}
    exit 1
fi


echo
echo "Testing Task2B..."
for query in "${queries[@]}"
do
    curl -s -XGET "localhost:9200/task2b/_count?q=$query&pretty" | grep count >> task2b.txt
done

diff -w task2b.txt <(echo "$task2b") > /dev/null
if [ $? -eq 0 ]
then
    echo "SUCCESS!" 1>&2
else
    echo "ERROR: Query results from task2b incorrect." 1>&2
    rm -rf ${TMP_DIR}
    exit 1
fi

echo
echo "Testing Task2C..."
for query in "${queries[@]}"
do
    curl -s -XGET "localhost:9200/task2c/_count?q=$query&pretty" | grep count >> task2c.txt
done

diff -w task2c.txt <(echo "$task2c") > /dev/null
if [ $? -eq 0 ]
then
    echo "SUCCESS!" 1>&2
else
    echo "ERROR: Query results from task2c incorrect." 1>&2
    rm -rf ${TMP_DIR}
    exit 1
fi

# clean up
rm -rf ${TMP_DIR}
exit 0