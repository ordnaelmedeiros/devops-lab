job "keycloak-postgres" {

  datacenters = ["db"]

  group "pg-0" {
    count = 1
    network {
      port "db" {
        static = 5433
        to = 5433
      }
    }
    service {
      name = "keycloak-pg-0"
      port = "db"
      check {
        name     = "alive"
        type     = "tcp"
        port     = "db"
        interval = "1s"
        timeout  = "3s"
        check_restart {
          limit = 3
          grace = "30s"
        }
      }
    }
    task "pg-0" {
      affinity {
        attribute = "${meta.db-type}"
        value = "master"
        weight = 100
      }
      driver = "docker"
      config {
        image = "bitnami/postgresql-repmgr:13.5.0"
        ports = ["db"]
        hostname = "pg-0"
        volumes = [
          "local/etc/hosts:/etc/hosts",
        ]
      }
      env {
        POSTGRESQL_POSTGRES_PASSWORD = "admin"
        POSTGRESQL_USERNAME = "keycloak"
        POSTGRESQL_PASSWORD = "admin"
        POSTGRESQL_DATABASE = "keycloak"
        REPMGR_PASSWORD = "repmgrpass"
        REPMGR_PRIMARY_HOST = "pg-0"
        REPMGR_PARTNER_NODES = "pg-0,pg-1"
        REPMGR_NODE_NAME = "pg-0"
        REPMGR_NODE_NETWORK_NAME = "pg-0"
        POSTGRESQL_MASTER_PORT_NUMBER = "${NOMAD_PORT_db}"
        POSTGRESQL_PORT_NUMBER = "${NOMAD_PORT_db}"
        REPMGR_PORT_NUMBER = "${NOMAD_PORT_db}"
        REPMGR_PRIMARY_PORT = "${NOMAD_PORT_db}"
        PGPORT = "${NOMAD_PORT_db}"
        POSTGRESQL_PGPORT = "${NOMAD_PORT_db}"
      }  
      resources {
        cpu = 100
        memory = 256
      }
      template {
        data = <<EOH
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

127.0.0.1 pg-0
192.168.100.192 pg-1
        EOH
        destination = "local/etc/hosts"
      }
    }
  }
  
  group "pg-1" {
    count = 1
    affinity {
      attribute = "${meta.db-type}"
      value = "slave"
      weight = 100
    }
    network {
      port "db" {
        static = 5433
        to = 5433
      }
    }
    service {
      name = "keycloak-pg-1"
      port = "db"
      check {
        name     = "alive"
        type     = "tcp"
        port     = "db"
        interval = "1s"
        timeout  = "1s"
        check_restart {
          limit = 3
          grace = "30s"
        }
      }
    }
    task "pg-1" {
      driver = "docker"
      config {
        image = "bitnami/postgresql-repmgr:13.5.0"
        ports = ["db"]
        hostname = "pg-1"
        volumes = [
          "local/etc/hosts:/etc/hosts",
        ]
      }
      env {
        POSTGRESQL_POSTGRES_PASSWORD = "admin"
        POSTGRESQL_USERNAME = "keycloak"
        POSTGRESQL_PASSWORD = "admin"
        POSTGRESQL_DATABASE = "keycloak"
        REPMGR_PASSWORD = "repmgrpass"
        REPMGR_PRIMARY_HOST = "pg-0"
        REPMGR_PARTNER_NODES = "pg-0,pg-1"
        REPMGR_NODE_NAME = "pg-1"
        REPMGR_NODE_NETWORK_NAME = "pg-1"
        POSTGRESQL_MASTER_PORT_NUMBER = "${NOMAD_PORT_db}"
        POSTGRESQL_PORT_NUMBER = "${NOMAD_PORT_db}"
        REPMGR_PORT_NUMBER = "${NOMAD_PORT_db}"
        REPMGR_PRIMARY_PORT = "${NOMAD_PORT_db}"
        PGPORT = "${NOMAD_PORT_db}"
        POSTGRESQL_PGPORT = "${NOMAD_PORT_db}"
      }  
      resources {
        cpu = 100
        memory = 256
      }
      template {
        data = <<EOH
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

192.168.100.191 pg-0
127.0.0.1 pg-1
        EOH
        destination = "local/etc/hosts"
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