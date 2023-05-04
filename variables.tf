variable "ami" {
  default = "ami-05f998315cca9bfe3"
}

variable "instance_type" {
  default = "t2.small"

}

variable "naming" {
  type = list(string)
  default = ["a"]
}
