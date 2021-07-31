
resource "aws_codebuild_project" "tf-plan" {
  name = "tf-cicd-plan"
  description = "codebuild_project"
  build_timeout = "5"
  service_role = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
   # image = "hashicorp/terraform:latest"
    image = "aws/codebuild/standard:1.0"
    type = "LINUX_CONTAINER"
  #  image_pull_credentials_type = "SERVICE_ROLE"
    image_pull_credentials_type = "CODEBUILD"
/*
    registry_credential {
      credential = var.docker_credentials
      credential_provider = "SECRETS_MANAGER"
    }
*/
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("buildspec/plan-buildspec.yml")
  }


}

resource "aws_codebuild_project" "tf-apply" {
  name = "tf-cicd-apply"
  description = "codebuild_project"
  build_timeout = "5"
  service_role = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
   # image = "hashicorp/terraform:latest"
    image = "aws/codebuild/standard:1.0"
    type = "LINUX_CONTAINER"
   # image_pull_credentials_type = "SERVICE_ROLE"
    image_pull_credentials_type = "CODEBUILD"

/*
    registry_credential {
      credential = var.docker_credentials
      credential_provider = "SECRETS_MANAGER"
    }
*/
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("buildspec/apply-buildspec.yml")
  }


}


resource "aws_codepipeline" "cicd_pipeline" {

  name = "tf-cicd"
  role_arn = aws_iam_role.tf-codepipeline-role.arn

  artifact_store {
    type="S3"
    location = aws_s3_bucket.pipeline-artifacts.id
  }

  stage {
    name = "Source"
    action{
        name = "Source"
        category = "Source"
        owner = "AWS"
        provider = "CodeStarSourceConnection"
        version = "1"
        output_artifacts = ["tf-code"]

        configuration = {
          FullRepositoryId = "pravinbangar21/tf-cicd-pravin2"
          BranchName   = "master"
          ConnectionArn = var.codestar_credentials
          OutputArtifactFormat = "CODE_ZIP"
        }
      }
    }

    stage {
      name ="Plan"
      action{
        name = "Build"
        category = "Build"
        provider = "CodeBuild"
        version = "1"
        owner = "AWS"
        input_artifacts = ["tf-code"]

        configuration = {
          ProjectName = "tf-cicd-plan"
        }
      }
    }

    stage {
      name ="Deploy"

      action{
        name = "Deploy"
        category = "Build"
        provider = "CodeBuild"
        version = "1"
        owner = "AWS"
        input_artifacts = ["tf-code"]

        configuration = {
          ProjectName = "tf-cicd-apply"
      }

      }
  }

}
