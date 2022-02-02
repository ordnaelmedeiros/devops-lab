job "keycloak" {
  datacenters = ["app"]
  group "group" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = 8080
      }
      port "expose" {}
    }
    service {
      name = "auth"
      port = "http"
      tags = [
        "traefik.enable=true",
      ]
      check {
        name     = "alive"
        type     = "http"
        path     = "/auth/realms/master"
        port     = "http"
        interval = "1s"
        timeout  = "1s"
      }

      connect {
        sidecar_service {
          tags = [
            "traefik.enable=false",
          ]
          proxy {
            upstreams {
              destination_name = "keycloak-pg-pool"
              local_bind_port  = 5433
            }
            expose {
              path {
                path = "/metrics"
                protocol = "http"
                local_path_port = 8080
                listener_port = "expose"
              }
            }
          }
        }
      }
    }
    task "task" {
      driver = "docker"
      config {
        image = "quay.io/keycloak/keycloak:16.1.0"
        ports = ["http"]
      }
      env {
        KEYCLOAK_USER = "admin" 
        KEYCLOAK_PASSWORD = "admin"
        DB_VENDOR = "postgres"
        DB_ADDR = "127.0.0.1"
        DB_PORT = "5433"
        DB_DATABASE = "keycloak"
        DB_USER = "postgres"
        DB_PASSWORD = "admin"
      }
      resources {
        cpu = 100
        memory = 512
      }
    }  
  }
  update {
    max_parallel      = 1
    health_check      = "task_states"
    min_healthy_time  = "10s"
    healthy_deadline  = "5m"
    progress_deadline = "10m"
    auto_revert       = true
    #auto_promote      = true
    #canary            = 1
    stagger           = "30s"
  }
}