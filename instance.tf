
resource "aws_instance" "pipelineinstance" {
  ami           = "ami-04132f301c3e4f138"
  instance_type = "t2.micro"
  key_name = "NewEC2pair"
  

    
  tags = {
    Name = "ConsoleEc2"
    
  }
   
}
