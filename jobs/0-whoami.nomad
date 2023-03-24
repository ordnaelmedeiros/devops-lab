job "whoami" {
  datacenters = ["dc1", "dc2"]
  constraint  {
    attribute = "${meta.server-type}"
    value = "app"
  }
  group "group" {
    count = 4
    spread {
      attribute = "${node.datacenter}"
      weight    = 100
      target "dc1" {
        percent = 90
      }
      target "dc2" {
        percent = 10
      }
    }
    network {
      mode = "bridge"
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
        type     = "http"
        port     = "http"
        path     = "/"
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
        cpu = 10
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