# Makefile for DevOptimize Terraform Demo Consumer
# Provides targets for testing consumer module that references Artifactory modules
#
# Usage:
#   1. Test configuration: make check
#   2. Clean up:          make clean
#   3. Initialize only:   make init
#   4. Plan only:         make plan

# Variables
TERRAFORM_DIR = .
CONSUMER_NAME = root
ARTIFACTORY_REPO = devo-terraform
ARTIFACTORY_BASE_URL = https://devoptimize.jfrog.io/artifactory
NAMESPACE = devo_tf_demo_cnsmr
PROVIDER = aws
VERSION ?= 1.0.0

# Terraform/OpenTofu selection (default to tofu)
TF ?= tofu

# Default target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  check      - Initialize and run $(TF) plan"
	@echo "  init       - Initialize $(TF) (download modules)"
	@echo "  plan       - Run $(TF) plan"
	@echo "  apply      - Run $(TF) apply"
	@echo "  output     - Show $(TF) outputs"
	@echo "  validate   - Validate $(TF) configuration"
	@echo "  clean      - Clean up $(TF) artifacts"
	@echo "  format     - Format $(TF) files"
	@echo "  publish    - Archive and upload consumer module to Artifactory (VERSION=x.y.z)"
	@echo "  archive    - Create zip archive of consumer module"
	@echo "  upload     - Upload archived consumer module to Artifactory"
	@echo "  check-creds - Verify Artifactory credentials are configured"
	@echo "  test-af    - Run af-root-consumer.sh to test the published consumer module"
	@echo ""
	@echo "Variables:"
	@echo "  TF         - Terraform/OpenTofu binary to use (default: tofu)"
	@echo "  VERSION    - Version for publishing (default: 1.0.0)"

# Initialize terraform
.PHONY: init
init:
	@echo "Initializing $(TF)..."
	@$(TF) init

# Validate terraform configuration
.PHONY: validate
validate: init
	@echo "Validating $(TF) configuration..."
	@$(TF) validate

# Run terraform plan
.PHONY: plan
plan: validate
	@echo "Running $(TF) plan..."
	@$(TF) plan

# Run terraform apply
.PHONY: apply
apply: validate
	@echo "Running $(TF) apply..."
	@$(TF) apply -auto-approve

# Show terraform outputs
.PHONY: output
output:
	@echo "Showing $(TF) outputs..."
	@$(TF) output

# Format terraform files
.PHONY: format
format:
	@echo "Formatting $(TF) files..."
	@$(TF) fmt

# Main check target - validates and plans
.PHONY: check
check: plan
	@echo ""
	@echo "✅ Consumer module testing complete!"
	@echo "📊 Review the plan output above to see module dependency breadcrumbs"
	@echo "🧹 Run 'make clean' to remove terraform artifacts"

# Clean up terraform artifacts
.PHONY: clean
clean:
	@echo "Cleaning up $(TF) artifacts..."
	@rm -rf .terraform/
	@rm -f .terraform.lock.hcl
	@rm -f .tofu.lock.hcl
	@rm -f terraform.tfstate*
	@rm -f *.tofu.tfstate*
	@rm -f terraform.tfplan
	@rm -f *.tofu.tfplan
	@rm -rf build/
	@rm -rf test-af-root/
	@echo "✅ Cleanup complete!"

# Destroy resources (if any were created)
.PHONY: destroy
destroy:
	@echo "Destroying $(TF) resources..."
	@$(TF) destroy -auto-approve

# Check if Artifactory credentials are configured
.PHONY: check-creds
check-creds:
	@echo "Checking Artifactory credentials..."
	@if [ -z "$$ARTIFACTORY_USER" ]; then \
		echo "❌ ARTIFACTORY_USER environment variable not set"; \
		echo "   Set with: export ARTIFACTORY_USER=your-username"; \
		exit 1; \
	fi
	@if [ -z "$$ARTIFACTORY_PASSWORD" ] && [ -z "$$ARTIFACTORY_API_KEY" ]; then \
		echo "❌ Neither ARTIFACTORY_PASSWORD nor ARTIFACTORY_API_KEY environment variable set"; \
		echo "   Set with: export ARTIFACTORY_PASSWORD=your-password"; \
		echo "   Or with:  export ARTIFACTORY_API_KEY=your-api-key"; \
		exit 1; \
	fi
	@echo "✅ Artifactory credentials configured"

# Create zip archive of consumer module
.PHONY: archive
archive:
	@echo "Creating consumer module archive for version $(VERSION)..."
	@mkdir -p build
	@echo "Archiving $(CONSUMER_NAME)..."
	@zip -r build/$(CONSUMER_NAME)-$(VERSION).zip . -x ".terraform/*" ".terraform.*" "terraform.tfstate*" "*.tfplan" "build/*" ".git/*"
	@echo "✅ Archive created: build/$(CONSUMER_NAME)-$(VERSION).zip"

# Upload archived consumer module to Artifactory
.PHONY: upload
upload: check-creds archive
	@echo "Uploading consumer module to Artifactory..."
	@if [ -n "$$ARTIFACTORY_API_KEY" ]; then \
		AUTH_HEADER="X-JFrog-Art-Api: $$ARTIFACTORY_API_KEY"; \
	else \
		AUTH_HEADER="Authorization: Basic $$(echo -n $$ARTIFACTORY_USER:$$ARTIFACTORY_PASSWORD | base64)"; \
	fi; \
	echo "Uploading $(CONSUMER_NAME) version $(VERSION)..."; \
	curl -H "$$AUTH_HEADER" \
		-X PUT \
		-T build/$(CONSUMER_NAME)-$(VERSION).zip \
		"$(ARTIFACTORY_BASE_URL)/$(ARTIFACTORY_REPO)/$(NAMESPACE)/$(CONSUMER_NAME)/$(PROVIDER)/$(VERSION).zip"; \
	echo ""; \
	echo "✅ Upload complete!"

# Main publish target
.PHONY: publish
publish: upload
	@echo ""
	@echo "🎉 Successfully published consumer module to Artifactory!"
	@echo "📦 Consumer module published:"
	@echo "   - $(CONSUMER_NAME) version $(VERSION)"
	@echo "🔗 Download URL:"
	@echo "   - $(ARTIFACTORY_BASE_URL)/$(ARTIFACTORY_REPO)/$(NAMESPACE)/$(CONSUMER_NAME)/$(PROVIDER)/$(VERSION).zip"
	@echo ""
	@echo "Usage in other repositories:"
	@echo "source = \"$(ARTIFACTORY_BASE_URL)/$(ARTIFACTORY_REPO)/$(NAMESPACE)/$(CONSUMER_NAME)/$(PROVIDER)/$(VERSION).zip\""

# Test the published consumer module using af-root-consumer.sh
.PHONY: test-af
test-af:
	@echo "🚀 Testing published consumer module from Artifactory..."
	@bash af-root-consumer.sh

# Show status
.PHONY: status
status:
	@echo "$(TF) status:"
	@echo "  Working directory: $(TERRAFORM_DIR)"
	@echo "  $(TF) version: $$($(TF) version -json 2>/dev/null | jq -r '.terraform_version' 2>/dev/null || $(TF) version | head -1)"
	@echo "  Initialized: $$(test -d .terraform && echo "✓ Yes" || echo "✗ No")"
	@echo "  Lock file exists: $$(test -f .terraform.lock.hcl && echo "✓ Yes" || echo "✗ No")"
	@echo "  State file exists: $$(test -f terraform.tfstate && echo "✓ Yes" || echo "✗ No")" 
