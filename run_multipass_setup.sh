#!/bin/bash

# Enable strict mode:
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.
# -o pipefail: Causes a pipeline to return the exit status of the last command in the pipe that failed.
set -euo pipefail

# Source environment variables
source .env

ansible-galaxy install -r requirements.yml

# Execute ansible-playbook with the necessary variables
ansible-playbook 98-devbox-multipass-configure.yaml \
    --connection=local  \
    --extra-vars "git_username=${git_username} \
        tailscale_domain=$TAILSCALE_DOMAIN \
        tailscale_auth_key=$AUTH_KEY \
        tailscale_api_key=$API_KEY \
        tailnet=$TAILNET"
