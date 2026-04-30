#!/bin/bash

echo "📱 Available emulators:"
flutter emulators

echo ""
read -p "Enter emulator id to launch: " id

flutter emulators --launch $id