# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "profile-aws" {
  description = "profile aws credentials"
  type        = string
  default     = "fiap-techallange" 
}