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

#Running Database scripts for WSO2-IS
echo "Running DB scripts for WSO2-IS..."

#Define parameter values for Database Engine and Version

DB_ENGINE='CF_DBMS_NAME'
DB_ENGINE_VERSION='CF_DBMS_VERSION'
WSO2_PRODUCT_VERSION='CF_PRODUCT_VERSION'
USE_CONSENT_DB=false

#Select product version
if [ $WSO2_PRODUCT_VERSION = "5.2.0" ]; then
    WSO2_PRODUCT_VERSION_SHORT=is520
elif [ $WSO2_PRODUCT_VERSION = "5.3.0" ]; then
    WSO2_PRODUCT_VERSION_SHORT=is530
elif [ $WSO2_PRODUCT_VERSION = "5.4.0" ]; then
    WSO2_PRODUCT_VERSION_SHORT=is540
elif [ $WSO2_PRODUCT_VERSION = "5.4.1" ]; then
    WSO2_PRODUCT_VERSION_SHORT=is541
elif [ $WSO2_PRODUCT_VERSION = "5.5.0" ]; then
    WSO2_PRODUCT_VERSION_SHORT=is550
    USE_CONSENT_DB=true
elif [ $WSO2_PRODUCT_VERSION = "5.6.0" ]; then
    WSO2_PRODUCT_VERSION_SHORT=is560
    USE_CONSENT_DB=true
elif [ $WSO2_PRODUCT_VERSION = "5.7.0" ]; then
    WSO2_PRODUCT_VERSION_SHORT=is570
    USE_CONSENT_DB=true
elif [ $WSO2_PRODUCT_VERSION = "5.8.0" ]; then
    WSO2_PRODUCT_VERSION_SHORT=is580
    USE_CONSENT_DB=true
elif [ $WSO2_PRODUCT_VERSION = "5.9.0" ]; then
    WSO2_PRODUCT_VERSION_SHORT=is590
    USE_CONSENT_DB=true
elif [ $WSO2_PRODUCT_VERSION = "5.10.0" ]; then
    WSO2_PRODUCT_VERSION_SHORT=is5100
    USE_CONSENT_DB=true
elif [ $WSO2_PRODUCT_VERSION = "5.11.0" ]; then
    WSO2_PRODUCT_VERSION_SHORT=is5110
    USE_CONSENT_DB=true
elif [ $WSO2_PRODUCT_VERSION = "6.0.0" ]; then
    WSO2_PRODUCT_VERSION_SHORT=is600
    USE_CONSENT_DB=true
elif [ $WSO2_PRODUCT_VERSION = "6.1.0" ]; then
    WSO2_PRODUCT_VERSION_SHORT=is610
    USE_CONSENT_DB=true
elif [ $WSO2_PRODUCT_VERSION = "7.0.0" ]; then
    WSO2_PRODUCT_VERSION_SHORT=is700
    USE_CONSENT_DB=true
elif [[ $WSO2_PRODUCT_VERSION == *"7.1.0"* ]]; then
    WSO2_PRODUCT_VERSION_SHORT=is710
    USE_CONSENT_DB=true
elif [[ $WSO2_PRODUCT_VERSION == *"7.2.0"* ]]; then
    WSO2_PRODUCT_VERSION_SHORT=is720
    USE_CONSENT_DB=true
fi

#Run database scripts for given database engine and product version

if [[ $DB_ENGINE = "postgres" ]]; then
    # DB Engine : Postgres
    echo "Postgres DB Engine Selected! Running WSO2-IS $WSO2_PRODUCT_VERSION DB Scripts for Postgres..."
    export PGPASSWORD=CF_DB_PASSWORD
    psql -U CF_DB_USERNAME -h CF_DB_HOST -p CF_DB_PORT -d postgres -f /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_postgres.sql
elif [[ $DB_ENGINE = "mysql" ]]; then
    # DB Engine : MySQL
    echo "MySQL DB Engine Selected! Running WSO2-IS $WSO2_PRODUCT_VERSION DB Scripts for MySQL..."
    if [[ $WSO2_PRODUCT_VERSION = "5.10.0" || $WSO2_PRODUCT_VERSION = "5.11.0" ]]; then
        mysql -u CF_DB_USERNAME -pCF_DB_PASSWORD -h CF_DB_HOST -P CF_DB_PORT < /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_mysql.sql
    elif [[ $WSO2_PRODUCT_VERSION = "5.9.0" ]]; then
        mysql -u CF_DB_USERNAME -pCF_DB_PASSWORD -h CF_DB_HOST -P CF_DB_PORT < /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_mysql.sql
    elif [[ $DB_ENGINE_VERSION = "5.7" || $DB_ENGINE_VERSION = "8.0.17" ]]; then
        mysql -u CF_DB_USERNAME -pCF_DB_PASSWORD -h CF_DB_HOST -P CF_DB_PORT < /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_mysql5.7.sql
    else
        mysql -u CF_DB_USERNAME -pCF_DB_PASSWORD -h CF_DB_HOST -P CF_DB_PORT < /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_mysql.sql
    fi
