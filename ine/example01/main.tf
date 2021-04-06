provider "aws" {
    region = "eu-west-1"
}

// in the second "" we give the bucket an identifier
// this is only for use inside terraform projects
// not actually used inside aws
resource "aws_s3_bucket" "my_bucket" {
    bucket = "arsh-myfirst-bucket" // bucket name, global unique identifier for the bucket
}
