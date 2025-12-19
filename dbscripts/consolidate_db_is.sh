#!/bin/bash
# -------------------------------------------------------------------------------------
# Copyright (c) 2025 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
#
# WSO2 LLC. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# --------------------------------------------------------------------------------------

echo "Creating DB scripts for WSO2-IS based on DB Engine"

# Define files and databases
DB_ENGINE='CF_DBMS_NAME'
SCRIPT_LOCATION='CF_SCRIPT_LOCATION'
WSO2_PRODUCT_VERSION_SHORT='CF_PRODUCT_VERSION_SHORT'

if [ $DB_ENGINE = "postgres" ]; then
  # Create database creation script
  db_create_file="$WSO2_PRODUCT_VERSION_SHORT/is_postgres_db_create.sql"
  touch "$db_create_file"
  echo "-- PostgreSQL Database Creation Script" > "$db_create_file"
  echo "DROP DATABASE IF EXISTS \"WSO2IS_SHARED_DB\";" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS \"WSO2IS_BPS_DB\";" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS \"WSO2IS_IDENTITY_DB\";" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS \"WSO2IS_CONSENT_DB\";" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS \"WSO2_METRICS_DB\";" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS \"WSO2IS_AGENTIDENTITY_DB\";" >> "$db_create_file"
  echo "" >> "$db_create_file"
  echo "CREATE DATABASE \"WSO2IS_SHARED_DB\";" >> "$db_create_file"
  echo "CREATE DATABASE \"WSO2IS_BPS_DB\";" >> "$db_create_file"
  echo "CREATE DATABASE \"WSO2IS_IDENTITY_DB\";" >> "$db_create_file"
  echo "CREATE DATABASE \"WSO2IS_CONSENT_DB\";" >> "$db_create_file"
  echo "CREATE DATABASE \"WSO2_METRICS_DB\";" >> "$db_create_file"
  echo "CREATE DATABASE \"WSO2IS_AGENTIDENTITY_DB\";" >> "$db_create_file"
  
  # Create schema scripts for each database
  sql_files=("$SCRIPT_LOCATION/postgresql.sql" "$SCRIPT_LOCATION/identity/postgresql.sql" "$SCRIPT_LOCATION/consent/postgresql.sql" "$SCRIPT_LOCATION/identity/agent/postgresql.sql")
  output_files=("$WSO2_PRODUCT_VERSION_SHORT/is_postgres_shared.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_postgres_identity.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_postgres_consent.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_postgres_agent_identity.sql")
  
  for i in "${!output_files[@]}"; do
    touch "${output_files[$i]}"
    cat "${sql_files[$i]}" >> "${output_files[$i]}"
    echo "" >> "${output_files[$i]}"
  done

elif [ $DB_ENGINE = "mysql" ]; then
  # Create database creation script
  db_create_file="$WSO2_PRODUCT_VERSION_SHORT/is_mysql_db_create.sql"
  touch "$db_create_file"
  echo "-- MySQL Database Creation Script" > "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2IS_SHARED_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2IS_IDENTITY_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2IS_BPS_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2IS_CONSENT_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2_METRICS_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2_CLUSTER_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS IS_ANALYTICS_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2_CARBON_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2_PERSISTENCE_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2_STATUS_DASHBOARD_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2IS_AGENTIDENTITY_DB;" >> "$db_create_file"
  echo "" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_SHARED_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_IDENTITY_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_BPS_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_CONSENT_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2_METRICS_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2_CLUSTER_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE IS_ANALYTICS_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2_CARBON_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2_PERSISTENCE_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2_STATUS_DASHBOARD_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_AGENTIDENTITY_DB character set latin1;" >> "$db_create_file"
  
  # Create schema scripts for each database
  sql_files=("$SCRIPT_LOCATION/mysql.sql" "$SCRIPT_LOCATION/identity/mysql.sql" "$SCRIPT_LOCATION/consent/mysql.sql" "$SCRIPT_LOCATION/identity/agent/mysql.sql")
  output_files=("$WSO2_PRODUCT_VERSION_SHORT/is_mysql_shared.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_mysql_identity.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_mysql_consent.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_mysql_agent_identity.sql")
  
  for i in "${!output_files[@]}"; do
    touch "${output_files[$i]}"
    cat "${sql_files[$i]}" >> "${output_files[$i]}"
    echo "" >> "${output_files[$i]}"
  done

