Select ds_id, title, db_type, connector_name, connector_version, max(job_start_time) as latest_MDE_start_time from
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
group by result.ds_id,result.title,db_type,connector_name,connector_version order by ds_id;