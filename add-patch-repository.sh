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


POM_FILE="pom.xml"
# Create a backup of the original POM file
cp "$POM_FILE" "$POM_FILE.bak"
echo "Created backup at $POM_FILE.bak"

# Function to fix <n> tags to <name> tags (if they exist)
fix_name_tags() {
    # Create a temporary file
    TEMP_FIX=$(mktemp)
    
    # Use perl to replace <n> with <name> tags in repository sections
    perl -pe 's/<n>(.*?)<\/n>/<name>$1<\/name>/g' "$POM_FILE" > "$TEMP_FIX"
    
    # Check if any replacements were actually made
    if diff -q "$POM_FILE" "$TEMP_FIX" >/dev/null; then
        # Files are identical, no changes were made
        rm "$TEMP_FIX"
        echo "No <n> tags found in the repository. Configuration is correct."
    else
        # Files differ, changes were made
        mv "$TEMP_FIX" "$POM_FILE"
        echo "Repository name tags fixed."
    fi
}

# Define the WSO2 repository directly to avoid any formatting issues
WSO2_REPO='        <repository>
            <id>wso2-nexus-u2-update-repo</id>
            <name>Support Nexus Repository of WSO2</name>
            <url>https://support-maven.wso2.org/nexus/content/repositories/updates-2.0/</url>
            <releases>
                <enabled>true</enabled>
                <updatePolicy>daily</updatePolicy>
                <checksumPolicy>ignore</checksumPolicy>
            </releases>
        </repository>'

# Check if WSO2 repository already exists
if grep -q '<url>https://support-maven.wso2.org/nexus/content/repositories/updates-2.0/</url>' "$POM_FILE"; then
    echo "WSO2 repository URL already exists in pom.xml"
    
    # Fix any <n> tags to <name> tags
    if grep -q '<n>' "$POM_FILE"; then
        echo "Fixing incorrect name tag format in repository..."
        fix_name_tags
    else
        echo "Repository configuration looks correct. No changes needed."
    fi
    
    exit 0
fi

# Create a temporary file
TEMP_FILE=$(mktemp)

# Check if <repositories> section exists
if grep -q '<repositories>' "$POM_FILE"; then
    while IFS= read -r line; do
        echo "$line" >> "$TEMP_FILE"
        if [[ "$line" == *"<repositories>"* ]]; then
            echo "$WSO2_REPO" >> "$TEMP_FILE"
        fi
    done < "$POM_FILE"
    echo "WSO2 repository added to existing <repositories> section."
else
    ADDED=false
    while IFS= read -r line; do
        echo "$line" >> "$TEMP_FILE"
        if [[ "$line" == *"<scm>"* ]] && [ "$ADDED" = false ]; then
            echo "    <repositories>" >> "$TEMP_FILE"
            echo "$WSO2_REPO" >> "$TEMP_FILE"
            echo "    </repositories>" >> "$TEMP_FILE"
            ADDED=true
        elif [[ "$line" == *"</project>"* ]] && [ "$ADDED" = false ]; then
            # Insert before the closing project tag
            sed -i '' '$d' "$TEMP_FILE" # Remove the last line which is </project>
            echo "    <repositories>" >> "$TEMP_FILE"
            echo "$WSO2_REPO" >> "$TEMP_FILE"
            echo "    </repositories>" >> "$TEMP_FILE"
            echo "$line" >> "$TEMP_FILE" # Add back the </project> line
            ADDED=true
        fi
    done < "$POM_FILE"
    echo "New <repositories> section added with WSO2 repository."
fi

# Ensure the </project> tag is present
if ! grep -q '</project>' "$TEMP_FILE"; then
    echo "</project>" >> "$TEMP_FILE"
fi

# Replace the original POM file with the modified one
mv "$TEMP_FILE" "$POM_FILE"

# Fix any <n> tags to <name> tags
if grep -q '<n>' "$POM_FILE"; then
    echo "Fixing incorrect name tag format in repository..."
    fix_name_tags
fi