elif [ $DB_ENGINE = "mariadb" ]; then
  # Create database creation script
  db_create_file="$WSO2_PRODUCT_VERSION_SHORT/is_mariadb_db_create.sql"
  touch "$db_create_file"
  echo "-- MariaDB Database Creation Script" > "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2IS_SHARED_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2IS_IDENTITY_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2IS_BPS_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2IS_CONSENT_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2_METRICS_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2_CLUSTER_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS IS_ANALYTICS_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2_CARBON_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2_PERSISTENCE_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2_STATUS_DASHBOARD_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2IS_AGENTIDENTITY_DB;" >> "$db_create_file"
  echo "" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_SHARED_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_IDENTITY_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_BPS_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_CONSENT_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2_METRICS_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2_CLUSTER_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE IS_ANALYTICS_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2_CARBON_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2_PERSISTENCE_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2_STATUS_DASHBOARD_DB character set latin1;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_AGENTIDENTITY_DB character set latin1;" >> "$db_create_file"
  
  # Create schema scripts for each database
  sql_files=("$SCRIPT_LOCATION/mysql.sql" "$SCRIPT_LOCATION/identity/mysql.sql" "$SCRIPT_LOCATION/consent/mysql.sql" "$SCRIPT_LOCATION/identity/agent/mysql.sql")
  output_files=("$WSO2_PRODUCT_VERSION_SHORT/is_mariadb_shared.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_mariadb_identity.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_mariadb_consent.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_mariadb_agent_identity.sql")
  
  for i in "${!output_files[@]}"; do
    touch "${output_files[$i]}"
    cat "${sql_files[$i]}" >> "${output_files[$i]}"
    echo "" >> "${output_files[$i]}"
  done

elif [ $DB_ENGINE = "sqlserver-se" ]; then
  # Create database creation script
  db_create_file="$WSO2_PRODUCT_VERSION_SHORT/is_mssql_db_create.sql"
  touch "$db_create_file"
  echo "-- SQL Server Database Creation Script" > "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2IS_SHARED_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2IS_BPS_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2IS_IDENTITY_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2IS_CONSENT_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2_METRICS_DB;" >> "$db_create_file"
  echo "DROP DATABASE IF EXISTS WSO2IS_AGENTIDENTITY_DB;" >> "$db_create_file"
  echo "GO" >> "$db_create_file"
  echo "" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_SHARED_DB;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_BPS_DB;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_IDENTITY_DB;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_CONSENT_DB;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2_METRICS_DB;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_AGENTIDENTITY_DB;" >> "$db_create_file"
  echo "GO" >> "$db_create_file"
  
  # Create schema scripts for each database
  sql_files=("$SCRIPT_LOCATION/mssql.sql" "$SCRIPT_LOCATION/identity/mssql.sql" "$SCRIPT_LOCATION/consent/mssql.sql" "$SCRIPT_LOCATION/identity/agent/mssql.sql")
  output_files=("$WSO2_PRODUCT_VERSION_SHORT/is_mssql_shared.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_mssql_identity.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_mssql_consent.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_mssql_agent_identity.sql")
  
  for i in "${!output_files[@]}"; do
    touch "${output_files[$i]}"
    # Add USE DATABASE statement for SQL Server
    if [ $i -eq 0 ]; then
      echo "USE WSO2IS_SHARED_DB;" >> "${output_files[$i]}"
      echo "GO" >> "${output_files[$i]}"
    elif [ $i -eq 1 ]; then
      echo "USE WSO2IS_IDENTITY_DB;" >> "${output_files[$i]}"
      echo "GO" >> "${output_files[$i]}"
    elif [ $i -eq 2 ]; then
      echo "USE WSO2IS_CONSENT_DB;" >> "${output_files[$i]}"
      echo "GO" >> "${output_files[$i]}"
    elif [ $i -eq 3 ]; then
      echo "USE WSO2IS_AGENTIDENTITY_DB;" >> "${output_files[$i]}"
      echo "GO" >> "${output_files[$i]}"
    fi
    cat "${sql_files[$i]}" >> "${output_files[$i]}"
    echo "" >> "${output_files[$i]}"
  done

