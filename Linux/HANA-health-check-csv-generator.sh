#!/bin/bash

# Get the hostname of the current machine
CURRENT_HOSTNAME=$(hostname)

# Set the directory for the CSVs and SQL Queries
HANA_DIR="/hana/shared/monitoring"

# Set the SID variable to the first three characters of the hostname, capitalized
SID=$(echo ${CURRENT_HOSTNAME} | cut -c -3 | tr '[:lower:]' '[:upper:]')

# Set the name of the GCS bucket to upload the CSV files to
BUCKET_NAME="inv_tracker_bucket/HANA/np-sapcar"                                                                                                

# Get the name of the current active primary server
ACTIVE_SERVER=$(SAPHanaSR-showAttr | grep -i promoted | awk '{ print $1}')                                                                             

if [[ "${ACTIVE_SERVER}" == "${CURRENT_HOSTNAME}" ]]; then                                                                                  
  echo "Current machine is the active primary server"
  
  # Run the five commands with a 5 second delay between each command
  /hana/shared/${SID}/hdbclient/hdbsql -o ${HANA_DIR}/${SID}_HANA_AlertsOverview.csv -U 4TENANTDB1 -I ${HANA_DIR}/HANA_AlertsOverview.sql       
  sleep 5s
  /hana/shared/${SID}/hdbclient/hdbsql -o ${HANA_DIR}/${SID}_HANA_Backups.csv -U 4TENANTDB1 -I ${HANA_DIR}/HANA_Backups.sql
  sleep 5s
  /hana/shared/${SID}/hdbclient/hdbsql -o ${HANA_DIR}/${SID}_HANA_MemoryUsage.csv -U 4TENANTDB1 -I ${HANA_DIR}/HANA_MemoryUsage.sql
  sleep 5s
  /hana/shared/${SID}/hdbclient/hdbsql -o ${HANA_DIR}/${SID}_HANA_OOMDumps.csv -U 4TENANTDB1 -I ${HANA_DIR}/HANA_OOMDumps.sql
  sleep 5s
  /hana/shared/${SID}/hdbclient/hdbsql -o ${HANA_DIR}/${SID}_HANA_Services.csv -U 4TENANTDB1 -I ${HANA_DIR}/HANA_Services.sql

  # Upload the CSV files to the specified GCS bucket
  gsutil -m cp /hana/shared/monitoring/*.csv gs://${BUCKET_NAME}/

	# Clean up all recently created CSV files
	rm /hana/shared/monitoring/*.csv

else                                                                                                                                        
  echo "Current machine is not the active primary server"
fi