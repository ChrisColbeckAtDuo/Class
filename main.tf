resource "google_compute_instance" "demo" {
  count        = var.number_of_demo_instances
  name         = "web-instance-${count.index}"
  machine_type = "e2-small"
  zone         = "us-west1-a"
  metadata = {
   ssh-keys = "ubuntu:${file("/opt/bitnami/jenkins/jenkins_home/tf-key.pub")}"
}

  # boot disk specifications
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts" 
    }
  }

// Make sure flask is installed on all new instances for later steps
 metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python3-pip nginx; pip3 install flask"

  # networks to attach to the VM
  network_interface {
    network = "default"
    access_config {} // use ephemeral public IP
  }
}

resource "google_compute_firewall" "demo" {
  name    = "allow-gce-tcp-80"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}

output "web_vm_ip" {
  value = [google_compute_instance.demo.*.network_interface.0.access_config.0.nat_ip]
}
