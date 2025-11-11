#!/bin/bash

# Wrapper script for remove_feature.dart
# Usage: ./scripts/remove_feature.sh <feature_name>
# Example: ./scripts/remove_feature.sh products

if [ -z "$1" ]; then
    echo "❌ Error: Feature name is required"
    echo "Usage: ./scripts/remove_feature.sh <feature_name>"
    echo "Example: ./scripts/remove_feature.sh products"
    exit 1
fi

dart run scripts/remove_feature.dart "$1"

