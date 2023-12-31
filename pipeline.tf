resource "aws_codebuild_project" "tf-plan" {
  name          = "NewConsoleProjectBuild"
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
    buildspec = "buildspec.yml"
  }

 
}
resource "aws_codebuild_project" "tf-plan-dotnet" {
  name          = "ConsoleBuild"
  description   = "stage for Terraform"
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
    buildspec = "buildspec.yml"
  }

 
}

resource "aws_codedeploy_app" "code_deploy" {
  name          = "NewConsoleAppDeployment"
  compute_platform = "Server"
}
resource "aws_codedeploy_deployment_group" "DeployGroup" {
  app_name               = "NewConsoleAppDeployment"
  deployment_group_name  = "NewConsoleAppDeploymentGroup"
  service_role_arn = aws_iam_role.codedeploy_role.arn 
  deployment_config_name = "CodeDeployDefault.AllAtOnce"


  
  # Use the tags to identify the EC2 instance
  ec2_tag_set {
    ec2_tag_filter {
      key    = "Name"
      value  = "ConsoleInstance"
      type   = "KEY_AND_VALUE"
    }

   

  }
}



resource "aws_codepipeline" "cicd_pipeline" {

    name = "NewGitPipelineConsoleApplication"
    role_arn = aws_iam_role.tf-codepipeline-role.arn

    artifact_store {
        type="S3"
        location = aws_s3_bucket.codepipeline_artifacts.id

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
                FullRepositoryId = "PradeepaLakshmanan-CH-2022/AWsConsoleApplication"
                BranchName   = "main"
                ConnectionArn=var.codestar_connector_credentials
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
                ProjectName = "NewConsoleProjectBuild"
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
      ApplicationName  = "NewConsoleAppDeployment"
      DeploymentGroupName = "NewConsoleAppDeploymentGroup"
  
    }
  }
}


}
resource "aws_codebuild_project" "tf-plan-console" {
  name          = "tf-cicd-plan2"
  description   = "Plan stage for terraform"
  service_role  = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:1.4.6"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential{
        credential = var.dockerhub_credentials
        credential_provider = "SECRETS_MANAGER"
    }
 }
 source {
     type   = "CODEPIPELINE"
     buildspec = file("buildspec.yml")
 }
}


resource "aws_codepipeline" "cicd_pipeline_tf" {

    name = "tf-cicd"
    role_arn = aws_iam_role.tf-codepipeline-role.arn

    artifact_store {
        type="S3"
        location = aws_s3_bucket.codepipeline_artifacts.id
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
                FullRepositoryId = "PradeepaLakshmanan-CH-2022/TerraformRepo"
                BranchName   = "main"
                ConnectionArn=var.codestar_connector_credentials
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
                ProjectName = "tf-cicd-plan2"
            }
        }
    }

 

}
resource "aws_codepipeline" "Mypipelinecicd_terraform" {

    name = "Mytf-cicdpipeline"
    role_arn = aws_iam_role.tf-codepipeline-role.arn

    artifact_store {
        type="S3"
        location = aws_s3_bucket.codepipeline_artifacts.id
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
                FullRepositoryId = "PradeepaLakshmanan-CH-2022/TerraformRepo"
                BranchName   = "main"
                ConnectionArn=var.codestar_connector_credentials
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
                ProjectName = "tf-cicd-plan2"
            }
        }
    }

 

}
