job "http-echo" {
  datacenters = ["dc1"]
  constraint  {
    attribute = "${meta.server-type}"
    value = "app"
  }
  group "group" {
    count = 2
    network {
      port "http" {}
    }
    service {
      name = "http-echo"
      port = "http"
      tags = [
        "traefik.enable=true",
        # "traefik.http.routers.http-echo.rule=Path(`/http-echo`) || Host(`http-echo.service.consul`)",
      ]
      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "1s"
        timeout  = "1s"
        check_restart {
          limit = 3
          grace = "30s"
          ignore_warnings = false
        }
      }
    }
    task "http-echo" {
      driver = "docker"
      config {
        image = "hashicorp/http-echo:latest"
        ports = ["http"]
        args = [
          "-listen", ":${NOMAD_PORT_http}",
          "-text", "v1 - Task ${NOMAD_TASK_NAME} - IP ${NOMAD_IP_http} : ${NOMAD_PORT_http}.",  
        ]  
      }
      resources {
        cpu = 100
        memory = 32
      }
    }  
    scaling {
      enabled = true
      min     = 2
      max     = 20
      policy {
        cooldown = "20s"
        check "avg_instance_sessions" {
          source = "prometheus"
          query  = "(sum(traefik_service_requests_total{service=\"http-echo@consulcatalog\"}) - (sum(traefik_service_requests_total{service=\"http-echo@consulcatalog\"} offset 5m) or vector(0))) / 5"
          strategy "pass-through" {}
        }
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