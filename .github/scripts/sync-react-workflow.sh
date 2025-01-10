#!/bin/bash

# Clone React repo
git clone https://github.com/facebook/react.git temp-react --depth=1

# Create workflows directory if it doesn't exist
mkdir -p .github/workflows/

# Copy workflow file
cp temp-react/.github/workflows/runtime_build_and_test.yml .github/workflows/benchmark.yml

# Modify with yq
yq -P -i '.on = {"workflow_dispatch": {}, "schedule": [{"cron": "15 */12 * * *"}]}' .github/workflows/benchmark.yml
yq -P -i '(.jobs.* | select(.strategy == null)).strategy.matrix.runner = ["ubuntu-24.04", "devzero-ubuntu-24.04"]' .github/workflows/benchmark.yml
yq -P -i '(.jobs.* | select(.strategy != null)).strategy.matrix.runner = ["ubuntu-24.04", "devzero-ubuntu-24.04"]' .github/workflows/benchmark.yml
yq -P -i '.jobs.*.runs-on = "${{ matrix.runner }}"' .github/workflows/benchmark.yml
yq -P -i '(.jobs.*.steps.[] | select(.uses == "actions/checkout@v4").with.repository) = "facebook/react"' .github/workflows/benchmark.yml
yq -P -i '(.jobs.*.steps.[] | select(.uses == "actions/checkout@v4").with.ref) = "main"' .github/workflows/benchmark.yml

# Clean up
rm -rf temp-react

# Configure git and commit
git config --local user.email "$1"
git config --local user.name "$2"
git add .github/workflows/benchmark.yml
git commit -m "Setup React runtime tests workflow" || echo "No changes to commit"
git push origin main