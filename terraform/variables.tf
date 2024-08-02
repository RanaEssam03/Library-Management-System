# Variable for User ARNs
variable "user_arns" {
  description = "List of IAM User ARNs allowed to assume the role"
  type        = list(string)
  default     = [
    "arn:aws:iam::637423483309:user/basma",
    "arn:aws:iam::637423483309:user/gamila",
    "arn:aws:iam::637423483309:user/farah"
  ]
}

# Tags Variable
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {
    Environment = "Production"
    Team        = "Team1"
  }
}

