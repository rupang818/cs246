#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "usage: task2.sh <corpus dir> <number of topics>"
    exit 1
fi

INPUT_DIR="$1"  # Dir may have spaces
NUM_TOPICS=$2

# 
# TODO: The current code just prints out what it is supposed to do
#       Replace the following echo statements with your code
#
# echo "This script should read files in $INPUT_DIR, perform LDA with $2 topics, and create two output files:"
# echo '  topic-words.txt: "topic-keys" file (topic number followed by top-20 associated words)'
# echo '  doc-topics.txt: "doc-topics" file (document # and filename followed by the topic probabilities)'

input_topic="$(basename $INPUT_DIR)"
output_mallet="$input_topic.mallet"

mallet import-dir --input $INPUT_DIR --output $output_mallet --keep-sequence --remove-stopwords
mallet train-topics --input $output_mallet --num-topics $NUM_TOPICS --output-topic-keys topic-words.txt --output-doc-topics doc-topics.txt
rm $output_mallet # cleanup .mallet file