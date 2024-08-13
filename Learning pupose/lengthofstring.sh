#!/bin/bash
# Create a new string
mystring="lets count the length of this string"
i=${#mystring}
echo "Length: $i"

delimiter=" "
IFS="$delimiter"  read -ra substr <<< $mystring


x=${#substr[@]}  
x=$(($x-1))
echo $x

y=0

while [[ $x > $y ]];
do 
temp=${substr[$y]}
substr[$y]=${substr[$x]}
substr[$x]=$temp
y=$(($y+1))
x=$(($x-1))
done
echo "${substr[@]}"
printf '%s ' "${substr[@]}"
