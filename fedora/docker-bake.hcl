target "default" {
  name        = variant
  description = "Build Sirf Project base image for Fedora ${variant}"
  inherits = [ "common" ]

  matrix = {
    variant = ["current", "dev"]
  }

  cache-to = cache_to("fedora:${variant}")

  cache-from = cache_from("fedora:${variant}")

  contexts = {
    fedora-base = "docker-image://docker.io/library/fedora:${tag(variant)}"
  }

  tags = image_tag("fedora:${variant}")

  annotations = oci_annotations(
    "Base Fedora:${variant} Image",
    "Base Fedora Image for Sirf Project with snapd, flatpak and kernel",
    "${variant}",
    "docker.io/library/fedora:${tag(variant)}"
  )

  labels = oci_labels(
    "Base Fedora ${variant} Image",
    "Base Fedora Image for Sirf Project with snapd, flatpak and kernel",
    "${variant}",
    "docker.io/library/fedora:${tag(variant)}"
  )
}

function "tag" {
  params = [variant]
  result = variant == "dev" ? "rawhide" : "latest"
}

