# Chroot with alationadmin
AlationAdmin_User="/bin/su - alationadmin -c"
AlationAdminUser="/usr/bin/sudo /usr/bin/su - alationadmin -c"
# Chroot with alation
AlationUser="/bin/su - alation -c"
# Chroot wihtout specify user
ChrootBase="chroot /opt/alation/alation"
kubectltimeout="600"
#CMD="alation_conf alation.authentication.builtin.enabled"
query="Select ds_id, title, db_type, connector_name, connector_version, max(job_start_time) as latest_MDE_start_time from
    (select distinct(ds.id) as ds_id,title,
                    dbtype as db_type,
                    connector_version,
                    CASE WHEN dbtype='ocf' THEN
                             connector.name
                         ELSE
                             dbtype
                        END connector_name,
                    ts_started as job_start_time
     from rosemeta_datasource ds inner join jobs_job job on job.external_service_aid=ds.id
                                 left join rosemeta_ocfconfiguration conf on conf.ds_id = ds.id
                                 left join connector_metadata_connector connector on conf.connector_id = connector.id
     where ds.deleted = False and job.job_type=0 and job.status=1 order by ds.id asc, job_start_time desc) as result
group by result.ds_id,result.title,db_type,connector_name,connector_version order by ds_id;"
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
                if [ $? -ne 1 ];then
                Data=$(kubectl --request-timeout $kubectltimeout exec $POD_NAME -c alationfc -- $ChrootBase $AAlationAdmin_User  "echo \"${query}\" | alation_psql"  < /dev/null )
                fi
                if [ -z "$Data" ]; then
                        echo "failed to run the script on $Cluster - $Region - $POD_NAME "
                else
                        #Value=$(echo "$Data"| cut -d "=" -f2)
                        echo "running on $Cluster - $Region  "

                        echo -e "Cluster: $Cluster $Region\n $Data\n ======= \n" >> $Region-$OUTPUT_FILE_NAME-RDBMS
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