/******************************************
	Required vars
 *****************************************/

variable "project_id" {
  type        = string
  description = "The ID of the project where the resources will be created"
}

variable "region" {
  type        = string
  description = "The region in which resources will be applied."
}

variable "service_account" {
  type        = string
  description = "Service account having the permission to resize the nodepool."
}

variable "target_uri" {
  type          = string
  description   = "URI of api target."
}

variable "job_name" {
  type        = string
  description = "The name of the scheduled job to run"
}

/******************************************
	Optional vars
 *****************************************/

variable "job_description" {
  type        = string
  description = "Addition text to describe the job"
  default     = ""
}

variable "job_schedule" {
  type        = string
  description = "The job frequency, in cron syntax"
  default     = "* * * * *"
}

variable "time_zone" {
  type        = string
  description = "The timezone to use in scheduler"
  default     = "Europe/Rome"
}

variable "scheduler_job" {
  type        = object({ name = string })
  description = "An existing Cloud Scheduler job instance"
  default     = null
}

variable "operation" {
  type        = string
  description = "Operation to start/stop the sql instance. The possible value are: ALWAYS/NEVER"
}