data "aws_vpc" "lead_vpc" {
  tags = {
    Name = "${var.aws_environment}-lead-vpc"
  }
}

// builds will run in the subnet originally created for eks workers, since these subnets are large enough
data "aws_subnet_ids" "eks_workers" {
  vpc_id = data.aws_vpc.lead_vpc.id

  filter {
    name = "tag:subnet-kind"
    values = [
      "private"
    ]
  }

  filter {
    name = "cidr-block"
    values = [
      "*/18"
    ]
  }
}

resource "aws_codebuild_project" "codebuild_build" {
  for_each = var.pipelines

  name          = replace("${var.product_name}-${each.value.repo}-build", "/^${var.product_name}-${var.product_name}/", var.product_name)
  description   = "terraform_codebuild_project"
  build_timeout = "20"
  service_role  = var.codebuild_role

  environment {
    privileged_mode             = true
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "${var.toolchain_image_repo}/builder-image-skaffold:${var.builder_images_version}"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "SKAFFOLD_DEFAULT_REPO"
      value = "${var.product_image_repo}/${var.product_name}"
    }
    environment_variable {
      name  = "REGION"
      value = var.region
    }
    environment_variable {
      name  = "PRODUCT_IMAGE_REPO"
      value = var.product_image_repo
    }
  }

  artifacts {
    type                = var.source_type
    location            = var.s3_bucket
    artifact_identifier = "build_output"
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

  vpc_config {
    security_group_ids = [
      var.codebuild_security_group_id
    ]
    subnets = sort(data.aws_subnet_ids.eks_workers.ids)
    vpc_id  = data.aws_vpc.lead_vpc.id
  }
}

resource "aws_codebuild_project" "codebuild_staging" {
  for_each = var.pipelines

  name          = replace("${var.product_name}-${each.value.repo}-staging", "/^${var.product_name}-${var.product_name}/", var.product_name)
  description   = "terraform_codebuild_project"
  build_timeout = "10"
  service_role  = var.codebuild_role

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "${var.toolchain_image_repo}/builder-image-skaffold:${var.builder_images_version}"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "STAGING_NAMESPACE"
      value = "${var.product_name}-staging"
    }
    environment_variable {
      name  = "ISTIO_DOMAIN"
      value = "staging.apps.${var.cluster_domain}"
    }
    environment_variable {
      name  = "PRODUCT_NAME"
      value = var.product_name
    }
    environment_variable {
      name  = "CLUSTER"
      value = var.cluster
    }
  }

  artifacts {
    type = var.source_type
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

  vpc_config {
    security_group_ids = [
      var.codebuild_security_group_id
    ]
    subnets = sort(data.aws_subnet_ids.eks_workers.ids)
    vpc_id  = data.aws_vpc.lead_vpc.id
  }
}

resource "aws_codebuild_project" "codebuild_production" {
  for_each = var.pipelines

  name          = replace("${var.product_name}-${each.value.repo}-production", "/^${var.product_name}-${var.product_name}/", var.product_name)
  description   = "terraform_codebuild_project"
  build_timeout = "10"
  service_role  = var.codebuild_role

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "${var.toolchain_image_repo}/builder-image-skaffold:${var.builder_images_version}"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "PROD_NAMESPACE"
      value = "${var.product_name}-production"
    }
    environment_variable {
      name  = "ISTIO_DOMAIN"
      value = "prod.apps.${var.cluster_domain}"
    }
    environment_variable {
      name  = "PRODUCT_NAME"
      value = var.product_name
    }
    environment_variable {
      name  = "CLUSTER"
      value = var.cluster
    }
  }

  artifacts {
    type = var.source_type
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  source {
    type            = var.source_type
    location        = var.s3_bucket
    git_clone_depth = 1
    buildspec       = "buildspec-prod.yaml"
    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "master"

  tags = {
    Product = var.product_name
  }

  vpc_config {
    security_group_ids = [
      var.codebuild_security_group_id
    ]
    subnets = sort(data.aws_subnet_ids.eks_workers.ids)
    vpc_id  = data.aws_vpc.lead_vpc.id
  }
}

resource "aws_codepipeline" "codepipeline" {
  for_each = var.pipelines

  name     = replace("${var.product_name}-${each.value.repo}", "/^${var.product_name}-${var.product_name}/", var.product_name)
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
      output_artifacts = [
        "source_output"
      ]

      configuration = {
        RepositoryName = replace("${var.product_name}-${each.value.repo}", "/^${var.product_name}-${var.product_name}/", var.product_name)
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      input_artifacts = [
        "source_output"
      ]
      output_artifacts = [
        "build_output"
      ]
      version = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_build[each.key].id
      }
    }
  }

  stage {
    name = "Staging"

    action {
      name     = "Staging"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      input_artifacts = [
        "build_output"
      ]
      version = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_staging[each.key].id
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
      name     = "Production"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      input_artifacts = [
        "build_output"
      ]
      version = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_production[each.key].id
      }
    }
  }

  tags = {
    Product = var.product_name
  }
}
