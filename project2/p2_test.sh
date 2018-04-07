#!/bin/bash

queries=( "information%20retrieval" "the%20matrix" "algebra" "elasticity" "elizabeth" )
TMP_DIR=/tmp/project2/
REQUIRED_FILES="build.sh build.gradle install-plugin.sh task3a.sh"

task3a='"max_score" : 89.30481,
        "_score" : 89.30481,
        "_score" : 86.686066,
        "_score" : 86.29083,
        "_score" : 86.09051,
        "_score" : 85.67467,
        "_score" : 85.61694,
        "_score" : 84.22537,
        "_score" : 83.28606,
        "_score" : 82.99002,
        "_score" : 80.8033,
    "max_score" : 40.151104,
        "_score" : 40.151104,
        "_score" : 38.99555,
        "_score" : 38.77317,
        "_score" : 38.37591,
        "_score" : 36.38686,
        "_score" : 36.263447,
        "_score" : 36.263447,
        "_score" : 36.249115,
        "_score" : 36.196007,
        "_score" : 36.13217,
    "max_score" : 91.52402,
        "_score" : 91.52402,
        "_score" : 90.47272,
        "_score" : 75.96907,
        "_score" : 71.13267,
    "max_score" : 140.12831,
        "_score" : 140.12831,
        "_score" : 100.34806,
        "_score" : 77.94006,
    "max_score" : 98.82846,
        "_score" : 98.82846,
        "_score" : 81.944954,
        "_score" : 79.832344,
        "_score" : 79.41739,
        "_score" : 78.47116,
        "_score" : 78.304855,
        "_score" : 78.25241,
        "_score" : 78.155525,
        "_score" : 77.41552,
        "_score" : 77.25188,'

# usage
if [ $# -ne 1 ]
then
     echo "Usage: $0 project1.zip" 
     exit
fi

if [ `hostname` != "cs246" ]; then
     echo "ERROR: You need to run this script within the class virtual machine" 
     exit
fi

ZIP_FILE=$1

# clean any existing files
rm -rf ${TMP_DIR}
mkdir ${TMP_DIR}

# unzip the submission zip file 
if [ ! -f ${ZIP_FILE} ]; then
    echo "ERROR: Cannot find $ZIP_FILE" 
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
        echo "ERROR: Cannot find ${FILE} in the root folder of your zip file" 
    fi
done

mkdir data

echo "Getting files..."
curl -s "http://oak.cs.ucla.edu/classes/cs246/projects/project2/simplewiki-abstract.json" > data/simplewiki-abstract.json
curl -s "http://oak.cs.ucla.edu/classes/cs246/projects/project2/benchmark.txt" > data/benchmark.txt
curl -s "http://oak.cs.ucla.edu/classes/cs246/projects/project2/benchmark.sh" > benchmark.sh

echo "Deleting any old indexes..."

curl -s -XDELETE 'localhost:9200/*?pretty' &> /dev/null


echo
echo "Running gradle assemble..."

gradle assemble 

if [ $? -eq 0 ]
then
    echo "SUCCESS!!"
else
    echo "Error: Gradle build FAILED."
    rm -rf ${TMP_DIR}
    exit 1
fi

echo "Installing plugin..."
PLUGINS=`/usr/share/elasticsearch/bin/elasticsearch-plugin list`
for PLUGIN in ${PLUGINS}
do
    echo "password" | sudo -S /usr/share/elasticsearch/bin/elasticsearch-plugin remove ${PLUGIN}
done

chmod +x install-plugin.sh
echo "password" | sudo -S ./install-plugin.sh

echo "Waiting for elasticsearch to restart..."
for i in `seq 1 180`;
do
    curl -s 'localhost:9200' &> /dev/null
    if [ $? -eq 0 ]; then
        break;
    else
        sleep 1;
    fi
done
curl -s 'localhost:9200' &> /dev/null
if [ $? -ne 0 ]; then
    echo "Error: Elasticsearech is not responding for 3 minutes."
    rm -rf ${TMP_DIR}
    exit 1
fi

echo "Running build.sh..."
chmod +x build.sh

./build.sh &> /dev/null
curl -s -XPOST 'localhost:9200/_flush?pretty' > /dev/null

chmod +x benchmark.sh

echo
echo "Testing task1a..."
./benchmark.sh task1a | grep Average | grep 0.2551 &> /dev/null 

if [ $? -eq 0 ]
then
    echo "SUCCESS!!"
else
    echo "Error: Results from task1a are incorrect."
    rm -rf ${TMP_DIR}
    exit 1
fi

echo
echo "Testing task1b..."
./benchmark.sh task1b | grep Average | grep 0.2579 &> /dev/null 

if [ $? -eq 0 ]
then
    echo "SUCCESS!!"
else
    echo "Error: Results from task1b are incorrect."
    rm -rf ${TMP_DIR}
    exit 1
fi

echo
echo "Testing task2..."
./benchmark.sh task2 | grep Average | grep 0.2569 &> /dev/null

if [ $? -eq 0 ]
then
    echo "SUCCESS!!"
else
    echo "Error: Task 2 parameters are not optimal."
    rm -rf ${TMP_DIR}
    exit 1
fi

chmod +x task3a.sh 

echo
echo "Testing task3a..."
for query in "${queries[@]}"
do
    ./task3a.sh $query | grep score &>> task3a.txt
done

diff -w task3a.txt <(echo "$task3a") &> /dev/null
if [ $? -eq 0 ]
then
    echo "SUCCESS!"
else
    echo "ERROR: Query rankings from task3a incorrect."
    rm -rf ${TMP_DIR}
    exit 1 
fi


echo 
echo "Testing task3b..."

./benchmark.sh task3b | grep Average | grep 0.2227 &> /dev/null

if [ $? -eq 0 ]
then
    echo "SUCCESS!!"
else
    echo "Error: Results from task3b are incorrect."
    rm -rf ${TMP_DIR}
    exit 1
fi

# clean up
rm -rf ${TMP_DIR}
exit 0
