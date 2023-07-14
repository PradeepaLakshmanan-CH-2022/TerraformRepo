resource "aws_codebuild_project" "tf-plan" {
  name          = "BuildAppConsole"
  description   = "Plan stage for Terraform"
  service_role  = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
  }

  source {
    type   = "CODEPIPELINE"
     # Specify the buildspec file location
    buildspec = "buildspec.yml"
  }

 
}

resource "aws_codedeploy_app" "code_deploy" {
  name          = "Deployproject"
  compute_platform = "Server"
}
resource "aws_codedeploy_deployment_group" "DeployGroup" {
  app_name               = "Deployproject"
  deployment_group_name  = "DeployprojectGroup"
  service_role_arn      ="arn:aws:iam::606104556660:role/CodeDeployRoleForEc2"  
  deployment_config_name = "CodeDeployDefault.AllAtOnce"


  
  # Use the tags to identify the EC2 instance
  ec2_tag_set {
    ec2_tag_filter {
      key    = "Name"
      value  = "HTmlec2"
      type   = "KEY_AND_VALUE"
    }

   

  }
}



resource "aws_codepipeline" "cicd_pipeline" {

    name = "CICDConsole"
    role_arn = aws_iam_role.tf-codepipeline-role.arn

    artifact_store {
        type="S3"
        location = aws_s3_bucket.codepipeline_artifacts.id
       // location = aws_s3_bucket.codepipeline_artifacts.id

    }

   stage {
    name = "Source"

    action {
      name            = "Source"
      category        = "Source"
      owner           = "AWS"
      provider        = "CodeStarSourceConnection"
      version         = "1"
            output_artifacts = ["SourceArtifact"]
            configuration = {
                FullRepositoryId = "PradeepaLakshmanan-CH-2022/TerraformPipeline"
                BranchName   = "main"
                ConnectionArn=var.codestar_connector_credentials
               // ConnectionArn = var.codestar_connector_credentials
                OutputArtifactFormat = "CODE_ZIP"
            }
        }
    }

    stage {
        name ="Build"
        action{
            name = "BuildAction"
            category = "Build"
            owner = "AWS"
            provider = "CodeBuild"
            version = "1"          
            input_artifacts = ["SourceArtifact"]
            output_artifacts = ["BuildArtifact"]
            configuration = {
                ProjectName = "BuildAppConsole"
            }
        }
    }

 stage {
  name = "Deploy"

  action {
    name            = "DeployEC2"
    category        = "Deploy"
    owner           = "AWS"
    provider        = "CodeDeploy"
    version = "1"
    run_order       = 1
    input_artifacts = ["BuildArtifact"]

    configuration = {
      ApplicationName  = "Deployproject"
      DeploymentGroupName = "DeployprojectGroup"
  
    }
  }
}


}
