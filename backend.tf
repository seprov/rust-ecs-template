terraform {
  backend "s3" {
    bucket = "seprov-np-us-east-1-rq-backend"
    key    = "_.tfstate"
    region = "us-east-1"
  }
}
