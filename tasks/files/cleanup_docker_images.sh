#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Define the repository to clean up
REPOSITORY="YOUR-REPO"

# Get all image IDs from the specified repository that are older than 48 hours
IMAGES=$(docker images --format '{{.Repository}}:{{.Tag}}@{{.CreatedAt}}' | grep "^$REPOSITORY" | awk -F'@' '{if ($2 <= strftime("%Y-%m-%dT%H:%M:%S", systime() - 172800)) print $1}')

# Remove the selected images
for image in $IMAGES; do
    docker rmi "$image"
done
