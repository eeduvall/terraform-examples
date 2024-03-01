variable "network_name" {
  type = string
  description = "Network name between the react and express app"
  default = "react_2_express"
}

variable "express_app_name" {
  type = string
  description = "Name for the image and container of the express app"
  default = "express_be"
}

variable "react_app_name" {
  type = string
  description = "Name for the image and container of the react app"
  default = "react_fe"
}

variable "express_port" {
  type = number
  description = "Port number of the express app"
  default = 3001
}

variable "react_port" {
  type = number
  description = "Port number of the react app"
  default = 3000
}

variable "docker_tag" {
  type = string
  description = "Tag for the docker image"
  default = "dev"
}

variable "express_hostname" {
  type = string
  description = "Docker hostname of the express app"
  default = "express.be.com"
}

variable "express_be_folder_location" {
  type = string
  description = "Relative or absolute path to the Express BE folder with no ending slash"
  default = "../../express_backend"
}

variable "react_fe_folder_location" {
  type = string
  description = "Relative or absolute path to the React FE folder with no ending slash"
  default = "../../react_frontend"
}