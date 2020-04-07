resource "aws_codebuild_project" "codebuild_build" {
  for_each = var.pipelines

  name          = "${var.product_name}-${each.value.repo}-build"
  description   = "terraform_codebuild_project"
  build_timeout = "10"
  service_role  = var.codebuild_role

  environment {
    privileged_mode             = true
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "489130170427.dkr.ecr.us-east-1.amazonaws.com/builder-image-skaffold:${var.builder_images_version}"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
  }

  artifacts {
    type     = var.source_type
    location = var.s3_bucket
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  source {
    type            = var.source_type
    location        = var.s3_bucket
    git_clone_depth = 1
    buildspec       = "buildspec-build.yaml"


    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "master"

  tags = {
    Product = var.product_name
  }
}

resource "aws_codebuild_project" "codebuild_staging" {
  for_each = var.pipelines

  name          = "${var.product_name}-${each.value.repo}-staging"
  description   = "terraform_codebuild_project"
  build_timeout = "10"
  service_role  = var.codebuild_role

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "489130170427.dkr.ecr.us-east-1.amazonaws.com/builder-image-skaffold:${var.builder_images_version}"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "STAGING_NAMESPACE"
      value = "${var.product_name}-staging"
    }
    environment_variable {
      name  = "ISTIO_DOMAIN"
      value = "${var.product_name}-staging.lead.prod.liatr.io"
    }
  }

  artifacts {
    name = ""
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  source {
    type            = var.source_type
    location        = var.s3_bucket
    git_clone_depth = 1
    buildspec       = "buildspec-staging.yaml"


    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "master"

  tags = {
    Product = var.product_name
  }
}

resource "aws_codebuild_project" "codebuild_production" {
  for_each = var.pipelines

  name          = "${var.product_name}-${each.value.repo}-production"
  description   = "terraform_codebuild_project"
  build_timeout = "10"
  service_role  = var.codebuild_role

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "489130170427.dkr.ecr.us-east-1.amazonaws.com/builder-image-skaffold:${var.builder_images_version}"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "STAGING_NAMESPACE"
      value = "${var.product_name}-staging"
    }
    environment_variable {
      name  = "ISTIO_DOMAIN"
      value = "${var.product_name}-staging.lead.prod.liatr.io"
    }
  }

  artifacts {
    name = ""
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  source {
    type            = var.source_type
    location        = var.s3_bucket
    git_clone_depth = 1
    buildspec       = "buildspec-production.yaml"


    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "master"

  tags = {
    Product = var.product_name
  }
}

resource "aws_codepipeline" "codepipeline" {
  for_each = var.pipelines

  name     = "${var.product_name}-${each.value.repo}"
  role_arn = var.codepipeline_role

  artifact_store {
    location = var.s3_bucket
    type     = "S3"

  }

  stage {
    name = "Source"

    action {
      name     = "Source"
      category = "Source"
      owner    = "AWS"
      provider = "CodeCommit"
      version  = "1"

      configuration = {
        RepositoryName = "${var.product_name}-${each.value.repo}"
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.codebuild_build[each.key].id}"
      }
    }
  }

  stage {
    name = "Staging"

    action {
      name            = "Staging"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.codebuild_staging[each.key].id}"
      }
    }
  }

  stage {
    name = "Approve"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }

  stage {
    name = "Production"

    action {
      name            = "Production"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.codebuild_production[each.key].id}"
      }
    }
  }
}
