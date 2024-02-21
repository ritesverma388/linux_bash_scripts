# Chroot with alationadmin
AlationAdminUser="/bin/su - alationadmin -c"
# Chroot with alation
AlationUser="/bin/su - alation -c"
# Chroot wihtout specify user
ChrootBase="chroot /opt/alation/alation"
kubectltimeout="600"
#CMD="alation_conf alation.authentication.builtin.enabled"
CMD="Select ocfconfig.ds_id, connector.name as connector_name, textarea.key as param_name, textarea.value as param_value from rosemeta_datasource ds inner join rosemeta_ocfconfiguration ocfconfig on ds.id = ocfconfig.ds_id inner join connector_metadata_connector connector on ocfconfig.connector_id = connector.id inner join connector_metadata_textarea textarea on ocfconfig.connector_configuration_id=textarea.configuration_id where textarea.key in ('custom_qli_query') and textarea.value != '' and textarea.value is not null and ds.deleted = false and connector.name like  '%Oracle OCF%';"
OUTPUT_FILE_NAME=eks-st-CMS-7100.txt



if [ "$#" -lt 1 ]; then
    echo "Error: Please provide the file with space sprated vaules"
    exit 1  # Exit the script with an error status
fi

	
clusterlist="$1"

RunCommand () {
        Region=$1
        Cluster=$2

        echo "$1 $2"
        POD_NAME=$(kubectl get pods | grep "^alationfc" | grep -v ha| grep Running)
        if [ -z "$POD_NAME" ]; then
                echo "alationfc pod not found in $Cluster - $Region."
        else
                echo "restart celery beat"
                Data=$(kubectl --request-timeout $kubectltimeout exec $POD_NAME -c alationfc -- $ChrootBase $AlationUser  "echo \"${query}\" | alation_psql"  < /dev/null )
                if [ -z "$Data" ]; then
                        echo "failed to run the script on $Cluster - $Region - $POD_NAME "
                else
                        #Value=$(echo "$Data"| cut -d "=" -f2)
                        echo "running on $Cluster - $Region  "

                        echo -e "Cluster: $Cluster $Region\n $Data\n ======= \n" >> $OUTPUT_FILE_NAME
                        #echo  "$Data" >> $Region-$Cluster.txt
                fi
        fi
       }



while IFS= read -r line; do
        read -r Region Name <<< "$line"
        aws eks describe-cluster --name $Name --region $Region  | grep "Environment" | grep "prod" > /dev/null
        echo "name $Name --region $Region"
        TAG_STATUS=$?
        if [ $TAG_STATUS -eq 0 ]; then
                aws eks --region $Region update-kubeconfig --name $Name --role-arn arn:aws:iam::118618885326:role/AlationEKSAdminRole
                RunCommand $Region $Name
        else
            echo -e "Cluster is not from PROD Environment"
        fi



done < "$clusterlist"