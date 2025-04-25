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

# Download and install a specific JDK version
# Arguments:
#   $1 - JDK name (e.g., ADOPT_OPEN_JDK11, ADOPT_OPEN_JDK17, ADOPT_OPEN_JDK21)
# Returns:
#   None, but sets JAVA_HOME environment variable
function install_specific_jdk() {
    local jdk_name=$1
    local jdk_dir="/opt/${jdk_name}"
    
    log_info "Installing JDK: ${jdk_name}"
    
    # Create JDK directory
    mkdir -p "${jdk_dir}"
    
    # Get JDK file name from infra.json
    local jdk_file=$(jq -r '.jdk[] | select ( .name == '\"${jdk_name}\"') | .file_name' ${INFRA_JSON})
    if [[ -z "${jdk_file}" ]]; then
        log_error "Failed to find JDK file for ${jdk_name} in ${INFRA_JSON}"
    fi
    
    # Download and extract JDK
    log_info "Downloading JDK: ${jdk_name} (${jdk_file})"
    wget -q "https://integration-testgrid-resources.s3.amazonaws.com/lib/jdk/${jdk_file}.tar.gz" || log_error "Failed to download JDK ${jdk_name}"
    tar -xzf "${jdk_file}.tar.gz" -C "${jdk_dir}" --strip-component=1 || log_error "Failed to extract JDK ${jdk_name}"
    
    # Clean up downloaded archive
    rm -f "${jdk_file}.tar.gz"
    
    # Set JAVA_HOME
    export JAVA_HOME="${jdk_dir}"
    log_info "Set JAVA_HOME to ${JAVA_HOME}"
}

# Install JDK for the current build
# Arguments:
#   $1 - Primary JDK type to install (from CFN_PROP_FILE)
# Returns:
#   None, but sets JAVA_HOME environment variable
function install_jdk() {
    local jdk_type=$1
    local jdk11="ADOPT_OPEN_JDK11"
    
    # Install requested JDK version
    if [[ "${jdk_type}" == "ADOPT_OPEN_JDK17" || "${jdk_type}" == "ADOPT_OPEN_JDK21" ]]; then
        # For JDK 17 and 21, we need both the requested JDK and JDK 11 for compilation
        install_specific_jdk ${jdk_type}
        
        # Install JDK 11 for compilation support, this will be reverted once the compilation is done and before testing begins
        log_info "Installing JDK 11 for compilation support"
        install_specific_jdk ${jdk11}
        
    else
        # For other JDK types, just install JDK 11
        install_specific_jdk ${jdk_type}
    fi
}

function export_db_params(){
    db_name=$1

    export WSO2SHARED_DB_DRIVER=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .driver' ${INFRA_JSON})
    export WSO2SHARED_DB_URL=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .database[] | select ( .name == "WSO2SHARED_DB") | .url' ${INFRA_JSON})
    export WSO2SHARED_DB_USERNAME=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .database[] | select ( .name == "WSO2SHARED_DB") | .username' ${INFRA_JSON})
    export WSO2SHARED_DB_PASSWORD=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .database[] | select ( .name == "WSO2SHARED_DB") | .password' ${INFRA_JSON})
    export WSO2SHARED_DB_VALIDATION_QUERY=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .validation_query' ${INFRA_JSON})
    
    export WSO2IDENTITY_DB_DRIVER=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .driver' ${INFRA_JSON})
    export WSO2IDENTITY_DB_URL=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .database[] | select ( .name == "WSO2IDENTITY_DB") | .url' ${INFRA_JSON})
    export WSO2IDENTITY_DB_USERNAME=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .database[] | select ( .name == "WSO2IDENTITY_DB") | .username' ${INFRA_JSON})
    export WSO2IDENTITY_DB_PASSWORD=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .database[] | select ( .name == "WSO2IDENTITY_DB") | .password' ${INFRA_JSON})
    export WSO2IDENTITY_DB_VALIDATION_QUERY=$(jq -r '.jdbc[] | select ( .name == '\"${db_name}\"' ) | .validation_query' ${INFRA_JSON})
    
}

source /etc/environment

log_info "Clone Product repository"
if [ ! -d $PRODUCT_REPOSITORY_NAME ];
then
    git clone https://${GIT_USER}:${GIT_PASS}@$PRODUCT_REPOSITORY --branch $PRODUCT_REPOSITORY_BRANCH --single-branch
fi

log_info "Exporting JDK"
install_jdk ${JDK_TYPE}

pwd

db_file=$(jq -r '.jdbc[] | select ( .name == '\"${DB_TYPE}\"') | .file_name' ${INFRA_JSON})
wget -q https://integration-testgrid-resources.s3.amazonaws.com/lib/jdbc/${db_file}.jar  -P $TESTGRID_DIR/${PRODUCT_PACK_NAME}/repository/components/lib

sed -i "s|DB_HOST|${CF_DB_HOST}|g" ${INFRA_JSON}
sed -i "s|DB_USERNAME|${CF_DB_USERNAME}|g" ${INFRA_JSON}
sed -i "s|DB_PASSWORD|${CF_DB_PASSWORD}|g" ${INFRA_JSON}
sed -i "s|DB_NAME|${DB_NAME}|g" ${INFRA_JSON}

export_db_params ${DB_TYPE}

# delete if the folder is available
rm -rf $PRODUCT_REPOSITORY_PACK_DIR
mkdir -p $PRODUCT_REPOSITORY_PACK_DIR
log_info "Copying product pack to Repository"
ls $TESTGRID_DIR
rm -rf $TESTGRID_DIR/$PRODUCT_NAME-$PRODUCT_VERSION.zip
ls $TESTGRID_DIR
zip -q -r $TESTGRID_DIR/$PRODUCT_NAME-$PRODUCT_VERSION.zip $PRODUCT_NAME-$PRODUCT_VERSION

log_info "Navigating to integration test module directory"
ls $INT_TEST_MODULE_DIR

# Check for master branch execution or tag-based execution
if [[ "$PRODUCT_VERSION" != *"SNAPSHOT"* ]]; then
    cd $TESTGRID_DIR/$PRODUCT_REPOSITORY_NAME
    echo $JAVA_HOME
    #If support is true add the nexus repository to the pom.xml
    if [[ "$PRODUCT_REPOSITORY_BRANCH" == *"support"* ]]; then
        log_info "Add WSO2 repository to pom.xml"
        cp $TESTGRID_DIR/add-patch-repository.sh $TESTGRID_DIR/$PRODUCT_REPOSITORY_NAME/
        cp $TESTGRID_DIR/add_u2.xml $TESTGRID_DIR/$PRODUCT_REPOSITORY_NAME/
        bash $TESTGRID_DIR/$PRODUCT_REPOSITORY_NAME/add-patch-repository.sh
    fi
    log_info "Running Maven clean install"
    #For Tag-based execution we initially build the product pack and then run the integration tests
    echo $JAVA_HOME
    mvn clean install -Dmaven.test.skip=true
    echo "Copying pack to target"
    mv $TESTGRID_DIR/$PRODUCT_NAME-$PRODUCT_VERSION.zip $PRODUCT_REPOSITORY_PACK_DIR/$PRODUCT_NAME-$PRODUCT_VERSION.zip
    ls $PRODUCT_REPOSITORY_PACK_DIR
    cd $INT_TEST_MODULE_DIR
    log_info "Running Maven clean install"
    #For Tag based execution we need to reset the JAVA_HOME to the requested JDK for the integration tests once compilation is complete
    export JAVA_HOME=/opt/${jdk_name}
    echo $JAVA_HOME
    mvn clean install
else 
    echo "Copying pack to target"
    mv $TESTGRID_DIR/$PRODUCT_NAME-$PRODUCT_VERSION.zip $PRODUCT_REPOSITORY_PACK_DIR/$PRODUCT_NAME-$PRODUCT_VERSION.zip
    ls $PRODUCT_REPOSITORY_PACK_DIR
    cd $INT_TEST_MODULE_DIR
    log_info "Running Maven clean install"
    mvn clean install
fi
