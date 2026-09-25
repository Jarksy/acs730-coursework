#!/usr/bin/env bash
set -euo pipefail

# Install Python 3
sudo dnf install -y python3

# Create the web directory and the index page
echo "<h1>Lab 2 Web App is Running!</h1>" | sudo tee /home/webapp/index.html

# Fix ownership so the least-privilege user owns the file
sudo chown webapp:webapp /home/webapp/index.html
