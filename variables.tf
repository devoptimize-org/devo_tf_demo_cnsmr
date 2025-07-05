variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "demo"
}

variable "big_a_name_prefix" {
  description = "Name prefix for BigA module resources"
  type        = string
  default     = "consumer-biga"
}

variable "big_b_name_prefix" {
  description = "Name prefix for BigB module resources"
  type        = string
  default     = "consumer-bigb"
}

variable "small_c_name_prefix" {
  description = "Name prefix for SmallC module resources"
  type        = string
  default     = "consumer-smallc"
} 