elif [[ $DB_ENGINE = "mariadb" ]]; then
    # DB Engine : mariadb
    echo "Maria DB Engine Selected! Running WSO2-IS $WSO2_PRODUCT_VERSION DB Scripts for MariaDB..."
    mysql -u CF_DB_USERNAME -pCF_DB_PASSWORD -h CF_DB_HOST -P CF_DB_PORT < /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_mysql.sql
elif [[ $DB_ENGINE =~ 'oracle-se' ]]; then
    # DB Engine : Oracle
    echo "Oracle DB Engine Selected! Running WSO2-IS $WSO2_PRODUCT_VERSION DB Scripts for Oracle..."
    # Create users to the required DB
    echo "DECLARE USER_EXIST INTEGER;"$'\n'"BEGIN SELECT COUNT(*) INTO USER_EXIST FROM dba_users WHERE username='WSO2IS_BPS_DB';"$'\n'"IF (USER_EXIST > 0) THEN EXECUTE IMMEDIATE 'DROP USER WSO2IS_BPS_DB CASCADE';"$'\n'"END IF;"$'\n'"END;"$'\n'"/" >> /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle.sql
    echo "DECLARE USER_EXIST INTEGER;"$'\n'"BEGIN SELECT COUNT(*) INTO USER_EXIST FROM dba_users WHERE username='WSO2IS_IDENTITY_DB';"$'\n'"IF (USER_EXIST > 0) THEN EXECUTE IMMEDIATE 'DROP USER WSO2IS_IDENTITY_DB CASCADE';"$'\n'"END IF;"$'\n'"END;"$'\n'"/" >> /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle.sql
    echo "DECLARE USER_EXIST INTEGER;"$'\n'"BEGIN SELECT COUNT(*) INTO USER_EXIST FROM dba_users WHERE username='WSO2IS_CONSENT_DB';"$'\n'"IF (USER_EXIST > 0) THEN EXECUTE IMMEDIATE 'DROP USER WSO2IS_CONSENT_DB CASCADE';"$'\n'"END IF;"$'\n'"END;"$'\n'"/" >> /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle.sql
    echo "CREATE USER WSO2IS_BPS_DB IDENTIFIED BY CF_DB_PASSWORD;"$'\n'"GRANT CONNECT, RESOURCE, DBA TO WSO2IS_BPS_DB;"$'\n'"GRANT UNLIMITED TABLESPACE TO WSO2IS_BPS_DB;" >> /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle.sql
    echo "CREATE USER WSO2IS_IDENTITY_DB IDENTIFIED BY CF_DB_PASSWORD;"$'\n'"GRANT CONNECT, RESOURCE, DBA TO WSO2IS_IDENTITY_DB;"$'\n'"GRANT UNLIMITED TABLESPACE TO WSO2IS_IDENTITY_DB;" >> /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle.sql
    echo "CREATE USER WSO2IS_CONSENT_DB IDENTIFIED BY CF_DB_PASSWORD;"$'\n'"GRANT CONNECT, RESOURCE, DBA TO WSO2IS_CONSENT_DB;"$'\n'"GRANT UNLIMITED TABLESPACE TO WSO2IS_CONSENT_DB;" >> /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle.sql
    if [[ $WSO2_PRODUCT_VERSION = "5.9.0" || $WSO2_PRODUCT_VERSION = "5.10.0" || $WSO2_PRODUCT_VERSION = "5.11.0" || $WSO2_PRODUCT_VERSION = "7.0.0" ]]; then
        echo "DECLARE USER_EXIST INTEGER;"$'\n'"BEGIN SELECT COUNT(*) INTO USER_EXIST FROM dba_users WHERE username='WSO2IS_SHARED_DB';"$'\n'"IF (USER_EXIST > 0) THEN EXECUTE IMMEDIATE 'DROP USER WSO2IS_REG_DB CASCADE';"$'\n'"END IF;"$'\n'"END;"$'\n'"/" >> /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle.sql
        echo "CREATE USER WSO2IS_SHARED_DB IDENTIFIED BY CF_DB_PASSWORD;"$'\n'"GRANT CONNECT, RESOURCE, DBA TO WSO2IS_SHARED_DB;"$'\n'"GRANT UNLIMITED TABLESPACE TO WSO2IS_SHARED_DB;" >> /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle.sql
    else
        echo "DECLARE USER_EXIST INTEGER;"$'\n'"BEGIN SELECT COUNT(*) INTO USER_EXIST FROM dba_users WHERE username='WSO2IS_REG_DB';"$'\n'"IF (USER_EXIST > 0) THEN EXECUTE IMMEDIATE 'DROP USER WSO2IS_REG_DB CASCADE';"$'\n'"END IF;"$'\n'"END;"$'\n'"/" >> /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle.sql
        echo "DECLARE USER_EXIST INTEGER;"$'\n'"BEGIN SELECT COUNT(*) INTO USER_EXIST FROM dba_users WHERE username='WSO2IS_USER_DB';"$'\n'"IF (USER_EXIST > 0) THEN EXECUTE IMMEDIATE 'DROP USER WSO2IS_USER_DB CASCADE';"$'\n'"END IF;"$'\n'"END;"$'\n'"/" >> /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle.sql
        echo "CREATE USER WSO2IS_REG_DB IDENTIFIED BY CF_DB_PASSWORD;"$'\n'"GRANT CONNECT, RESOURCE, DBA TO WSO2IS_REG_DB;"$'\n'"GRANT UNLIMITED TABLESPACE TO WSO2IS_REG_DB;" >> /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle.sql
        echo "CREATE USER WSO2IS_USER_DB IDENTIFIED BY CF_DB_PASSWORD;"$'\n'"GRANT CONNECT, RESOURCE, DBA TO WSO2IS_USER_DB;"$'\n'"GRANT UNLIMITED TABLESPACE TO WSO2IS_USER_DB;" >> /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle.sql
    fi
    # Create the users
    # WARN: DO NOT RUN THE is_oracle.sql SCRIPT AFTER CREATING THE TABLES - SCHEMAS DROP WITH THE USERS
    echo exit | sqlplus64 CF_DB_USERNAME/CF_DB_PASSWORD@//CF_DB_HOST:CF_DB_PORT/WSO2ISDB @/home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle.sql
    # Create the tables
    echo "--------------------BPS---------------------"
    if [[ $WSO2_PRODUCT_VERSION != "7.0.0" && $WSO2_PRODUCT_VERSION != "7.1.0-SNAPSHOT" && $WSO2_PRODUCT_VERSION != "7.1.0" && $WSO2_PRODUCT_VERSION != "7.2.0-SNAPSHOT" && $WSO2_PRODUCT_VERSION != "7.2.0" ]]; then
    echo exit | sqlplus64 WSO2IS_BPS_DB/CF_DB_PASSWORD@//CF_DB_HOST:CF_DB_PORT/WSO2ISDB @/home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle_bps.sql
    fi
    echo "--------------------IDENTITY---------------------"
    echo exit | sqlplus64 WSO2IS_IDENTITY_DB/CF_DB_PASSWORD@//CF_DB_HOST:CF_DB_PORT/WSO2ISDB @/home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle_identity.sql
    if [[ $WSO2_PRODUCT_VERSION = "5.10.0" || $WSO2_PRODUCT_VERSION = "5.11.0" || $WSO2_PRODUCT_VERSION = "7.0.0" || $WSO2_PRODUCT_VERSION != "7.1.0-SNAPSHOT" || $WSO2_PRODUCT_VERSION != "7.1.0" || $WSO2_PRODUCT_VERSION != "7.2.0-SNAPSHOT" || $WSO2_PRODUCT_VERSION != "7.2.0" ]]; then
    echo "--------------------COMMON---------------------"
        echo exit | sqlplus64 WSO2IS_SHARED_DB/CF_DB_PASSWORD@//CF_DB_HOST:CF_DB_PORT/WSO2ISDB @/home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle_common.sql
    elif [[ $WSO2_PRODUCT_VERSION = "5.9.0" ]]; then
    echo "--------------------COMMON---------------------"
        echo exit | sqlplus64 WSO2IS_SHARED_DB/CF_DB_PASSWORD@//CF_DB_HOST:CF_DB_PORT/WSO2ISDB @/home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle_common.sql
    else
        echo exit | sqlplus64 WSO2IS_REG_DB/CF_DB_PASSWORD@//CF_DB_HOST:CF_DB_PORT/WSO2ISDB @/home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle_common.sql
        echo exit | sqlplus64 WSO2IS_USER_DB/CF_DB_PASSWORD@//CF_DB_HOST:CF_DB_PORT/WSO2ISDB @/home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle_common.sql
    fi
    if $USE_CONSENT_DB; then
        echo exit | sqlplus64 WSO2IS_CONSENT_DB/CF_DB_PASSWORD@//CF_DB_HOST:CF_DB_PORT/WSO2ISDB @/home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle_consent.sql
    else
        echo exit | sqlplus64 WSO2IS_CONSENT_DB/CF_DB_PASSWORD@//CF_DB_HOST:CF_DB_PORT/WSO2ISDB @/home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_oracle_common.sql
    fi
elif [[ $DB_ENGINE =~ 'sqlserver-se' ]]; then
    # DB Engine : SQLServer
    echo "SQL Server DB Engine Selected! Running WSO2-IS $WSO2_PRODUCT_VERSION DB Scripts for SQL Server..."
    sqlcmd -S CF_DB_HOST -U CF_DB_USERNAME -P CF_DB_PASSWORD -i /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_mssql.sql
elif [[ $DB_ENGINE = "db2-se" ]]; then
    # DB Engine : DB2
    echo "DB2 DB Engine Selected! Running WSO2-IS $WSO2_PRODUCT_VERSION DB Scripts for DB2..."
    db2cli -tvf /home/ubuntu/is/$WSO2_PRODUCT_VERSION_SHORT/is_db2.sql -u CF_DB_USERNAME -p CF_DB_PASSWORD -h CF_DB_HOST -p CF_DB_PORT
fi

echo "Database Provision Complete"
