variable "react_app_name" {
  type = string
}

variable "network_name" {
  type = string
}

variable "react_port" {
  type = string
}

variable "docker_tag" {
  type = string
}

variable "react_fe_folder_location" {
  type = string
}

resource "docker_image" "react_fe_image" {
  name = var.react_app_name
  build {
    context = "${var.react_fe_folder_location}/."
    tag = ["${var.react_app_name}:${var.docker_tag}"]
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "${var.react_fe_folder_location}/src/*") : filesha1(f)]))
  }
}

resource "docker_container" "react_app" {
  name  = var.react_app_name
  image = docker_image.react_fe_image.image_id
  networks_advanced {
    name = var.network_name
  }
  labels {
    label = var.react_app_name
    value = "container"
  }
  ports {
    internal = var.react_port
    external = var.react_port
  }
}