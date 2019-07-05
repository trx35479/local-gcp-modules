# ECS deployment

provider "aws" {
  region = "ap-southeast-2"
}

module "ecr-1" {
  source = "modules/resource-ecs-upload"

  REPO_NAME = "fleetman-global-config-server"
  IMAGE     = "virtualpairprogrammers/fleetman-global-config-server"
  TAG       = "microservice"
}

module "ecr-2" {
  source = "modules/resource-ecs-upload"

  REPO_NAME = "fleetman-queue"
  IMAGE     = "virtualpairprogrammers/fleetman-queue"
  TAG       = "latest"
}

module "ecr-3" {
  source = "modules/resource-ecs-upload"

  REPO_NAME = "fleetman-registry"
  IMAGE     = "virtualpairprogrammers/fleetman-registry"
  TAG       = "microservice"
}

module "ecr-4" {
  source = "modules/resource-ecs-upload"

  REPO_NAME = "fleetman-webapp"
  IMAGE     = "virtualpairprogrammers/fleetman-webapp"
  TAG       = "microservice"
}

module "ecr-5" {
  source = "modules/resource-ecs-upload"

  REPO_NAME = "fleetman-position-simulator"
  IMAGE     = "virtualpairprogrammers/fleetman-position-simulator"
  TAG       = "microservice"
}

module "ecr-6" {
  source = "modules/resource-ecs-upload"

  REPO_NAME = "fleetman-position-tracker"
  IMAGE     = "virtualpairprogrammers/fleetman-position-tracker"
  TAG       = "microservice"
}
