#!/usr/bin/env bash

source "${PWD}/config.ini"
source "color.sh"


delete_repository() {

    #Deletes de remote repo and local folder
    echo "$(green_text "[+] Deleting local folder:")"
    sudo rm -r $repo_name

    echo "$(green_text "[+] Deleting remote repository:") $repo_name ..."
    gcloud init
    gcloud source repos delete $repo_name
}

delete_bucket() {

    #deletes the bucket with the unique name from config.ini

    echo "$(green_text "[+] Deleting bucket:") $bucket_name ..."
    gsutil rm -r gs://$bucket_name
}

delete_dataSet(){

    #Deletes the dataset

    echo "$(green_text "[+] Deleting dataset:") $dataSet_name ..."
    bq rm -r -d -f $dataSet_name
}

delete_table() {

    #Deletes the table from previous dataset

    echo "$(green_text "[+] Deleting table:") $table_name ..."
    bq rm -t -f $dataSet_name.$table_name

}

delete_CloudFunction() {

    #Deletes Cloud Function that copies New Blobs to BigQuery table

    echo "$(green_text "[+] Deleting Cloud Function...")"
    gcloud functions delete -q $CloudFunction_name --region $location
}

# 1. Delete de repository
# https://cloud.google.com/source-repositories/docs/deleting-a-repository
delete_repository

# 2. Deletes the bucket
# https://cloud.google.com/storage/docs/deleting-buckets#gsutil
delete_bucket

# 3. Delete dataset and table for BigQuery
# https://cloud.google.com/bigquery/docs/managing-datasets
# https://cloud.google.com/bigquery/docs/managing-tables
delete_dataSet
delete_table

# 4. Delete Cloud Function
# https://cloud.google.com/sdk/gcloud/reference/functions/delete
delete_CloudFunction