resource "google_compute_instance" "airflow" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.vm_image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
    apt-get update -y
    apt-get install -y docker-ce docker-compose

    # Create Airflow Docker setup
    mkdir /opt/airflow
    cd /opt/airflow

    cat <<EOF > docker-compose.yaml
    version: '3'
    services:
      airflow:
        image: apache/airflow:2.9.1
        restart: always
        environment:
          - AIRFLOW__CORE__EXECUTOR=SequentialExecutor
          - AIRFLOW__CORE__LOAD_EXAMPLES=False
        ports:
          - "8080:8080"
        command: webserver
    EOF

    docker-compose up -d
  EOT
}