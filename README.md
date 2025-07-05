# DevOptimize Terraform Demo Consumer

This Terraform root module demonstrates consuming Artifactory-published modules from the `devo_tf_demo_module` project.

## Overview

This consumer module references three modules from Artifactory:
- **moduleBigA** - depends on moduleSmallC and moduleSmallD
- **moduleBigB** - depends on moduleSmallC
- **moduleSmallC** - standalone module

## Module Sources

All modules are sourced from Artifactory using the following pattern:
```
devoptimize.jfrog.io/devo-terraform__devo_tf_demo_module/<MODULE-NAME>/aws
```

## Usage

### Using the Makefile (Recommended)

1. **Quick Start**: Run the full test cycle:
   ```bash
   make check
   ```

2. **Test Published Version**: Test the consumer module from Artifactory:
   ```bash
   make test-af
   ```

3. **Deploy if needed**:
   ```bash
   make apply
   ```

4. **View outputs**:
   ```bash
   make output
   ```

5. **Clean up**:
   ```bash
   make destroy
   make clean
   ```

### Manual Usage

1. **Configure Variables**: Copy the example variables file and customize:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your desired values
   ```

2. **Initialize Terraform**: 
   ```bash
   terraform init
   ```

3. **Plan Deployment**:
   ```bash
   terraform plan
   ```

4. **Apply Configuration**:
   ```bash
   terraform apply
   ```

### Available Make Targets

Run `make help` to see all available targets:
- `check` - Full test cycle (init, validate, plan)
- `apply` - Deploy the consumer module
- `destroy` - Destroy deployed resources
- `clean` - Clean up terraform cache files
- `output` - Display module outputs
- `format` - Format terraform files
- `publish` - Archive and upload consumer module to Artifactory
- `test-af` - Test the published consumer module from Artifactory

## Testing the Published Consumer Module

The `test-af` target allows you to test the complete Artifactory ecosystem by downloading and running the published consumer module:

```bash
make test-af
```

This runs the `af-root-consumer.sh` script which:
1. Creates a temporary `test-af-root/` directory
2. Downloads the consumer module from Artifactory using the registry format
3. Copies the consumer module files to use as the root module
4. Runs `terraform init` to download all dependency modules
5. Runs `terraform plan` to verify all modules load correctly and show breadcrumbs

The test demonstrates:
- ✅ Consumer module download from Artifactory (v1.0.0)
- ✅ Automatic dependency resolution for sub-modules (v1.2.0)
- ✅ Complete module chain functionality
- ✅ Breadcrumb outputs showing dependency verification

Clean up the test directory with:
```bash
make clean
```

## Publishing the Consumer Module

To publish this consumer module to Artifactory:

```bash
make publish VERSION=1.0.0
```

This will:
1. Create a zip archive of the consumer module files
2. Upload to Artifactory at: `devo-terraform/devo_tf_demo_cnsmr/devo_tf_demo_cnsmr/aws/1.0.0.zip`

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region for resources | `us-east-1` |
| `environment` | Environment name (e.g., dev, staging, prod) | `demo` |
| `big_a_name_prefix` | Name prefix for BigA module resources | `consumer-biga` |
| `big_b_name_prefix` | Name prefix for BigB module resources | `consumer-bigb` |
| `small_c_name_prefix` | Name prefix for SmallC module resources | `consumer-smallc` |

## Outputs

The module exposes various outputs from each referenced module:
- Module information and breadcrumbs
- Dependency status
- Resource prefixes
- Summary information

## Breadcrumbs

Each module includes breadcrumb outputs that will appear in `terraform plan` and `terraform apply` to demonstrate that modules and their dependencies are loaded properly from Artifactory.

## Module Dependencies

The dependency chain is:
- **BigA** → SmallC + SmallD (SmallD is loaded automatically as a dependency)
- **BigB** → SmallC
- **SmallC** → standalone

Note that SmallD is not directly referenced in this consumer but will be loaded automatically as a dependency of BigA. 
