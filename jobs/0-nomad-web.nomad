job nomad-web {
  datacenters = ["dc1", "dc2"]
  type = "service"
  group "grupo" {
    count = 2
    spread {
      attribute = "${node.datacenter}"
      weight    = 100
      target "dc1" {
        percent = 50
      }
      target "dc2" {
        percent = 50
      }
    }
    network {
      mode = "bridge"
      port "http" {
        to = 80
      }
    }
    service {
      name = "nomad-web"
      port = "http"
      tags = [
        "traefik.enable=true"
      ]
      connect {
        sidecar_service {
          tags = [
            "traefik.enable=false",
          ]
          proxy {
          }
        }
      }
    }
    task "task" {
      driver = "docker"
      config {
        image = "nginx:1.21"
        ports = ["http"]
        volumes = [
          "local/default.conf:/etc/nginx/conf.d/default.conf",
        ]
      }
      resources {
        cpu = 10
        memory = 16
      }
      template {
        destination = "local/default.conf"
        data = <<EOF
server {
  listen 80;
  location / {
    proxy_pass http://nomad-server.service.consul:4646;
  }
  access_log off;
  error_log  /var/log/nginx/error.log error;
}
EOF
      }
    }
  }
}