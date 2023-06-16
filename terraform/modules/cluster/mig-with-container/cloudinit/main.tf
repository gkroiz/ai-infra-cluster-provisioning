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

locals {
  _filestore_host_mount = "/tmp/cloud/filestore_mnt"
  _gcsfuse_host_mount   = "/tmp/cloud/gcsfuse_mnt"

  container = {
    cmd   = try(var.container.cmd != null ? var.container.cmd : "", "")
    image = try(var.container.image, "")
    run_at_boot = try(
      var.container.run_at_boot != null ? var.container.run_at_boot : true,
      false
    )
    run_options = try(
      {
        custom = (
          var.container.run_options.custom != null
          ? var.container.run_options.custom
          : []
        )
        enable_cloud_logging = (
          var.container.run_options.enable_cloud_logging != null
          ? var.container.run_options.enable_cloud_logging
          : false
        )
        env = (
          var.container.run_options.env != null
          ? var.container.run_options.env
          : {}
        )
      },
      {
        custom               = []
        enable_cloud_logging = false
        env                  = {}
      }
    )
  }

  _container_template_variables = {
    docker_cmd   = local.container.cmd
    docker_image = local.container.image
    docker_run_options = join(
      " ",
      concat(
        [
          for name, value in local.container.run_options.env
          : "--env ${name}=${value}"
        ],
        local.container.run_options.enable_cloud_logging ? [
          "--log-driver=gcplogs"
        ] : [],
        local.container.run_options.custom,
        [""], // dummy to make join return non-null
      ),
    )
    docker_volume_flags = join(
      " ",
      concat(
        [
          for m in var.filestores[*].local_mount
          : "--volume ${local._filestore_host_mount}${m}:${m}:rw"
        ],
        [
          for m in var.gcsfuses[*].local_mount
          : "--volume ${local._gcsfuse_host_mount}${m}:${m}:rw,rslave"
        ],
        [""], // dummy to make join return non-null
      ),
    )
  }

  _network_storage_template_variables = {
    filestore_mount_commands = join(
      " && ",
      concat(
        ["true"], // dummy to make join return non-null
        [
          for f in var.filestores
          : "mount -t nfs -o async,hard,rw ${f.remote_mount} ${local._filestore_host_mount}${f.local_mount}"
        ],
        ["true"], // dummy to make join return non-null
      )
    )
    gcsfuse_host_mount = local._gcsfuse_host_mount
    gcsfuse_mount_commands = join(
      " && ",
      concat(
        ["true"], // dummy to make join return non-null
        [
          for g in var.gcsfuses
          : "docker exec gcsfuse gcsfuse --implicit-dirs ${g.remote_mount} ${local._gcsfuse_host_mount}${g.local_mount}"
        ],
        ["true"], // dummy to make join return non-null
      )
    )
    host_mountpoints = join(
      " ",
      concat(
        [
          for m in var.filestores[*].local_mount
          : "${local._filestore_host_mount}${m}"
        ],
        [
          for m in var.gcsfuses[*].local_mount
          : "${local._gcsfuse_host_mount}${m}"
        ],
        ["."], // dummy to make join return non-null and have mkdir succeed
      ),
    )
  }

  _userdata_template_variables = merge(
    {
      network_storage = {
        file = templatefile(
          "${path.module}/templates/aiinfra_network_storage.yaml.template",
          local._network_storage_template_variables,
        )
        service = "aiinfra-network-storage"
      }
    },
    var.container != null ? {
      pull_image = {
        file = templatefile(
          "${path.module}/templates/aiinfra_pull_image.yaml.template",
          local._container_template_variables,
        )
        service = "aiinfra-pull-image"
      }
      start_container = {
        file = templatefile(
          "${path.module}/templates/aiinfra_start_container.yaml.template",
          local._container_template_variables,
        )
        service = local.container.run_at_boot ? "aiinfra-start-container" : null
      }
      start_container_gpu = {
        file = templatefile(
          "${path.module}/templates/aiinfra_start_container_gpu.yaml.template",
          local._container_template_variables,
        )
        service = local.container.run_at_boot ? "aiinfra-start-container-gpu" : null
      }
      } : {
      pull_image          = { file = "", service = null }
      start_container     = { file = "", service = null, }
      start_container_gpu = { file = "", service = null, }
    },
  )
  _services = [
    local._userdata_template_variables.network_storage,
    local._userdata_template_variables.pull_image,
    local._userdata_template_variables.start_container,
  ]
  _services_gpu = [
    local._userdata_template_variables.network_storage,
    local._userdata_template_variables.pull_image,
    local._userdata_template_variables.start_container_gpu,
  ]
  userdata_template_variables = {
    aiinfra_network_storage     = local._userdata_template_variables.network_storage.file
    aiinfra_pull_image          = local._userdata_template_variables.pull_image.file
    aiinfra_start_container     = local._userdata_template_variables.start_container.file
    aiinfra_start_container_gpu = local._userdata_template_variables.start_container_gpu.file
    aiinfra_services = join(
      " ",
      [for s in local._services : s.service if s.service != null],
    )
    aiinfra_services_gpu = join(
      " ",
      [for s in local._services_gpu : s.service if s.service != null],
    )
  }
}

data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.module}/templates/userdata.yaml.template",
      local.userdata_template_variables,
    )
    filename = "userdata.yaml"
  }
}

data "cloudinit_config" "config-gpu" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.module}/templates/userdata_gpu.yaml.template",
      local.userdata_template_variables,
    )
    filename = "userdata-gpu.yaml"
  }
}