elif [ $DB_ENGINE = "oracle-se" ]; then
  sql_files=("$SCRIPT_LOCATION/oracle.sql" "$SCRIPT_LOCATION/identity/oracle.sql" "$SCRIPT_LOCATION/consent/oracle.sql" "$SCRIPT_LOCATION/identity/agent/oracle.sql")
  databases=("WSO2IS_SHARED_DB" "WSO2IS_IDENTITY_DB" "WSO2IS_CONSENT_DB" "WSO2IS_AGENT_IDENTITY_DB")
  output_files=("$WSO2_PRODUCT_VERSION_SHORT/is_oracle_common.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_oracle_identity.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_oracle_consent.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_oracle_agent_identity.sql")
  
  # Ensure the output files exist (they will not be overwritten)
  for output_file in "${output_files[@]}"; do
    touch "$output_file"
  done
  # Loop through files and write content
  for i in "${!sql_files[@]}"; do
    cat "${sql_files[$i]}" >> "${output_files[$i]}"
    echo "" >> "${output_files[$i]}"
  done

elif [ $DB_ENGINE = "db2-se" ]; then
  # Create database creation script
  db_create_file="$WSO2_PRODUCT_VERSION_SHORT/is_db2_db_create.sql"
  touch "$db_create_file"
  echo "-- DB2 Database Creation Script" > "$db_create_file"
  echo "BEGIN" >> "$db_create_file"
  echo "    DECLARE CONTINUE HANDLER FOR SQLSTATE '42704' BEGIN END;" >> "$db_create_file"
  echo "    DROP DATABASE WSO2IS_SHARED_DB;" >> "$db_create_file"
  echo "    DROP DATABASE WSO2IS_BPS_DB;" >> "$db_create_file"
  echo "    DROP DATABASE WSO2IS_IDENTITY_DB;" >> "$db_create_file"
  echo "    DROP DATABASE WSO2IS_CONSENT_DB;" >> "$db_create_file"
  echo "    DROP DATABASE WSO2_METRICS_DB;" >> "$db_create_file"
  echo "    DROP DATABASE WSO2IS_AGENTIDENTITY_DB;" >> "$db_create_file"
  echo "END;" >> "$db_create_file"
  echo "" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_SHARED_DB;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_BPS_DB;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_IDENTITY_DB;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_CONSENT_DB;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2_METRICS_DB;" >> "$db_create_file"
  echo "CREATE DATABASE WSO2IS_AGENTIDENTITY_DB;" >> "$db_create_file"
  
  # Create schema scripts for each database
  sql_files=("$SCRIPT_LOCATION/db2.sql" "$SCRIPT_LOCATION/identity/db2.sql" "$SCRIPT_LOCATION/consent/db2.sql" "$SCRIPT_LOCATION/identity/agent/db2.sql")
  output_files=("$WSO2_PRODUCT_VERSION_SHORT/is_db2_shared.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_db2_identity.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_db2_consent.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_db2_agent_identity.sql")
  
  for i in "${!output_files[@]}"; do
    touch "${output_files[$i]}"
    cat "${sql_files[$i]}" >> "${output_files[$i]}"
    echo "" >> "${output_files[$i]}"
  done
fi

echo "SQL files appended successfully"