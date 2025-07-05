# Outputs from BigA module
output "big_a_module_info" {
  description = "Information about BigA module"
  value       = module.big_a.module_info
}

output "big_a_breadcrumb" {
  description = "Breadcrumb from BigA module"
  value       = module.big_a.breadcrumb
}

output "big_a_dependency_status" {
  description = "Dependency status from BigA module"
  value       = module.big_a.dependency_status
}

output "big_a_resource_prefix" {
  description = "Resource prefix from BigA module"
  value       = module.big_a.resource_prefix
}

# Outputs from BigB module
output "big_b_module_info" {
  description = "Information about BigB module"
  value       = module.big_b.module_info
}

output "big_b_breadcrumb" {
  description = "Breadcrumb from BigB module"
  value       = module.big_b.breadcrumb
}

output "big_b_dependency_status" {
  description = "Dependency status from BigB module"
  value       = module.big_b.dependency_status
}

output "big_b_resource_prefix" {
  description = "Resource prefix from BigB module"
  value       = module.big_b.resource_prefix
}

# Outputs from SmallC module
output "small_c_module_info" {
  description = "Information about SmallC module"
  value       = module.small_c.module_info
}

output "small_c_breadcrumb" {
  description = "Breadcrumb from SmallC module"
  value       = module.small_c.breadcrumb
}

output "small_c_resource_prefix" {
  description = "Resource prefix from SmallC module"
  value       = module.small_c.resource_prefix
}

# Summary outputs
output "all_module_breadcrumbs" {
  description = "All module breadcrumbs for verification"
  value = {
    big_a   = module.big_a.breadcrumb
    big_b   = module.big_b.breadcrumb
    small_c = module.small_c.breadcrumb
  }
}

output "environment_summary" {
  description = "Summary of environment configuration"
  value = {
    environment = var.environment
    aws_region  = var.aws_region
    modules_loaded = [
      "moduleBigA",
      "moduleBigB",
      "moduleSmallC"
    ]
  }
} 