old_ifs="$IFS"
IFS="$IFS="
while read LINE
  do  
        read _ NAME _ TYPE _ SIZE _ OWNER _ GROUP _ MODE _ PKNAME _ MOUNTPOINT
        
         if [ "$MOUNTPOINT" ]
           then  echo -e "Mountpoint:$MOUNTPOINT \n Type:$TYPE"
         fi
        
  done < str1.txt