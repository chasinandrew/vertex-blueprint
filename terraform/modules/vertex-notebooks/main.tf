resource "random_id" "instance_random_suffix" {
  byte_length = 3
}

locals {
  userid   = split("@", var.instance_owner)[0]
  mlops_sa = format("%s-%s", var.project_id, "mlops")

  notebook_instance_name = format("%s-%s-%s-%s-%s-%s",
    "gcp",
    var.labels.region,
    var.labels.app_code,
    "un",
    random_id.instance_random_suffix.hex,
    local.userid,
  )
  service_account_id = format("%s-%s-%s-%s-%s",
    "gcp",
    var.labels.app_code,
    "un",
    random_id.instance_random_suffix.hex,
    local.userid,
  )
  metadata = {
    install-monitoring-agent  = true
    report-system-health      = true
    report-notebook-metrics   = true
    startup-script-url        = var.metadata_optional != null ? lookup(var.metadata_optional, "startup-script-url", "") : ""
    notebook-upgrade-schedule = var.metadata_optional != null ? lookup(var.metadata_optional, "notebook-upgrade-schedule", "") : ""
  }
}

resource "google_notebooks_instance" "instance" {
  project      = var.project_id
  name         = local.notebook_instance_name
  location     = var.zone
  machine_type = var.machine_type
  labels       = var.labels

  dynamic "accelerator_config" {
    for_each = var.accelerator_config != null ? [var.accelerator_config] : []
    content {
      type       = var.accelerator_config.type
      core_count = var.accelerator_config.core_count
    }
  }

  vm_image {
    project      = var.vm_image_config.project
    image_family = var.vm_image_config.image_family
  }

  instance_owners = [var.instance_owner]
  service_account = resource.google_service_account.sa_p_notebook_compute.email

  install_gpu_driver = var.install_gpu_driver
  boot_disk_type     = var.boot_disk_type
  boot_disk_size_gb  = var.boot_disk_size_gb
  disk_encryption    = var.disk_encryption

  no_public_ip    = var.no_public_ip
  no_proxy_access = var.no_proxy_access

  network = data.google_compute_network.my_network.id
  subnet  = data.google_compute_subnetwork.my_subnetwork.id

  metadata            = local.metadata
  post_startup_script = var.post_startup_script

}
