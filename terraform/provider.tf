# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.79.0"
    }
  }


  required_version = ">= 0.13"
    backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "diplom-s3-backet"
    key        = "state/terraform.tfstate"
    access_key = ""
    secret_key = ""
    region     = "ru-central1-a"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  cloud_id                 = "${var.yandex_cloud_id}"
  folder_id                = "${var.yandex_folder_id}"
  service_account_key_file = "${var.yandex_key}"
}


