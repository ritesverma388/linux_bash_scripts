#root@development:/git/scripts# cat get_zeus_tenant_details.sh
#!/bin/bash
echo "**********************************************"
echo $1
cd /git/scripts/zeus_data/
grep "$1" *

#root@development:/git/scripts# cat get_all_zeus_tenant.sh
#!/bin/bash
rm -r /git/scripts/zeus_data/*
sleep 15
for reg in `kubectx | grep prod`
do
   kubectx $reg
   sleep 5
   kubectl config current-context
   kubectl port-forward service/tenant-resource-catalog 8001:80 &
   sleep 20
   curl -X 'GET' 'http://localhost:8001/resourceSets?status=assigned' -H 'accept: application/json' | jq '.resource_sets[] | "\(.tenant_id) \(.tenant_url)"' | tr -d '"' >> /git/scripts/zeus_data/$reg
   sleep 10
   kill %1
done;
#root@development:/git/scripts#