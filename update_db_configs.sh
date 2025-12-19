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

# Script to update WSO2 deployment.toml with database configuration from infra.json
# Usage: ./update_db_config.sh <db_type>
# Example: ./update_db_config.sh mysql

# Check if a database type was provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <db_type>"
    echo "Available database types: $(jq -r '.jdbc[].name' infra.json | tr '\n' ', ' | sed 's/,$//')"
    exit 1
fi

DB_TYPE_INPUT=$1
WSO2_PRODUCT_VERSION=$2
DEPLOYMENT_TOML="$WSO2_PRODUCT_VERSION/repository/conf/deployment.toml"
INFRA_JSON="infra.json"
NEW_TOML="${DEPLOYMENT_TOML}.new"
BACKUP_TOML="${DEPLOYMENT_TOML}.bak"

# Check if files exist
if [ ! -f "$INFRA_JSON" ]; then
    echo "Error: $INFRA_JSON not found"
    exit 1
fi

if [ ! -f "$DEPLOYMENT_TOML" ]; then
    echo "Error: $DEPLOYMENT_TOML not found"
    exit 1
fi

DB_TYPE=$DB_TYPE_INPUT

# Check if the database type exists in infra.json

DB_EXISTS=$(jq -r --arg db "$DB_TYPE" '.jdbc[] | select(.name == $db) | .name' "$INFRA_JSON")
if [ -z "$DB_EXISTS" ]; then
    echo "Error: Database type '$DB_TYPE' (mapped from '$DB_TYPE_INPUT') not found in $INFRA_JSON"
    echo "Available database types: $(jq -r '.jdbc[].name' "$INFRA_JSON" | tr '\n' ', ' | sed 's/,$//')"
    exit 1
fi

# Extract database configuration from infra.json
DRIVER=$(jq -r --arg db "$DB_TYPE" '.jdbc[] | select(.name == $db) | .driver' "$INFRA_JSON")
VALIDATION_QUERY=$(jq -r --arg db "$DB_TYPE" '.jdbc[] | select(.name == $db) | .validation_query' "$INFRA_JSON")

echo "Updating $DEPLOYMENT_TOML with $DB_TYPE database configuration..."

# Create a backup
cp "$DEPLOYMENT_TOML" "$BACKUP_TOML"

# Extract database info from infra.json
IDENTITY_DB=$(jq -r --arg db "$DB_TYPE" '.jdbc[] | select(.name == $db) | .database[] | select(.name == "WSO2IDENTITY_DB")' "$INFRA_JSON")
SHARED_DB=$(jq -r --arg db "$DB_TYPE" '.jdbc[] | select(.name == $db) | .database[] | select(.name == "WSO2SHARED_DB")' "$INFRA_JSON")
AGENTIDENTITY_DB=$(jq -r --arg db "$DB_TYPE" '.jdbc[] | select(.name == $db) | .database[] | select(.name == "WSO2AGENTIDENTITY_DB")' "$INFRA_JSON")

# Extract values for identity_db
IDENTITY_URL=$(echo "$IDENTITY_DB" | jq -r '.url')
IDENTITY_USERNAME=$(echo "$IDENTITY_DB" | jq -r '.username')
IDENTITY_PASSWORD=$(echo "$IDENTITY_DB" | jq -r '.password')

# Extract values for shared_db
SHARED_URL=$(echo "$SHARED_DB" | jq -r '.url')
SHARED_USERNAME=$(echo "$SHARED_DB" | jq -r '.username')
SHARED_PASSWORD=$(echo "$SHARED_DB" | jq -r '.password')

AGENTIDENTITY_URL=$(echo "$AGENTIDENTITY_DB" | jq -r '.url')
AGENTIDENTITY_USERNAME=$(echo "$AGENTIDENTITY_DB" | jq -r '.username')
AGENTIDENTITY_PASSWORD=$(echo "$AGENTIDENTITY_DB" | jq -r '.password')

# For oracle, we'll use oracle-se2 even though we map it to "oracle" for display
if [ "$DB_TYPE_INPUT" = "oracle-se2" ] || [ "$DB_TYPE_INPUT" = "oracle-se2-cdb" ]; then
    DB_TYPE="oracle"
fi

# Create new content
{
  # Read the file until we find identity_db section
  while IFS= read -r line; do
    if [[ "$line" =~ ^\[database.identity_db\] ]]; then
      # Write the identity_db section
      echo "[database.identity_db]"
      echo "type = \"$DB_TYPE\""
      echo "url = \"$IDENTITY_URL\""
      echo "username = \"$IDENTITY_USERNAME\""
      echo "password = \"$IDENTITY_PASSWORD\""
      echo "driver = \"$DRIVER\""
      echo "validationQuery = \"$VALIDATION_QUERY\""
      echo ""
      
      # Skip the original section
      while IFS= read -r section_line; do
        if [[ "$section_line" =~ ^\[ ]]; then
          # We reached a new section, process it
          if [[ "$section_line" =~ ^\[database.shared_db\] ]]; then
            # Write shared_db section
            echo "[database.shared_db]"
            echo "type = \"$DB_TYPE\""
            echo "url = \"$SHARED_URL\""
            echo "username = \"$SHARED_USERNAME\""
            echo "password = \"$SHARED_PASSWORD\""
            echo "driver = \"$DRIVER\""
            echo "validationQuery = \"$VALIDATION_QUERY\""
            echo ""
            
            # Skip the original shared_db section
            while IFS= read -r shared_section_line; do
              if [[ "$shared_section_line" =~ ^\[ ]]; then
                # We reached the next section after shared_db
                if [[ "$shared_section_line" =~ ^\[datasource.AgentIdentity\] ]]; then
                  # Write AgentIdentity datasource section if AGENTIDENTITY_DB exists
                  if [ -n "$AGENTIDENTITY_URL" ] && [ "$AGENTIDENTITY_URL" != "null" ]; then
                    echo "[datasource.AgentIdentity]"
                    echo "id = \"AgentIdentity\""
                    echo "type = \"$DB_TYPE\""
                    echo "url = \"$AGENTIDENTITY_URL\""
                    echo "username = \"$AGENTIDENTITY_USERNAME\""
                    echo "password = \"$AGENTIDENTITY_PASSWORD\""
                    echo "driver = \"$DRIVER\""
                    echo "validationQuery = \"$VALIDATION_QUERY\""
                    echo ""
                    
                    # Skip the original AgentIdentity section
                    while IFS= read -r agent_section_line; do
                      if [[ "$agent_section_line" =~ ^\[ ]]; then
                        # We reached the next section after AgentIdentity
                        echo "$agent_section_line"
                        break
                      fi
                    done
                  else
                    # If no AGENTIDENTITY_DB in infra.json, keep the original section
                    echo "$shared_section_line"
                  fi
                else
                  echo "$shared_section_line"
                fi
                break
              fi
            done
          else
            # This is not the shared_db section, just echo it
            echo "$section_line"
          fi
          break
        fi
      done
    else
      echo "$line"
    fi
  done
} < "$BACKUP_TOML" > "$NEW_TOML"

# Replace original file with our new file
mv "$NEW_TOML" "$DEPLOYMENT_TOML"

echo "Database configuration updated successfully for '$DB_TYPE_INPUT' (mapped to '$DB_TYPE_DISPLAY')"

# Show the updated sections
echo -e "\nUpdated database configuration in $DEPLOYMENT_TOML:"
grep -A 6 "^\[database\." "$DEPLOYMENT_TOML"
