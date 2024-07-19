#!/bin/bash

# Define an array
input_array=("apple" "banana" "cherry" "date")

# Loop through the array and extract the first character of each element
for element in "${input_array[@]}"; do
   first_char="${element:0:1}"
   echo "$first_char"
done