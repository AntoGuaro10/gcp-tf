resource "google_tags_tag_binding" "binding" {
  for_each  = var.create_template ? {} : coalesce(var.tag_bindings, {})
  parent    = "//compute.googleapis.com/${google_compute_instance.default.0.id}"
  tag_value = each.value
}
