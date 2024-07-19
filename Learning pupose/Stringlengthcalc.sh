x=$1
y=$2
echo $x
count=0
hamming_distance() {
if [ -n "${x}" ] && [ -n "${y}" ]; then
   if [ ${#x} != ${#y} ]; then
        echo "string must be equal"
    else
        for ((i=0; i<${#x}; i++)); do
           if [ "${x:$i:1}" == "${y:$i:1}" ]; then
               count=$(($count+1))
            fi
        done
        echo $count
    fi
else
        echo "0"
fi
}

hamming_distance