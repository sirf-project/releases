target "default" {
  name        = variant
  description = "Build Sirf Project base image for Debian ${variant}"
  inherits    = ["common"]

  matrix = {
    variant = ["dev", "latest", "lts"]
  }

  cache-to = cache_to("debian:${variant}")

  cache-from = cache_from("debian:${variant}")

  contexts = {
    debian-base = "docker-image://docker.io/library/debian:${tag(variant)}"
  }

  tags = image_tag("debian:${variant}")

  annotations = oci_annotations(
    "Base Debian:${variant} Image",
    "Base Debian Image for Sirf Project with snapd, flatpak and kernel",
    "${variant}",
    "docker.io/library/debian:${tag(variant)}",
    "debian:${variant}"
  )

  labels = oci_labels(
    "Base Debian ${variant} Image",
    "Base Debian Image for Sirf Project with snapd, flatpak and kernel",
    "${variant}",
    "docker.io/library/debian:${tag(variant)}",
    "debian:${variant}"
  )
}

function "tag" {
  params = [variant]
  result = lookup(
    {      
      dev     = "unstable"
      latest  = "testing"
      lts     = "stable"
    },
    variant,
    "stable"
  )
}

