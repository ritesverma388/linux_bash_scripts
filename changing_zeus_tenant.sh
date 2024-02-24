
#!/bin/bash
​
# Exit on error.
#set -o errexit
# Exit on error inside any functions or subshells.
#set -o errtrace
# Catch the errors eg. in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
#set -o pipefail
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
#set -o nounset
# Turn on traces, useful while debugging but commented out by default
# Turn on if needed for debugging.
#set -o xtrace
#set -e
​
# Chroot with alationadmin
alationadmin_user="/bin/su - alationadmin -c"
# Chroot with alation
alation_user="/bin/su - alation -c"
# Chroot with alation psql util
alation_psql_util="alation_pgsql_util run_psql"
# Chroot with alation
alation_user="/bin/su - alation -c"
# Chroot wihtout specify user
chroot_base="chroot /opt/alation/alation"
​
OUTPUT_FILE_NAME="zeus-bulk-query-output.txt"
​
​
​
​
#query1="SELECT DISTINCT ds.id AS ds_id, title, connector.name FROM rosemeta_datasource ds LEFT JOIN rosemeta_ocfconfiguration conf ON conf.ds_id = ds.id LEFT JOIN connector_metadata_connector connector ON conf.connector_id = connector.id;
"
​
#aws ec2 describe-regions --region eu-west-1 | grep "RegionName" | awk '{ print $2 }' | tr -d '",' > regions.txt
​
​
# for i in `cat regions.txt`; do
#     echo $i
#     aws eks list-clusters --region $i | grep prod | tr -d '",' | tr -d " " > eks-clusters-$i.txt
# done
​
if [[ -f $OUTPUT_FILE_NAME ]]; then
    rm -f $OUTPUT_FILE_NAME
fi

read -p "Please Confirm If Zeus KUBECONFIG Exported [Y/N] :" ZEUS_KUBECONFIG
​
if [ "$ZEUS_KUBECONFIG" = "Y" ]; then
​
    kubectl config get-contexts | grep -E '\bprod' | grep prod-enterprise-use1 | awk '{ print $2 }' > zeus-cluster-contexts.txt
    # ps -ef | grep port-forward | grep kubectl
    # if [ $? -eq 0 ]; then
    #     PROCESS_ID=`ps -ef | grep port-forward | grep kubectl | awk '{ print $2 }'`
    #     kill -9 $PROCESS_ID
    # fi
    # kubectl port-forward service/tenant-resource-catalog 8001:80 &
    # echo -e "\n"
    # sleep 12
    # echo -e "\n Fetching All TENANTS ID in All PROD ZEUS clusters"
    # sleep 6
​
    for i in `cat zeus-cluster-contexts.txt`; do
​
        ps -ef | grep port-forward | grep kubectl
        if [ $? -eq 0 ]; then
            PROCESS_ID=`ps -ef | grep port-forward | grep kubectl | awk '{ print $2 }'`
            kill -9 $PROCESS_ID
        fi
        echo -e "\n Switching Context Name : $i"
        kubectl config use-context $i
        kubectl port-forward service/tenant-resource-catalog 8001:80 &
        echo -e "\n Port Forwarding Configuring ....\n"
        sleep 15
        echo -e "\n Fetching All TENANTS ID in ZEUS cluster - $i\n"
        sleep 6
        echo -e "\n Set Cluster Context to : $i"
        sleep 5
​
        curl -X 'GET' 'http://localhost:8001/resourceSets?status=assigned' -H 'accept: application/json' | jq -r .resource_sets[].tenant_id > $i-tenants-id.txt
​
        for j in `cat $i-tenants-id.txt`;do
            echo "********************************** Tenant-ID: $j *******************************"
            echo -e "\n\n\n"
            kubectl get deployment -n $j | grep "^alationfc"  > /dev/null
            pod_status=$?
            if [ $pod_status -eq 0 ]; then
                echo -e "\n\n**********************  Checking pod Health on $j ********************\n\n"
                kubectl exec -it deploy/alationfc -n $j -- hostname
                pod_health=$?
                if [ $pod_health -ne 0 ]; then
                    echo "$j, exec not working on alationfc, $j"
                else
                    for n in {1..1}; do
                        echo -e "------------------------------------- Tenant iD : $j ------------------------------------- \n"
                        echo -e "\n\n--------------------------------- Tenant iD : $j ------------------------------------- \n" >> $OUTPUT_FILE_NAME
                        result1=$(kubectl exec -it deploy/alationfc -n $j -- chroot /opt/alation/alation /bin/su - alation -c "alation_conf base_url")
                        echo $result1
                        echo -e "$result1" >> $OUTPUT_FILE_NAME
                        host=$(kubectl exec -it deploy/alationfc -n 59c52336-1f68-48c1-a872-3524c802db25 -- chroot /opt/alation/alation /bin/su - alation -c "alation_conf alation_analytics-v2.pgsql.config.host | cut -d '=' -f2 | tr -d '[:space:]'")

                        db=$(kubectl exec -it deploy/alationfc -n 59c52336-1f68-48c1-a872-3524c802db25 -- chroot /opt/alation/alation /bin/su - alation -c "alation_conf alation_analytics-v2.pgsql.config.dbname | cut -d '=' -f2 | tr -d '[:space:]'")

                        user=$(kubectl exec -it deploy/alationfc -n 59c52336-1f68-48c1-a872-3524c802db25 -- chroot /opt/alation/alation /bin/su - alation -c "alation_conf alation_analytics-v2.pgsql.user | cut -d '=' -f2 | tr -d '[:space:]'")

                        pass=$(kubectl exec -it deploy/alationfc -n 59c52336-1f68-48c1-a872-3524c802db25 -- chroot /opt/alation/alation /bin/su - alation -c "alation_conf alation_analytics-v2.pgsql.password | cut -d '=' -f2 | tr -d '[:space:]'")

                        kubectl exec -it deploy/alationfc -n 59c52336-1f68-48c1-a872-3524c802db25 -- chroot /opt/alation/alation /bin/su - alation -c "PGPASSWORD=\"${pass}\" psql -U \"${user}\" -d \"${db}\" -h \"${host}\" -c \"select 1\" -c \"select 1\""
                        
                        echo -e "\n\n================================================================================================\n"
                        echo -e "\n\n================================================================================================\n" >> $OUTPUT_FILE_NAME
                    done
                fi
            fi
        done
    done
fi


#  026c51db-1e43-4274-978f-eb401b2ec893
 
#  kubectl exec -it deploy/alationfc -n 026c51db-1e43-4274-978f-eb401b2ec893 -- chroot /opt/alation/alation /bin/su - alation -c "echo \"${!query1}\" | alation_psql"
 
#  result1=$(kubectl exec -it deploy/alationfc -n $j -- chroot /opt/alation/alation /bin/su - alation -c "alation_conf base_url")

#  ###