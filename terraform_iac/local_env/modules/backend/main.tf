variable "express_app_name" {
  type = string
}

variable "express_hostname" {
  type = string
}

variable "express_port" {
  type = number
}

variable "network_name" {
  type = string
}

variable "docker_tag" {
  type = string
}

variable "express_be_folder_location" {
  type = string
}

resource "docker_image" "express_be_image" {
  name = var.express_app_name
  build {
    context = "${var.express_be_folder_location}/."
    tag = ["${var.express_app_name}:${var.docker_tag}"]
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "${var.express_be_folder_location}/src/*") : filesha1(f)]))
  }
}

resource "docker_container" "express_app" {
  name  = var.express_app_name
  image = docker_image.express_be_image.image_id
  networks_advanced {
    name = var.network_name
  }
  hostname = var.express_hostname
  labels {
    label = var.express_app_name
    value = "container"
  }
  ports {
    internal = var.express_port
    external = var.express_port
  }
}