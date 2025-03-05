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
  sql_files=("$SCRIPT_LOCATION/postgresql.sql" "$SCRIPT_LOCATION/identity/postgresql.sql" "$SCRIPT_LOCATION/consent/postgresql.sql")
  databases=("WSO2IS_SHARED_DB" "WSO2IS_IDENTITY_DB" "WSO2IS_CONSENT_DB")
  output_file="$WSO2_PRODUCT_VERSION_SHORT/is_postgres.sql"
  # Ensure the output file exists (it will not be overwritten)
  touch "$output_file"
  
  # Loop through files and append content
  for i in "${!sql_files[@]}"; do
  echo "\c ${databases[$i]};" >> "$output_file"
  echo "" >> "$output_file"
  cat "${sql_files[$i]}" >> "$output_file"
  echo "" >> "$output_file"
  done

elif [ $DB_ENGINE = "mysql" ]; then
  sql_files=("$SCRIPT_LOCATION/mysql.sql" "$SCRIPT_LOCATION/identity/mysql.sql" "$SCRIPT_LOCATION/consent/mysql.sql")
  databases=("WSO2IS_SHARED_DB" "WSO2IS_IDENTITY_DB" "WSO2IS_CONSENT_DB")
  output_files=("$WSO2_PRODUCT_VERSION_SHORT/is_mysql.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_mysql5.7.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_mysql_8.sql")
  
  # Ensure the output files exist (they will not be overwritten)
  for output_file in "${output_files[@]}"; do
    touch "$output_file"
  done
  
  # Loop through files and append content
  for i in "${!sql_files[@]}"; do
    for output_file in "${output_files[@]}"; do
      echo "USE ${databases[$i]};" >> "$output_file"
      echo "" >> "$output_file"
      cat "${sql_files[$i]}" >> "$output_file"
      echo "" >> "$output_file"
    done
  done

elif [ $DB_ENGINE = "mariadb" ]; then
  sql_files=("$SCRIPT_LOCATION/mysql.sql" "$SCRIPT_LOCATION/identity/mysql.sql" "$SCRIPT_LOCATION/consent/mysql.sql")
  databases=("WSO2IS_SHARED_DB" "WSO2IS_IDENTITY_DB" "WSO2IS_CONSENT_DB")
  output_files="$WSO2_PRODUCT_VERSION_SHORT/is_mysql.sql"
  
  # Ensure the output file exists (it will not be overwritten)
  touch "$output_file"
  
  # Loop through files and append content
  for i in "${!sql_files[@]}"; do
  echo "USE ${databases[$i]};" >> "$output_file"
  echo "" >> "$output_file"
  cat "${sql_files[$i]}" >> "$output_file"
  echo "" >> "$output_file"
  done

elif [ $DB_ENGINE = "sqlserver-se" ]; then
  sql_files=("$SCRIPT_LOCATION/mssql.sql" "$SCRIPT_LOCATION/identity/mssql.sql" "$SCRIPT_LOCATION/consent/mssql.sql")
  databases=("WSO2IS_SHARED_DB" "WSO2IS_IDENTITY_DB" "WSO2IS_CONSENT_DB")
  output_file="$WSO2_PRODUCT_VERSION_SHORT/is_mssql.sql"
  
  # Ensure the output file exists (it will not be overwritten)
  touch "$output_file"
  
  # Loop through files and append content
  for i in "${!sql_files[@]}"; do
  echo "USE ${databases[$i]};" >> "$output_file"
  echo "GO" >> "$output_file"
  echo "" >> "$output_file"
  cat "${sql_files[$i]}" >> "$output_file"
  echo "" >> "$output_file"
  done

elif [ $DB_ENGINE = "oracle-se" ]; then
  sql_files=("$SCRIPT_LOCATION/oracle.sql" "$SCRIPT_LOCATION/identity/oracle.sql" "$SCRIPT_LOCATION/consent/oracle.sql")
  databases=("WSO2IS_SHARED_DB" "WSO2IS_IDENTITY_DB" "WSO2IS_CONSENT_DB")
  output_files=("$WSO2_PRODUCT_VERSION_SHORT/is_oracle_common.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_oracle_identity.sql" "$WSO2_PRODUCT_VERSION_SHORT/is_oracle_consent.sql")
  
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
  sql_files=("$SCRIPT_LOCATION/db2.sql" "$SCRIPT_LOCATION/identity/db2.sql" "$SCRIPT_LOCATION/consent/db2.sql")
  databases=("WSO2IS_SHARED_DB" "WSO2IS_IDENTITY_DB" "WSO2IS_CONSENT_DB")
  output_file="$WSO2_PRODUCT_VERSION_SHORT/is_db2.sql"
  
  # Ensure the output file exists (it will not be overwritten)
  touch "$output_file"
  
  # Loop through files and append content
  for i in "${!sql_files[@]}"; do
  echo "CONNECT TO ${databases[$i]};" >> "$output_file"
  echo "" >> "$output_file"
  cat "${sql_files[$i]}" >> "$output_file"
  echo "" >> "$output_file"
  done
fi

echo "SQL files appended successfully"