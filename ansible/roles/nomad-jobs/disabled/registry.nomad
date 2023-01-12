job "registry" {
  datacenters = ["app"]
  group "group" {
    count = 1

    network {
      port "http" {
        static = 5000
      }
    }
    service {
      name = "registry"
      port = "http"
      tags = [
        "traefik.enable=true",
        # "traefik.http.routers.http-echo.rule=Path(`/registry`) || Host(`registry.service.consul`)",
      ]
      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "1s"
        timeout  = "1s"
      }
    }
    task "task" {
      driver = "docker"
      config {
        image = "registry:2.7.1"
        ports = ["http"]
      }
      resources {
        cpu = 100
        memory = 32
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