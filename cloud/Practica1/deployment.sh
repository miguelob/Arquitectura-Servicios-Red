#!/usr/bin/env bash

source "${PWD}/config.ini"
source "color.sh"

create_bucket() {

    #Creates the bucket with the unique name from config.ini

    echo "$(green_text "[+] Creating bucket:") $bucket_name ..."
    gsutil mb -l $location -b on gs://$bucket_name

}

create_dataSet(){

    #Creates the dataset into bq

    echo "$(green_text "[+] Creating dataset:") $dataSet_name ..."
    bq --location=$location mk -d $dataSet_name
}

create_table() {

    #Creates the tabla into the dataset created above

    echo "$(green_text "[+] Creating table:") $table_name ..."
    bq mk $dataSet_name.$table_name \
    userId:STRING,transaction:FLOAT
}

create_CloudFunction() {
    
    #Creates the trigger for the service

    echo "$(green_text "[+] Creating the Cloud Function...")"
    gcloud functions deploy $CloudFunction_name \
            --entry-point=upload2BQ \
            --runtime=python39 \
            --region $location \
            --memory 512MB \
            --timeout 60s \
            --trigger-resource $bucket_name \
            --trigger-event google.storage.object.finalize
}
# 1. Create the bucket
# https://cloud.google.com/storage/docs/creating-buckets?authuser=1#storage-create-bucket-gsutil
create_bucket

#2. Create dataset and table into BigQuery
# https://cloud.google.com/bigquery/docs/datasets#bq
# https://cloud.google.com/bigquery/docs/tables
create_dataSet
create_table

#3. Create trigger
# https://cloud.google.com/sdk/gcloud/reference/functions/deploy#--trigger-event
# https://cloud.google.com/functions/docs/calling/storage#archive
create_CloudFunction

