#!/bin/bash

# Prompt user for URL type
read -p "Choose URL format (https/ssh): " url_choice

# Check valid format
if [[ "$url_choice" != "https" && "$url_choice" != "ssh" ]]; then
    echo " Invalid URL format. Choose 'https' or 'ssh'."
    exit 1
fi

# Prompt for the repo URL
read -p "Enter the repository URL to clone: " url
if [[ -z "$url" ]]; then
    echo " URL cannot be empty."
    exit 1
fi

if [[ "$url_choice" == "ssh" ]]; then
    echo " Setting up SSH agent..."
    eval "$(ssh-agent -s)" >/dev/null

    read -p "Enter path to your private SSH key (default: ~/.ssh/id_rsa): " ssh_key
    ssh_key=${ssh_key:-~/.ssh/id_rsa}  # Use id_rsa if input is empty

    if [ -f "$ssh_key" ]; then
        ssh-add "$ssh_key"
    else
        echo " SSH key not found at $ssh_key"
        echo "⚠️ Make sure the path is correct or generate a key using ssh-keygen"
        return 1
    fi
fi


# Clone the repo
echo " Cloning from: $url"
if git clone "$url"; then
    echo " Cloning successful!"
else
    echo " Cloning failed. Check the repo URL and authentication method."
    exit 1
fi

