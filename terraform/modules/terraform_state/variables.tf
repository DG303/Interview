variable "bucket_name" {
  description = "Name of the bucket to put terraform state files"
}

variable "ddb_name" {
  description = "Name of dynamoDB table for locks"
}
