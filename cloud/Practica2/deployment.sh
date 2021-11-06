#!/usr/bin/env bash

source "${PWD}/config.ini"
source "color.sh"

create_repository() {

    #Creates and upload code to the google repository

    echo "$(green_text "[+] Auth to continue:")"
    gcloud init

    echo "$(green_text "[+] Creating repository:") $repo_name ..."
    gcloud source repos create $repo_name

    echo "$(green_text "[+] Cloning repository to local machine:") Cloning repo..."
    gcloud source repos clone $repo_name --project=$project_name

    echo "$(green_text "[+] Moving content to the remote cloned folder:") Moving files..."
    cp *.* $repo_name
    cd $repo_name

    echo "$(green_text "[+] Uploading content to the remote repo:") Uploading content..."
    git add .
    git commit -m "init"
    git push -u origin master
}
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
    ID:STRING,AMOUNT:FLOAT
}

create_CloudFunction() {
    
    #Creates the cloud function for the service

    echo "$(green_text "[+] Creating the Cloud Function...")"
    gcloud functions deploy $CloudFunction_name \
            --entry-point=ingest_transaction \
            --runtime=python39 \
            --region $location \
            --memory 256MB \
            --timeout 60s \
            --trigger-resource $bucket_name \
            --trigger-event google.storage.object.finalize
}

create_trigger() {

    #Creates the trigger of Cloud Build

    echo "$(green_text "[+] Creating the trigger for repository and master branch..")"
    gcloud beta builds triggers create cloud-source-repositories \
    --repo=$repo_name \
    --branch-pattern="^master$" \ # or --tag-pattern=TAG_PATTERN
    --build-config="cloudbuild-prod.yaml" \
    --service-account=$project_name \
    --name=$trigger_name
}

# 1. Creates the repository and push the code
# https://cloud.google.com/source-repositories/docs/creating-an-empty-repository#gcloud
# https://cloud.google.com/source-repositories/docs/creating-an-empty-repository#gcloud
#create_repository

# 2. Create the bucket
# https://cloud.google.com/storage/docs/creating-buckets?authuser=1#storage-create-bucket-gsutil
#create_bucket

# 3. Create dataset and table into BigQuery
# https://cloud.google.com/bigquery/docs/datasets#bq
# https://cloud.google.com/bigquery/docs/tables
#create_dataSet
#create_table

# 4. Create the cloud function
# https://cloud.google.com/sdk/gcloud/reference/functions/deploy#--trigger-event
# https://cloud.google.com/functions/docs/calling/storage#archive
#create_CloudFunction

# 5. Create trigger
# https://cloud.google.com/build/docs/automating-builds/create-manage-triggers
create_trigger

