job "countdash" {
  datacenters = ["dc1"]
  constraint  {
    attribute = "${meta.server-type}"
    value = "app"
  }

  group "api" {
    count = 2
    network {
      mode = "bridge"
      port "metrics_envoy" {to = 9102}
    }
    service {
      name = "count-api"
      port = "9001"
      meta {
        metrics_port_envoy = "${NOMAD_HOST_PORT_metrics_envoy}"
      }
      connect {
        sidecar_service {
          proxy {
            config {
              envoy_prometheus_bind_addr = "0.0.0.0:9102"
            }
          }
        }
        sidecar_task {
          resources {
            cpu = 100
            memory = 64
          }
        }
      }
    }
    task "web" {
      driver = "docker"
      config {
        image = "hashicorpnomad/counter-api:v3"
      }
      resources {
        cpu = 100
        memory = 64
      }
    }
  }

  group "dashboard" {
    count = 2
    network {
      mode = "bridge"
      port "http" {to = 9002}
      port "metrics_envoy" {to = 9102}
    }
    service {
      name = "count-dashboard"
      port = "${NOMAD_PORT_http}"
      meta {
        metrics_port_envoy = "${NOMAD_HOST_PORT_metrics_envoy}"
      }
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "count-api"
              local_bind_port  = 8080
            }
            config {
              envoy_prometheus_bind_addr = "0.0.0.0:9102"
            }
          }
        }
        sidecar_task {
          resources {
            cpu = 100
            memory = 64
          }
        }
      }
    }
    task "dashboard" {
      driver = "docker"
      env {
        COUNTING_SERVICE_URL = "http://${NOMAD_UPSTREAM_ADDR_count_api}"
      }
      config {
        image = "hashicorpnomad/counter-dashboard:v3"
      }
      resources {
        cpu = 100
        memory = 64
      }
    }
  }
  
  group "ingress" {
    network {
      mode = "bridge"
      port "inbound" {to = 8080}
    }
    service {
      name = "count"
      port = "${NOMAD_HOST_PORT_inbound}"
      tags = [
        "traefik.enable=true",
      ]
      connect {
        gateway {
          ingress {
            listener {
              port = 8080
              service {
                name = "count-dashboard"
              }
            }
          }
        }
        sidecar_task {
          resources {
            cpu = 100
            memory = 64
          }
        }
      }
    }
  }

}
