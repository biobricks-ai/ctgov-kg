#!/usr/bin/env bash
# Script to download files

# Get local path
localpath=$(pwd)
echo "Local path: $localpath"

downloadpath="$localpath/download"
echo "Download path: $downloadpath"
mkdir -p $downloadpath

URL='https://ctti-aact.nyc3.digitaloceanspaces.com/b3eaknxyv33k9ah4hckm4igb1ozq'
OUTPUT_ZIP_BASENAME='20240430_clinical_trials.zip'

mkdir -p $downloadpath/aact/db-dump
wget "$URL" \
  -O $downloadpath/aact/db-dump/"$OUTPUT_ZIP_BASENAME"

echo "Download done."
