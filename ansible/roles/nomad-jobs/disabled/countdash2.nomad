job "countdash2" {
  datacenters = ["dc1"]
  group "api" {
    network {
      mode = "bridge"
      port "metrics_envoy" {
        to = 9102
      }
    }

    service {
      name = "test-metrics"
      port = "9001"
      meta {
        metrics_port_envoy = "${NOMAD_HOST_PORT_metrics_envoy}"
      }
      connect {
        sidecar_service {
          proxy {
            config {
              # Expose metrics for prometheus (envoy)
              envoy_prometheus_bind_addr = "0.0.0.0:9102"
            }
          }
        }
      }

    }

    task "web" {
      driver = "docker"
      config {
        image = "hashicorpnomad/counter-api:v1"
      }
    }
  }


}