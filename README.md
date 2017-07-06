`container_definitions` module
-----------------------------

This module should contain the logic that generates our default set of container definitions,
providing the rendered definitions as an output.

Input variables
---------------

 * `container_name` - (string) **REQUIRED** - Name/name prefix to apply to the resources in the module.
 * `image` - (string) **REQUIRED** - The docker image in use
 * `port_mappings` - (list) OPTIONAL - list of maps of port_mappings. defaults: []
 * `cpu`- (string) OPTIONAL -The CPU limit for this container definition
 * `memory`- (string) OPTIONAL - The memory limit for this container definition
 * `dns_servers` - (list) OPTIONAL - List of dns servers to pass into the container 
 * `env`: (map) OPTIONAL - map with environment variables
 * `metadata`: (map) OPTIONAL - Set of metadata for this container. It will be passed as environment variables (key uppercased) and labels.
 * `mountpoint`: (map) OPTIONAL - Configuration of one mountpoint for this volume. Map with the values `sourceVolume`, `containerPath` and (optional) `readOnly` .
 * `log_driver` - (string) OPTIONAL - Log driver to be used by the containers. Must be supported by ecs-agent
 * `log_configuration_options`: (map) OPTIONAL - Log configuration options
Usage
-----

```hcl
module "container_defintions" {
  source = "github.com/mergermarket/tf_ecs_container_definitions"

  name           = "some-app"
  image          = "repo/image"
  cpu            = 1024
  memory         = 256
  
  dns_servers     = ["172.17.0.1"]
  
  log_configuration_options = {
    labels = "com.amazonaws.ecs.container-name"
    env = "container_version,environment"
  }

  port_mappings = 
  [
    {
      containerPort = 80
    },
    {
      containerPort = 9090
      hostPort = 9090 
    }
  ]

  container_env = {
    VAR1 = "value1"
    VAR2 = "value2"
  }

  metadata = {
    "label1" = "label.one"
    "label2" = "label.two"
  }

  mountpoint = {
    sourceVolume  = 'data_volume',
    containerPath = '/mnt/data',
    readOnly      = true
  }
}
```

Outputs
-------

 * `rendered`: rendered container definition
