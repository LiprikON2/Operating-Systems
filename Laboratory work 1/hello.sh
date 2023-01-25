#!/usr/bin/bash

echo "Hey, $USER" # Output: "Hey, "

TRUE_USER=$(whoami)
echo "Hey, ${TRUE_USER}" # Output: "Hey, user"