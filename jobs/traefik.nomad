job "traefik" {
  region = "grim"
  datacenters = ["dc1"]
  type = "system"
#  constraint  {
#    attribute = "${meta.server-type}"
#    value = "proxy"
#  }
  group "group" {
    network {
      mode = "host"
      port "http" {static = 80}
      port "api" {static = 8081}
    }
    service {
      name = "traefik"
      port = "api"
      tags = [
        #"traefik.enable=true",
        "traefik.http.middlewares.web-public.ipwhitelist.sourcerange=0.0.0.0/0",
        "traefik.http.middlewares.web-private.ipwhitelist.sourcerange=192.168.100.0/24, 10.221.0.0/24",
      ]
      check {
        name = "alive"
        type = "http"
        port = "api"
        path = "/ping"
        interval = "1s"
        timeout  = "2s"
      }
      check_restart {
        limit = 3
        grace = "30s"
      }
    }
    task "traefik" {
      driver = "docker"
      config {
        image = "traefik:v2.5.1"
        network_mode = "host"
        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
      }
      resources {
        cpu    = 100
        memory = 64
      }
      template {
        destination = "local/traefik.toml"
        data = <<EOF
[entryPoints]
  [entryPoints.traefik]
    address = ":8081"
  [entryPoints.http]
    address = ":80"

[api]
  dashboard = true
  insecure  = true

# Enable Consul Catalog configuration backend.
[providers.consulCatalog]
  refreshInterval = "1s"
  prefix           = "traefik"
  exposedByDefault = false
  defaultRule = "Host(`{{"{{ .Name }}"}}.service.consul`, `{{"{{ .Name }}.localhost"}}`)"
  
  [providers.consulCatalog.endpoint]
    address = "127.0.0.1:8500"
    scheme  = "http"

[metrics]
  [metrics.prometheus]
    buckets = [0.1,0.3,1.2,5.0]

[accessLog]
[ping]
EOF
      }
    }
  }
}