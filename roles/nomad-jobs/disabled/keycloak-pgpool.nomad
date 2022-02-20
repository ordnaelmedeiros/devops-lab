job "keycloak-pgpool" {

  datacenters = ["dc1"]
  constraint  {
    attribute = "${meta.server-type}"
    value = "app"
  }
  group "pg-pool" {

    count = 1

    network {
      mode = "bridge"
      port "db" {
        to = 5432
      }
    }

    service {
      name = "keycloak-pg-pool"
      port = 5432
      #check {
      #  name     = "alive"
      #  type     = "tcp"
      #  port     = "db"
      #  interval = "1s"
      #  timeout  = "1s"
      #}
      connect {
        sidecar_service {}
      }
    }

    task "pg-pool" {
      driver = "docker"
      config {
        image = "bitnami/pgpool:4.2.6"
        ports = ["db"]
      }
      env {
        PGPOOL_BACKEND_NODES = "0:192.168.100.191:5433,1:192.168.100.192:5433"
        PGPOOL_SR_CHECK_USER = "keycloak"
        PGPOOL_SR_CHECK_PASSWORD = "admin"
        PGPOOL_ENABLE_LDAP = "no"
        PGPOOL_POSTGRES_USERNAME = "postgres"
        PGPOOL_POSTGRES_PASSWORD = "admin"
        PGPOOL_ADMIN_USERNAME = "admin"
        PGPOOL_ADMIN_PASSWORD = "admin"
      }  
      resources {
        cpu = 100
        memory = 200
      }
    }  
  }

}