#!/bin/bash

# Set variables
BUCKET_NAME=inv_tracker_bucket/HANA/pr-ca-retail
LOCAL_DIR=/root/scripts/health_reports/hana/reports
MERGED_CSV_NAME=all_merged_AlertsOverview.csv
PR7_FILENAME=PR7_HANA_AlertsOverview.csv
CSV_FILENAME=pr-ca-retail_HANA_AlertsOverview.csv

# Download CSV files from GCS bucket (excluding certain files)
gsutil ls gs://${BUCKET_NAME}/*.csv | while read -r filepath; do
    filename=$(basename "${filepath}")
    if [ "${filename:9:2}" == "Al" ] && [ "$filename" != "pr-ca-retail_*" ]; then
        gsutil cp "${filepath}" "${LOCAL_DIR}/${filename}"
    fi
done

# Loop through all CSVs (except for PR7) and remove first row (header)
for file in $(ls ${LOCAL_DIR}/*.csv | grep -v "^PR7"); do tail -n +2 $file > temp && mv temp $file; done

# Merge CSV files locally
cat $(ls ${LOCAL_DIR}/*.csv | grep -v "^PR7") >> ${LOCAL_DIR}/${MERGED_CSV_NAME}
cat ${LOCAL_DIR}/${PR7_FILENAME} ${LOCAL_DIR}/${MERGED_CSV_NAME} > ${LOCAL_DIR}/${CSV_FILENAME}

# Upload merged CSV file back to GCS bucket
gsutil cp ${LOCAL_DIR}/${CSV_FILENAME} gs://${BUCKET_NAME}/${CSV_FILENAME}

# Empty local directory
rm ${LOCAL_DIR}/*
