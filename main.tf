# container definition template mapping
data "template_file" "container_definitions" {
  template = "${file("${path.module}/container_definition.json.tmpl")}"

  vars {
    image          = "${var.image}"
    container_name = "${var.name}"
    portMappings   = "${join(",", data.template_file._port_mapping.*.rendered)}"
    cpu            = "${var.cpu}"
    mem            = "${var.memory}"

    container_env = "${
      join (
        format(",\n      "),
        concat(
          null_resource._jsonencode_container_env.*.triggers.entries,
          null_resource._jsonencode_metadata_env.*.triggers.entries,
          list(jsonencode(
            map(
              "name", "DOCKER_IMAGE",
              "value", var.image,
            )
          ))
        )
      )
    },"

    labels = "${jsonencode(var.metadata)}"

    mountpoint_sourceVolume  = "${lookup(var.mountpoint, "sourceVolume", "none")}"
    mountpoint_containerPath = "${lookup(var.mountpoint, "containerPath", "none")}"
    mountpoint_readOnly      = "${lookup(var.mountpoint, "readOnly", false)}"
  }

  depends_on = [
    "null_resource._jsonencode_container_env",
    "null_resource._jsonencode_metadata_env",
  ]
}

# Create a JSON snippet with the list of variables to be passed to
# the container definitions.
#
# It will use a null_resource to generate a list of JSON encoded
# name-value maps like {"name": "...", "value": "..."}, and then
# we join them in a data template file.
resource "null_resource" "_jsonencode_container_env" {
  triggers {
    entries = "${
      jsonencode(
        map(
          "name", element(keys(var.container_env), count.index),
          "value", element(values(var.container_env), count.index),
          )
      )
    }"
  }

  count = "${length(var.container_env)}"
}

# JSON snippet with the list of labels
resource "null_resource" "_jsonencode_metadata_env" {
  triggers {
    entries = "${
      jsonencode(
        map(
          "name", upper(element(keys(var.metadata), count.index)),
          "value", element(values(var.metadata), count.index),
          )
      )
    }"
  }

  count = "${length(var.metadata)}"
}

data "template_file" "_port_mapping" {
  count    = "${length(var.portMappings)}"
  template = "$${val}"
  vars {
    val = "${jsonencode(var.portMappings[count.index])}"
  }
}
