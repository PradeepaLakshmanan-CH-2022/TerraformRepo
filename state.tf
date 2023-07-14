terraform{
    backend "s3" {
        bucket = "mybucketforconsole"
        encrypt = true
        key = "terraform.tfstate"
        region = "us-east-1"
    }
}




