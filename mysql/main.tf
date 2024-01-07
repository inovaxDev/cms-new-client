terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

data "google_sql_database_instance" "cms_instance" {
  name = var.mysql_server_instance_name
}

resource "google_sql_database" "client_database" {
  name      = "${var.client_name}-cms"
  instance  = data.google_sql_database_instance.cms_instance.name
  charset   = "utf8"
  collation = "utf8_general_ci"
}

resource "google_sql_user" "client_admin_user" {
  name     = "${var.client_name}-cms-${random_id.db_name_suffix.hex}"
  password = var.db_password
  instance = data.google_sql_database_instance.cms_instance.name

  depends_on = [google_sql_database.client_database]
}

output "database_connection_url" {
  value = "mysql://${google_sql_user.client_admin_user.name}:${google_sql_user.client_admin_user.password}@${data.google_sql_database_instance.cms_instance.private_ip_address}:3306/${google_sql_database.client_database.name}"
}
