# [START cloudloadbalancing_ext_http_cloudrun]
module "lb-http" {
  source                          = "/modules/serverless_negs"
  name                            = var.lb_name
  project                         = "your project id"

  ssl                             = var.ssl
  private_key                     = var.private_key
  certificate                     = var.certificate
  create_ssl_certificate          = true # or false
  managed_ssl_certificate_domains = [var.domain]
  https_redirect                  = var.ssl
  match_host                      = var.match_host
  match_path                      = var.match_path

  load_balancing_scheme           = var.load_balancing_scheme
  subnetwork                      = var.subnetwork
  region                          = "your region"

  labels                          = { "application" = var.GCP_LABEL }

  backends = {
    default = {
      description = "Your description"
      groups = [
        {
          group = google_compute_region_network_endpoint_group.frontend-serverless_neg.id
        }
      ]
      enable_cdn = var.cdn_enabled

      iap_config = {
        enable = var.iap_enabled
      }
      log_config = {
        enable = var.log_enabled
      }
    }
  }
}

resource "google_compute_region_network_endpoint_group" "frontend-serverless_neg" {
  provider              = google-beta
  project               = "your project id"
  name                  = "webapp-frontend-name-serverless-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "your region"
  cloud_run {
    service = google_cloud_run_v2_service.poseidon-webapp-frontend.name
  }
  depends_on = [ google_cloud_run_v2_service.poseidon-webapp-frontend ]
}
# [END cloudloadbalancing_ext_http_cloudrun]


resource "google_cloud_run_v2_service" "webapp-frontend" {
    provider    = google-beta
    project     = "your project id"
    name        = "webapp-frontend"
    location    = "your region"
    ingress     = "INGRESS_TRAFFIC_INTERNAL_ONLY"

    template {

        labels = { "application" = "your label" }


        scaling {
            min_instance_count = 1
            max_instance_count = 1
        }

        timeout = "3600s"

        service_account = "your service account"

        containers {

            image = "europe-west4-docker.pkg.dev/${"your project id"}/artifacts/webapp-frontend:latest"

            env {
                name  = "BACKEND"
                value = "https:\\/\\/webapp-backend-xofn2mllmq-ez.a.run.app"
            }

            env {
                name  = "RESOLVER"
                value = "169.254.169.254"
            }

            resources {
                limits = {
                    cpu = 1
                    memory = "512Mi"
                }
            }

            ports {
                container_port = 80
            }    

        }

        vpc_access {
            egress = "ALL_TRAFFIC"
            connector = "your vpc connector"
        }

        max_instance_request_concurrency = 1000

    }
# To block image re-build
    lifecycle {
      ignore_changes = [ template[0].containers[0].image ]
    }

}
