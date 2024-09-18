#------------
# Base Config
#------------
variable "project_id" {
  description = "(Required) Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "Default region to create the resource"
  type        = string
  default     = "asia-northeast1"
}

variable "zone" {
  description = "Default zone to create the resource"
  type        = string
  default     = "asia-northeast1-a"
}
