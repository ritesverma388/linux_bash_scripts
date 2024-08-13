#!/bin/bash

# Define the input string
string="This is a string."

# Define the delimiter
delimiter=" "

# Use the delimiter to split the input string into substrings
IFS="$delimiter" read -ra substrings <<< "$string"

# Iterate over each substring and extract the first character
for substring in "${substrings[@]}"; do
   first_char="${substring:0:2}"
   echo "$first_char"
done