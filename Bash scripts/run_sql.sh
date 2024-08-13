#!/bin/bash
# Chroot with alationadmin
AlationAdminUser="/usr/bin/sudo /usr/bin/su - alationadmin -c"
# Chroot with alation
AlationUser="/usr/bin/sudo /usr/bin/su - alation -c"
# Chroot with alation psql util
AlationPsqlUtil="alation_pgsql_util run_psql"

CurrentTime=$(date "+%Y.%m.%d-%H.%M.%S")
CurrentContext=$(kubectl config current-context)
Output="output-CurrentContext"-"$CurrentTime".txt
#query=$(cat <<SQL
#select 1 ;
#)
query=$(cat table_size.sql)
ActiveNameSpace=()
AllNameSpaceList=`kubectl get ns | grep -E  "\b[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}\b" | awk '{print $1}'`
echo "cluster_name,tenant_id,base_url,table_name,row_count,table_size" >> $Output
echo "Cluster Name: $CurrentContext"
while IFS= read -r Ns; do
        echo "Tenant ID: $Ns"

        if kubectl -n "$Ns" get deploy alationfc &> /dev/null; then
                url=`kubectl -n $Ns --request-timeout 60s exec deploy/alationfc -c alationfc  --  $AlationAdminUser "alation_conf alation.install.base_url" < /dev/null| cut -d "/" -f3`
                echo "base_url: $url"
                SqlOut=`kubectl -n $Ns --request-timeout 90s exec deploy/alationfc -c alationfc --   $AlationAdminUser "echo \"$query\"  | alation_psql 2>/dev/null" < /dev/null`
                while IFS= read -r Line;do
                   echo "$CurrentContext,$Ns,$url,$Line" >> $Output
                done < <(printf "%s\n" "$SqlOut")

                echo -e "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        else
                echo "Pod alationfc not found in namespace $Ns"
        fi
echo -e "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n"
done < <(printf "%s\n" "$AllNameSpaceList")
