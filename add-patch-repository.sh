#!/bin/bash

POM_FILE="pom.xml"
REPO_FILE="add_u2.xml"

# Read WSO2 repository configuration from add_u2.xml
WSO2_REPO=$(<"$REPO_FILE")

# Check if WSO2 repository already exists
if grep -q '<url>https://support-maven.wso2.org/nexus/content/repositories/updates-2.0/</url>' "$POM_FILE"; then
    echo "WSO2 repository already exists in pom.xml"
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
        if [[ "$line" == *"<scm>"* ]] && [ "$ADDED" = false ]; then
            echo "    <repositories>" >> "$TEMP_FILE"
            echo "$WSO2_REPO" >> "$TEMP_FILE"
            echo "    </repositories>" >> "$TEMP_FILE"
            ADDED=true
        fi
        echo "$line" >> "$TEMP_FILE"
    done < "$POM_FILE"
    if [ "$ADDED" = false ]; then
        while IFS= read -r line; do
            if [[ "$line" == *"</project>"* ]]; then
                if [ "$ADDED" = false ]; then
                    echo "    <repositories>" >> "$TEMP_FILE"
                    echo "$WSO2_REPO" >> "$TEMP_FILE"
                    echo "    </repositories>" >> "$TEMP_FILE"
                    ADDED=true
                fi
            fi
            echo "$line" >> "$TEMP_FILE"
        done < "$POM_FILE"
    fi
    echo "New <repositories> section added with WSO2 repository."
fi

# Ensure the </project> tag is present
if ! grep -q '</project>' "$TEMP_FILE"; then
    echo "</project>" >> "$TEMP_FILE"
fi

# Replace the original POM file with the modified one
mv "$TEMP_FILE" "$POM_FILE"
