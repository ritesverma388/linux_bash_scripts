#                             Online Bash Shell.
#                 Code, Compile, Run and Debug Bash script online.
# Write your code in this editor and press "Run" button to execute it.


str="Hello world"


IFS=" "
read -ra array<<< "$str"

echo ${array[@]}


len=${#array[@]}
declare -a my_arr

echo $len

for (( i=$((len-1)),j=0; i>=0, j<=$((len-1)); i--, j++ ))
do
    my_arr[$j]=${array[$i]}
#   rev_string="$rev_string${str:$i:1}"
done

echo ${my_arr[@]}
printf "%s " "${my_arr[@]}"
