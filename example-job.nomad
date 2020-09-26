job "test" {
  group "test" {
    count = 3

    task "nginx" {
      driver = "docker"
      config {
        image = "nginx:latest"

        port_map {
          db = 80
        }
      }

      logs {
        max_files     = 5
        max_file_size = 15
      }
      resources {
        cpu    = 200 # MHz
        memory = 64 # MB

        network {
          mbits = 10
          port  "db"  {}
        }
      }
      service {
        name = "nginx"
        tags = ["global", "test"]
        port = "db"

        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    ephemeral_disk {
      size = 100
    }
  }

  datacenters = ["spain"]
  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "5s"
    healthy_deadline = "3m"
    auto_revert = false
    canary = 0
  }
}
