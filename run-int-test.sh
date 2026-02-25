#!/bin/bash
# -------------------------------------------------------------------------------------
# Copyright (c) 2025 WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
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

set -o xtrace

TESTGRID_DIR=/opt/testgrid/workspace
INFRA_JSON='infra.json'
M2_REPO_DIR=/opt/testgrid/m2-repo
PRODUCT_REPOSITORY=$1
PRODUCT_REPOSITORY_BRANCH=$2
PRODUCT_NAME="wso2$3"
PRODUCT_VERSION=$4
GIT_USER=$5
GIT_PASS=$6
TEST_MODE=$7
TEST_GROUP=$8
PRODUCT_REPOSITORY_NAME=$(echo $PRODUCT_REPOSITORY | rev | cut -d'/' -f1 | rev | cut -d'.' -f1)
PRODUCT_REPOSITORY_PACK_DIR="$TESTGRID_DIR/$PRODUCT_REPOSITORY_NAME/modules/distribution/target"
INT_TEST_MODULE_DIR="$TESTGRID_DIR/$PRODUCT_REPOSITORY_NAME/modules/integration/tests-integration"

# CloudFormation properties
CFN_PROP_FILE="${TESTGRID_DIR}/cfn-props.properties"

JDK_TYPE=$(grep -w "JDK_TYPE" ${CFN_PROP_FILE} | cut -d"=" -f2)
DB_TYPE=$(grep -w "CF_DBMS_NAME" ${CFN_PROP_FILE} | cut -d"=" -f2)
PRODUCT_PACK_NAME=$(grep -w "REMOTE_PACK_NAME" ${CFN_PROP_FILE} | cut -d"=" -f2)
CF_DBMS_VERSION=$(grep -w "CF_DBMS_VERSION" ${CFN_PROP_FILE} | cut -d"=" -f2)
CF_DB_PASSWORD=$(grep -w "CF_DB_PASSWORD" ${CFN_PROP_FILE} | cut -d"=" -f2)
CF_DB_USERNAME=$(grep -w "CF_DB_USERNAME" ${CFN_PROP_FILE} | cut -d"=" -f2)
CF_DB_HOST=$(grep -w "CF_DB_HOST" ${CFN_PROP_FILE} | cut -d"=" -f2)
CF_DB_PORT=$(grep -w "CF_DB_PORT" ${CFN_PROP_FILE} | cut -d"=" -f2)
CF_DB_NAME=$(grep -w "SID" ${CFN_PROP_FILE} | cut -d"=" -f2)
PRODUCT_PACK_LOCATION=$(grep -w "PRODUCT_PACK_LOCATION" ${CFN_PROP_FILE} | cut -d"=" -f2)

function log_info(){
    echo "[INFO][$(date '+%Y-%m-%d %H:%M:%S')]: $1"
}

function log_error(){
    echo "[ERROR][$(date '+%Y-%m-%d %H:%M:%S')]: $1"
    exit 1
}

