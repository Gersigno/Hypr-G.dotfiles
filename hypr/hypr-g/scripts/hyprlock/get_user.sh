#!/bin/bash

# Get the current username
USERNAME=$(whoami)

# Capitalize the first letter and print
# ${VAR^} is a bash-specific string manipulation for uppercase first letter
echo "${USERNAME^}"