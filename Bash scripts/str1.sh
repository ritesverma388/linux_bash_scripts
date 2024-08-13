while read line; do
{
  mn=$(echo "$line" | awk -F " " '{print$8}'| awk -F "=" '{print$2}')
  if [ "$mn" != \"\" ]; then
    echo $line | awk -F " " '{print $8}'
    echo $line | awk -F " " '{print $2}'
    echo
    fi
}
done < str1.txt

