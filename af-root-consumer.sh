#!/bin/bash

# Script to test the Artifactory consumer module
# This script downloads the consumer module from Artifactory and runs it locally

set -e  # Exit on any error

# Terraform/OpenTofu selection (default to tofu)
TF=${TF:-tofu}

# Check if test-af-root directory exists
if [ -d "test-af-root" ]; then
    echo "❌ Directory 'test-af-root' already exists. Please remove it first or run 'make clean'."
    exit 1
fi

echo "🚀 Starting Artifactory consumer module test..."

# Create test directory and cd into it
echo "📁 Creating test-af-root directory..."
mkdir test-af-root
cd test-af-root

# Create temporary main.tf to download the consumer module
echo "📝 Creating temporary main.tf to download consumer module..."
cat > main.tf << 'EOF'
# Test module that references the Artifactory consumer module (latest version)
module "af_consumer" {
  source = "devoptimize.jfrog.io/devo-terraform__devo_tf_demo_cnsmr/root/aws"
}

# Output the consumer module's outputs for testing
output "consumer_breadcrumbs" {
  description = "Breadcrumbs from the consumer module"
  value = {
    all_breadcrumbs = module.af_consumer.all_module_breadcrumbs
    big_a_breadcrumb = module.af_consumer.big_a_breadcrumb
    big_b_breadcrumb = module.af_consumer.big_b_breadcrumb
    small_c_breadcrumb = module.af_consumer.small_c_breadcrumb
  }
}

output "consumer_environment_summary" {
  description = "Environment summary from the consumer module"
  value = module.af_consumer.environment_summary
}
EOF

echo "✅ Created temporary main.tf to download consumer module"

# Run terraform init to fetch the root module
echo "🔄 Running $(TF) init to fetch the consumer module..."
$(TF) init

# Find the downloaded consumer module directory
MODULE_DIR=$(find .terraform/modules -name "af_consumer" -type d | head -1)
if [ -z "$MODULE_DIR" ]; then
    echo "❌ Could not find downloaded consumer module directory"
    echo "Available directories:"
    find .terraform/modules -type d -name "*af_consumer*"
    exit 1
fi

echo "📦 Found consumer module at: $MODULE_DIR"

# Remove the stub main.tf
echo "🗑️  Removing stub main.tf..."
rm -f main.tf

# Copy the consumer module contents to the current directory (making it the root module)
echo "📋 Copying consumer module contents to current directory..."
cp -r "$MODULE_DIR"/* .

# Remove the .terraform directory to clean up
echo "🧹 Cleaning up .terraform directory..."
rm -rf .terraform .terraform.lock.hcl

# Run terraform init again on the consumer module (now as root)
echo "🔄 Running $(TF) init on consumer module as root..."
$(TF) init

# Run terraform plan to get breadcrumb output
echo "📊 Running $(TF) plan to see breadcrumb output..."
$(TF) plan

echo ""
echo "🎉 Artifactory consumer module test completed successfully!"
echo "📊 Review the plan output above to see the direct module dependency breadcrumbs"
echo "✅ Consumer module running as root with all dependencies from Artifactory:"
echo "   - Consumer module: root v1.0.0 (running as root)"  
echo "   - Dependency modules: moduleBigA, moduleBigB, moduleSmallC, moduleSmallD v1.2.0"
echo "🧹 Run 'make clean' to remove the test-af-root directory" 
