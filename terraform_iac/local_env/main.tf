resource "docker_network" "react_2_express_network" {
  name = var.network_name
  ipam_config {
    subnet = "172.10.0.0/16"
  }
}

module "express_app" {
  source = "./modules/backend"
  express_app_name = var.express_app_name
  express_hostname = var.express_hostname
  express_port = var.express_port
  network_name = var.network_name
  docker_tag = var.docker_tag
  express_be_folder_location = var.express_be_folder_location
}

module "react_app" {
  source = "./modules/frontend"
  react_app_name = var.react_app_name
  react_port = var.react_port
  network_name = var.network_name
  docker_tag = var.docker_tag
  react_fe_folder_location = var.react_fe_folder_location
}