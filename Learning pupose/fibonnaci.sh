#!/bin/bash
echo "Enter the number: "
read num
n1=0
n2=1
echo "$n1 $n2"
for ((i=1; i<=(($num-2)); i++));
do 
   temp=$(($n1+$n2))
   echo $temp
   n1=$n2
   n2=$temp
done


