job "countdash" {
  datacenters = ["app"]

  group "api" {

    count = 1

    network {
      mode = "bridge"
    }

    service {
      name = "count-api"
      port = "9001"

      connect {
        sidecar_service {}
      }
    }

    task "web" {
      driver = "docker"

      config {
        image = "hashicorpnomad/counter-api:v3"

      }
      resources {
        cpu    = 10
        memory = 64
      }

    }
  }

  group "dashboard" {

    count = 1

    network {
      mode = "bridge"

      port "http" {
        to     = 9002
      }
    }

    service {
      name = "count-dashboard"
      port = "http"
      tags = [
        "traefik.enable=true",
      ]
      connect {
        sidecar_service {
          tags = [
            "traefik.enable=true",
          ]
          proxy {
            upstreams {
              destination_name = "count-api"
              local_bind_port  = 8080
            }
          }
          port = 9000
          
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
        cpu    = 10
        memory = 64
      }

    }
  }
}
