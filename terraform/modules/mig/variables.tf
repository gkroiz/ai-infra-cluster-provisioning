/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

variable "project_id" {
  description = "GCP Project ID to which the cluster will be deployed."
  type        = string
}
variable "resource_prefix" {
  description = <<-EOT
    Arbitrary string with which all names of newly created resources will be
    prefixed.
    EOT
  type        = string
}

variable "target_size" {
  description = <<-EOT
    The number of running instances for this managed instance group.

    Related docs:
    - [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group_manager#target_size)
    - [gcloud](https://cloud.google.com/sdk/gcloud/reference/compute/instance-groups/managed/create#--size)
    EOT
  type        = number
}

variable "zone" {
  description = <<-EOT
    The zone that instances in this group should be created in.

    Related docs:
    - [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group_manager#zone)
    - [gcloud](https://cloud.google.com/sdk/gcloud/reference/compute/instance-groups/managed/create#--zone)
    EOT
  type        = string
}

variable "disk_size_gb" {
  description = <<-EOT
    The size of the image in gigabytes for the boot disk of each instance.

    Related docs:
    - [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template#disk_size_gb
    - [gcloud](https://cloud.google.com/sdk/gcloud/reference/compute/instance-templates/create#--boot-disk-size)"
    EOT
  type        = number
  default     = 128
}

variable "disk_type" {
  description = <<-EOT
    The GCE disk type for the boot disk of each instance.

    Possible values:
    - `"pd-ssd"`
    - `"local-ssd"`
    - `"pd-balanced"`
    - `"pd-standard"`

    Related docs:
    - [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template#disk_type)
    - [gcloud](https://cloud.google.com/sdk/gcloud/reference/compute/instance-templates/create#--boot-disk-type)"
    EOT
  type        = string
  default     = "pd-standard"
}

variable "filestore_new" {
  description = <<-EOT
    Configurations to mount newly created network storage. Each object describes
    NFS file-servers to be hosted in Filestore.

    Related docs:
    - [hpc-toolkit](https://github.com/GoogleCloudPlatform/hpc-toolkit/tree/main/modules/file-system/filestore#inputs)

    ### `filestore_new.filestore_tier`

    The service tier of the instance.

    Possible values:
    - `"BASIC_HDD"`
    - `"BASIC_SSD"`
    - `"HIGH_SCALE_SSD"`
    - `"ENTERPRISE"`

    Related docs:
    - [hpc-toolkit](https://github.com/GoogleCloudPlatform/hpc-toolkit/tree/main/modules/file-system/filestore#input_filestore_tier)
    - [gcloud](https://cloud.google.com/sdk/gcloud/reference/filestore/instances/create#--tier)

    ### `filestore_new.local_mount`

    Mountpoint for this filestore instance.

    Related docs:
    - [hpc-toolkit](https://github.com/GoogleCloudPlatform/hpc-toolkit/tree/main/modules/file-system/filestore#input_local_mount)

    ### `filestore_new.size_gb`

    Storage size of the filestore instance in GB.

    Related docs:
    - [hpc-toolkit](https://github.com/GoogleCloudPlatform/hpc-toolkit/tree/main/modules/file-system/filestore#input_local_mount)
    - [gcloud](https://cloud.google.com/sdk/gcloud/reference/filestore/instances/create#--file-share)
    EOT
  type = list(object({
    filestore_tier = string
    local_mount    = string
    size_gb        = number
  }))
  default = []
}

variable "gcsfuse_existing" {
  description = <<-EOT
    Configurations to mount existing network storage. Each object describes
    Cloud Storage Buckets to be mounted with Cloud Storage FUSE.

    Related docs:
    - [hpc-toolkit](https://github.com/GoogleCloudPlatform/hpc-toolkit/tree/main/modules/file-system/pre-existing-network-storage#inputs)

    ### `gcsfuse_existing.local_mount`

    The mount point where the contents of the device may be accessed after mounting.

    Related docs:
    - [hpc-toolkit](https://github.com/GoogleCloudPlatform/hpc-toolkit/tree/main/modules/file-system/pre-existing-network-storage#input_local_mount)

    ### `gcsfuse_existing.remote_mount`

    Bucket name without “gs://”.

    Related docs:
    - [hpc-toolkit](https://github.com/GoogleCloudPlatform/hpc-toolkit/tree/main/modules/file-system/pre-existing-network-storage#input_remote_mount)
    EOT
  type = list(object({
    local_mount  = string
    remote_mount = string
  }))
  default = []
}

variable "guest_accelerator" {
  description = <<-EOT
    List of the type and count of accelerator cards attached to each instance.
    This must be `null` when `machine_type` is of an
    [accelerator-optimized machine family](https://cloud.google.com/compute/docs/accelerator-optimized-machines)
    such as A2 or G2.

    Related docs:
    - [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template#guest_accelerator)
    - [gcloud](https://cloud.google.com/sdk/gcloud/reference/compute/instance-templates/create#--accelerator)

    ### `guest_accelerator.count`

    The number of the guest accelerator cards exposed to each instance.

    ### `guest_accelerator.type`

    The accelerator type resource to expose to each instance.

    Possible values:
    - `"nvidia-tesla-k80"`
    - `"nvidia-tesla-p100"`
    - `"nvidia-tesla-p4"`
    - `"nvidia-tesla-t4"`
    - `"nvidia-tesla-v100"`

    Related docs:
    - [possible values](https://cloud.google.com/compute/docs/gpus#nvidia_gpus_for_compute_workloads)
    EOT
  type = object({
    count = number
    type  = string
  })
  default = null
}

variable "enable_ops_agent" {
  description = <<-EOT
    Install
    [Google Cloud Ops Agent](https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent).
    EOT
  type        = bool
  default     = true

  validation {
    condition     = var.enable_ops_agent != null
    error_message = "must not be null"
  }
}

variable "enable_ray" {
  description = <<-EOT
    Install [Ray](https://docs.ray.io/en/latest/cluster/getting-started.html).
    EOT
  type        = bool
  default     = false

  validation {
    condition     = var.enable_ray != null
    error_message = "must not be null"
  }
}

variable "machine_image" {
  description = <<-EOT
    The image with which this disk will initialize.

    Related docs:
    - [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template#source_image)

    ### `machine_image.family`

    The family of images from which the latest non-deprecated image will be selected. Conflicts with `machine_image.name`.

    Related docs:
    - [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image#name)
    - [gcloud](https://cloud.google.com/sdk/gcloud/reference/compute/instance-templates/create#--image-family)

    ### `machine_image.name`

    The name of a specific image. Conflicts with `machin_image.family`.

    Related docs:
    - [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image#name)
    - [gcloud](https://cloud.google.com/sdk/gcloud/reference/compute/instance-templates/create#--image)

    ### `machine_image.project`

    The project_id to which this image belongs.

    Related docs:
    - [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image#project)
    - [gcloud](https://cloud.google.com/sdk/gcloud/reference/compute/instance-templates/create#--image-project)
    EOT
  type = object({
    family  = string
    name    = string
    project = string
  })
  default = {
    project = "deeplearning-platform-release"
    family  = "pytorch-latest-gpu-debian-11-py310"
    name    = null
  }

  validation {
    condition = (
      var.machine_image != null
      // project is non-empty
      && alltrue([
        for empty in [null, ""]
        : var.machine_image.project != empty
      ])
      // at least one is non-empty
      && anytrue([
        for value in [var.machine_image.name, var.machine_image.family]
        : alltrue([for empty in [null, ""] : value != empty])
      ])
      // at least one is empty
      && anytrue([
        for value in [var.machine_image.name, var.machine_image.family]
        : anytrue([for empty in [null, ""] : value == empty])
      ])
    )
    error_message = "project must be non-empty exactly one of family or name must be non-empty"
  }
}

variable "machine_type" {
  description = <<-EOT
    The name of a Google Compute Engine machine type.

    Related docs:
    - [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template#machine_type)
    - [gcloud](https://cloud.google.com/sdk/gcloud/reference/compute/instance-templates/create#--machine-type)
    EOT
  type        = string
  default     = "a2-highgpu-2g"
}

variable "network_config" {
  description = <<-EOT
    The network configuration to specify the type of VPC to be used.

    Possible values:
    - `"default"`
    - `"new_multi_nic"`
    - `"new_single_nic"`
    EOT
  type        = string
  default     = "default"

  validation {
    condition = contains(
      ["default", "new_multi_nic", "new_single_nic"],
      var.network_config
    )
    error_message = "network_config must be one of ['default', 'new_multi_nic', 'new_single_nic']."
  }
}

variable "service_account" {
  description = <<-EOT
    Service account to attach to the instance.

    Related docs:
    - [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template#service_account)

    ### `service_account.email`

    The service account e-mail address. If not given, the default Google
    Compute Engine service account is used.

    Related docs:
    - [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template#email)
    - [gcloud](https://cloud.google.com/sdk/gcloud/reference/compute/instance-templates/create#--service-account)

    ### `service_account.scopes`

    A list of service scopes. Both OAuth2 URLs and gcloud short names are
    supported. To allow full access to all Cloud APIs, use the
    `"cloud-platform"` scope. See a complete list of scopes
    [here](https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes#--scopes)

    Related docs:
    - [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template#scopes)
    - [gcloud](https://cloud.google.com/sdk/gcloud/reference/compute/instance-templates/create#--scopes)
    EOT
  type = object({
    email  = string,
    scopes = set(string)
  })
  default = null
}

variable "startup_script" {
  description = <<-EOT
    Shell script -- the actual script (not the filename). Defaults to null.
    Shell script filename. Defaults to null.
    EOT
  type        = string
  default     = null
}

variable "startup_script_file" {
  description = "Shell script filename."
  type        = string
  default     = null
}