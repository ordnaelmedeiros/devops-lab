job "whoami" {
  datacenters = ["app"]
  group "group" {
    count = 2
    network {
      port "http" {
        to = 80
      }
    }
    service {
      name = "whoami"
      port = "http"
      tags = [
        "traefik.enable=true",
        # "traefik.http.routers.whoami.rule=Path(`/whoami`) || Host(`whoami.service.consul`)",
      ]
      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "1s"
        timeout  = "1s"
      }
    }
    task "whoami" {
      driver = "docker"
      config {
        image = "traefik/whoami:latest"
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