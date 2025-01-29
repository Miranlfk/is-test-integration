#!/bin/bash

echo "Creating DB scripts for WSO2-IS based on DB Engine"

# Define files and databases
DB_ENGINE='CF_DBMS_NAME'
SCRIPT_LOCATION='CF_SCRIPT_LOCATION'

if [ $DB_ENGINE = "postgres" ]; then
  sql_files=("$SCRIPT_LOCATION/postgresql.sql" "$SCRIPT_LOCATION/identity/postgresql.sql" "$SCRIPT_LOCATION/consent/postgresql.sql")
  databases=("WSO2IS_SHARED_DB" "WSO2IS_IDENTITY_DB" "WSO2IS_CONSENT_DB")
  output_file="is710/is_postgres.sql"
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
  output_files=("is710/is_mysql.sql" "is710/is_mysql5.7.sql" "is710/is_mysql_8.sql")
  
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
  output_files="is710/is_mysql.sql"
  
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
  output_file="is710/is_mssql.sql"
  
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
  output_files=("is710/is_oracle_common.sql" "is710/is_oracle_identity.sql" "is710/is_oracle_consent.sql")
  
  # Ensure the output files exist (they will not be overwritten)
  for output_file in "${output_files[@]}"; do
    touch "$output_file"
  done
  # Loop through files and write content
  for i in "${!sql_files[@]}"; do
    cat "${sql_files[$i]}" >> "${output_files[$i]}"
    echo "" >> "${output_files[$i]}"
  done
fi

echo "SQL files appended successfully"