function install_jdk11(){
    if [[ "$JDK_TYPE" == "ADOPT_OPEN_JDK17_ARM" ]] || [[ "$JDK_TYPE" == "ADOPT_OPEN_JDK21_ARM" ]]; then
        jdk11="ADOPT_OPEN_JDK11_ARM"
    else
        jdk11="ADOPT_OPEN_JDK11"
    fi
    mkdir -p /opt/${jdk11}
    jdk_file2=$(jq -r '.jdk[] | select ( .name == '\"${jdk11}\"') | .file_name' ${INFRA_JSON})
    wget -q https://integration-testgrid-resources.s3.amazonaws.com/lib/jdk/$jdk_file2.tar.gz
    tar -xzf "$jdk_file2.tar.gz" -C /opt/${jdk11} --strip-component=1

    export JAVA_HOME=/opt/${jdk11}
}

function install_jdks(){
    mkdir -p /opt/${jdk_name}
    jdk_file=$(jq -r '.jdk[] | select ( .name == '\"${jdk_name}\"') | .file_name' ${INFRA_JSON})
    wget -q https://integration-testgrid-resources.s3.amazonaws.com/lib/jdk/$jdk_file.tar.gz
    tar -xzf "$jdk_file.tar.gz" -C /opt/${jdk_name} --strip-component=1

    export JAVA_HOME=/opt/${jdk_name}
    echo $JAVA_HOME
}

function set_jdk(){
    jdk_name=$1
    #When running Integration tests for JDK 17 or 21, JDK 11 is also required for compilation.
    if [[ "$jdk_name" == "ADOPT_OPEN_JDK17" ]] || [[ "$jdk_name" == "ADOPT_OPEN_JDK21" ]] || [[ "$jdk_name" == "ADOPT_OPEN_JDK17_ARM" ]] || [[ "$jdk_name" == "ADOPT_OPEN_JDK21_ARM" ]]; then
        echo "Installing " + $jdk_name
        install_jdks
        echo $JAVA_HOME
        #setting JAVA_HOME to JDK 11 to compile
        install_jdk11
        echo $JAVA_HOME 
    elif [[ "$jdk_name" == "ADOPT_OPEN_JDK8" ]]; then
        echo "Installing " + $jdk_name
        install_jdks
        echo $JAVA_HOME
    else
        echo "Installing " + $jdk_name
        install_jdks
        echo $JAVA_HOME
        
    fi
}

function export_db_params(){
    db_name=$1

    export SHARED_DB_DRIVER=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .driver' ${INFRA_JSON})
    export SHARED_DB_URL=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .database[] | select ( .name == "WSO2SHARED_DB") | .url' ${INFRA_JSON})
    export SHARED_DB_USERNAME=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .database[] | select ( .name == "WSO2SHARED_DB") | .username' ${INFRA_JSON})
    export SHARED_DB_PASSWORD=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .database[] | select ( .name == "WSO2SHARED_DB") | .password' ${INFRA_JSON})
    export SHARED_DB_VALIDATION_QUERY=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .validation_query' ${INFRA_JSON})
    
    export IDENTITY_DB_DRIVER=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .driver' ${INFRA_JSON})
    export IDENTITY_DB_URL=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .database[] | select ( .name == "WSO2IDENTITY_DB") | .url' ${INFRA_JSON})
    export IDENTITY_DB_USERNAME=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .database[] | select ( .name == "WSO2IDENTITY_DB") | .username' ${INFRA_JSON})
    export IDENTITY_DB_PASSWORD=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .database[] | select ( .name == "WSO2IDENTITY_DB") | .password' ${INFRA_JSON})
    export IDENTITY_DB_VALIDATION_QUERY=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .validation_query' ${INFRA_JSON})

    export AGENTIDENTITY_DB_DRIVER=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .driver' ${INFRA_JSON})
    export AGENTIDENTITY_DB_URL=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .database[] | select ( .name == "WSO2AGENTIDENTITY_DB") | .url' ${INFRA_JSON})
    export AGENTIDENTITY_DB_USERNAME=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .database[] | select ( .name == "WSO2AGENTIDENTITY_DB") | .username' ${INFRA_JSON})
    export AGENTIDENTITY_DB_PASSWORD=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .database[] | select ( .name == "WSO2AGENTIDENTITY_DB") | .password' ${INFRA_JSON})
    export AGENTIDENTITY_DB_VALIDATION_QUERY=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .validation_query' ${INFRA_JSON})
    
}

source /etc/environment

log_info "Clone Product repository"
if [ ! -d $PRODUCT_REPOSITORY_NAME ];
then
    git clone https://${GIT_USER}:${GIT_PASS}@$PRODUCT_REPOSITORY --branch $PRODUCT_REPOSITORY_BRANCH --single-branch
fi


wget -q "https://raw.githubusercontent.com/Miranlfk/testgrid-jenkins-library/refs/heads/add-script/scripts/is/intg/infra.json"
log_info "Exporting JDK"
set_jdk ${JDK_TYPE}

pwd
db_file=$(jq -r '.jdbc[] | select ( .name == '\"${DB_TYPE}\"') | .file_name' ${INFRA_JSON})
wget -q https://integration-testgrid-resources.s3.amazonaws.com/lib/jdbc/${db_file}.jar  -P $TESTGRID_DIR/${PRODUCT_PACK_NAME}/repository/components/lib


sed -i "s|DB_HOST|${CF_DB_HOST}|g" ${INFRA_JSON}
sed -i "s|DB_USERNAME|${CF_DB_USERNAME}|g" ${INFRA_JSON}
sed -i "s|DB_PASSWORD|${CF_DB_PASSWORD}|g" ${INFRA_JSON}
sed -i "s|DB_NAME|${DB_NAME}|g" ${INFRA_JSON}

export_db_params ${DB_TYPE}

# mkdir -p $M2_REPO_DIR
# export MAVEN_OPTS="-Dmaven.repo.local=$M2_REPO_DIR"

# delete if the folder is available
rm -rf $PRODUCT_REPOSITORY_PACK_DIR
mkdir -p $PRODUCT_REPOSITORY_PACK_DIR
log_info "Copying product pack to Repository"
ls $TESTGRID_DIR
rm -rf $TESTGRID_DIR/$PRODUCT_NAME-$PRODUCT_VERSION.zip
ls $TESTGRID_DIR

Update database configurations in deployment.toml before re-zipping
log_info "Updating database configurations in deployment.toml"
wget -q https://integration-testgrid-resources.s3.us-east-1.amazonaws.com/iam-support-scripts/update_db_configs.sh
cp update_db_configs.sh $TESTGRID_DIR/
bash $TESTGRID_DIR/update_db_configs.sh $DB_TYPE $PRODUCT_NAME-$PRODUCT_VERSION

# Re-zip the pack after configuration updates
log_info "Re-zipping product pack with updated configurations"
zip -q -r $TESTGRID_DIR/$PRODUCT_NAME-$PRODUCT_VERSION.zip $PRODUCT_NAME-$PRODUCT_VERSION

log_info "Navigating to integration test module directory"
ls $INT_TEST_MODULE_DIR

# Check for master branch execution or tag-based execution
if [[ "$PRODUCT_VERSION" != *"SNAPSHOT"* ]]; then
    cd $TESTGRID_DIR/$PRODUCT_REPOSITORY_NAME || log_error "Failed to navigate to product repository directory"
    echo $JAVA_HOME
    #If support add the nexus repository to the pom.xml
    if [[ "$PRODUCT_REPOSITORY_BRANCH" == *"support"* ]]; then
        cp $TESTGRID_DIR/add-patch-repository.sh $TESTGRID_DIR/$PRODUCT_REPOSITORY_NAME
        log_info "Add WSO2 repository to pom.xml"
        
        bash $TESTGRID_DIR/$PRODUCT_REPOSITORY_NAME/add-patch-repository.sh
        if [[ "$PRODUCT_VERSION" == "5.11.0" ]]; then
            cd $TESTGRID_DIR/$PRODUCT_REPOSITORY_NAME
            find . -name "*.toml" -type f -exec sed -i '/^\[user_store\]/,/^base_dn =/c\[user_store]\ntype = "database_unique_id"\n#connection_url = "ldap://localhost:${Ports.EmbeddedLDAP.LDAPServerPort}"\n#connection_name = "uid=admin,ou=system"\n#connection_password = "admin"\n#base_dn = "dc=wso2,dc=org"' {} +
        fi
    fi
    log_info "Running Maven clean install"
    #For Tag-based execution we initially build the product pack and then run the integration tests
    echo $JAVA_HOME
    mvn clean install -Dmaven.test.skip=true -U
    echo "Copying pack to target"
    mv $TESTGRID_DIR/$PRODUCT_NAME-$PRODUCT_VERSION.zip $PRODUCT_REPOSITORY_PACK_DIR/$PRODUCT_NAME-$PRODUCT_VERSION.zip
    ls $PRODUCT_REPOSITORY_PACK_DIR
    cd $INT_TEST_MODULE_DIR || log_error "Failed to navigate to integration test module directory"
    log_info "Running Maven clean install"
    export JAVA_HOME=/opt/${jdk_name}
    echo $JAVA_HOME
    mvn clean install
else 
    echo "Copying pack to target"
    mv $TESTGRID_DIR/$PRODUCT_NAME-$PRODUCT_VERSION.zip $PRODUCT_REPOSITORY_PACK_DIR/$PRODUCT_NAME-$PRODUCT_VERSION.zip
    ls $PRODUCT_REPOSITORY_PACK_DIR
    cd $INT_TEST_MODULE_DIR || log_error "Failed to navigate to integration test module directory"
    log_info "Running Maven clean install"
    mvn clean install -U
fi
