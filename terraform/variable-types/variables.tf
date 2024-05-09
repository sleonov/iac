# https://developer.hashicorp.com/terraform/language/expressions/type-constraints
# Primitive Types: number, string, bool
# -------------------------------------
# number
variable "IntNumber" {
  type    = number
  default = 10
}
variable "FloatNumber" {
  type    = number
  default = 10.999
}

# string
variable "String" {
  type    = string
  default = "I am a string"
}

# bool
variable "Boolean" {
  type    = bool
  default = true
}

# Collection Types: list, map, set
# --------------------------------
# list (all elements should be the same type)
variable "ListOfNumbers" {
  type    = list(number)
  default = [10, 20]
}
variable "ListOfAny" {
  type    = list(any)
  default = [10, "10", false]
}

# map (all values must be the same type)
variable "Map1" {
  type = map(number)
  default = {
    "us-east-1" = 1
    "eu-west-2" = 2
  }
}

# set (all values must be the same type)
# in the below example all will be converted to strings, and de-duplicated
variable "Set1" {
  type    = set(any)
  default = ["1", 1, "two", false] # ["1", "two", "false"]
}

# Structural Types: object, tuple
# object
# Values that match the object type must contain all of the specified keys,
# and the value for each key must match its specified type.
variable "ObjectEmployee" {
  type    = object({ name = string, age = number })
  default = { name = "Joe", age = 52 }
}

# tuple
# Values that match the tuple type must have exactly the same number of elements (no more and no fewer)
variable "Tuple" {
  type    = tuple([number, string, bool])
  default = [15, "Minsk", true]
}