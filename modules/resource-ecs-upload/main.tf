# module for uploading image to ecr / can be reused 

resource "aws_ecr_repository" "image" {
  name = "${var.REPO_NAME}"
}

# null_resource to pull the image and tag it

resource "null_resource" "pull-image" {
  provisioner "local-exec" {
    command = "docker image pull ${var.IMAGE}"
  }

  depends_on = ["aws_ecr_repository.image"]
}

resource "null_resource" "tag-image" {
  provisioner "local-exec" {
    command = "docker image tag ${var.IMAGE} ${aws_ecr_repository.image.repository_url}:${var.TAG}"
  }

  depends_on = ["null_resource.pull-image"]
}

resource "null_resource" "push-image" {
  provisioner "local-exec" {
    command = "docker image push  ${aws_ecr_repository.image.repository_url}:${var.TAG}"
  }

  depends_on = ["null_resource.tag-image"]
}
