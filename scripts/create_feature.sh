#!/bin/bash

# Wrapper script for create_feature.dart
# Usage: ./scripts/create_feature.sh <feature_name>
# Example: ./scripts/create_feature.sh products

if [ -z "$1" ]; then
    echo "❌ Error: Feature name is required"
    echo "Usage: ./scripts/create_feature.sh <feature_name>"
    echo "Example: ./scripts/create_feature.sh products"
    exit 1
fi

dart run scripts/create_feature.dart "$1"

flutter pub run build_runner build --delete-conflicting-outputs