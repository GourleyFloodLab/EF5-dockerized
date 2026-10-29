#!/bin/bash

# Default verified variables
ALPINE_VERSION="3.17"
REPO="https://github.com/HyDROSLab/EF5.git"
BRANCH="master"

# Check for custom source injection
if [ -f "../custom_sources.env" ]; then
    echo "Detected custom_sources.env file."
    source ../custom_sources.env
    HAS_CUSTOM=true
else
    HAS_CUSTOM=false
fi

echo "======================================"
echo " Select EF5 Source Repository:"
echo "======================================"
echo " 1) Default: HyDROSLab Original (master)"
echo " 2) Active Fork: AHWALab (master)"
if [ "$HAS_CUSTOM" = true ]; then
    echo " 3) Custom Injection (Loaded from .env)"
fi
echo "======================================"
read -p "Enter choice: " choice

case $choice in
    1)
        echo "Selected: HyDROSLab Original"
        REPO="https://github.com/HyDROSLab/EF5.git"
        BRANCH="master"
        ALPINE_VERSION="3.17"
        ;;
    2)
        echo "Selected: AHWALab Active Fork"
        REPO="https://github.com/AHWALab/EF5.git"
        BRANCH="master"
        ALPINE_VERSION="3.17"
        echo ""
        echo "WARNING: The AHWALab fork renamed the inundation parameter from 'th_inu' to 'th_fim'. Ensure your control.txt reflects this change to avoid silent runtime errors."
        echo ""
        sleep 2
        ;;
    3)
        if [ "$HAS_CUSTOM" = true ]; then
            echo "Selected: Custom Injection"
            REPO="${EF5_REPO_URL}"
            BRANCH="${EF5_BRANCH}"
            ALPINE_VERSION="${ALPINE_VERSION:-3.17}"
        else
            echo "Invalid choice. Defaulting to HyDROSLab Original."
        fi
        ;;
    *)
        echo "Invalid choice. Defaulting to HyDROSLab Original."
        ;;
esac

# Generate dynamic tag based on repository owner and branch
# Extracts the 4th field from the URL (e.g., 'HyDROSLab' or 'AHWALab')
ORG_NAME=$(echo "$REPO" | awk -F'/' '{print $4}')
TAG_NAME="ef5-${ORG_NAME,,}:${BRANCH}"

echo "Building Docker image: $TAG_NAME with Alpine $ALPINE_VERSION"

docker build \
  --build-arg ALPINE_VERSION="$ALPINE_VERSION" \
  --build-arg EF5_REPO_URL="$REPO" \
  --build-arg EF5_BRANCH="$BRANCH" \
  -t "$TAG_NAME" \
  -t ef5-container:latest \
  -f Dockerfile ..