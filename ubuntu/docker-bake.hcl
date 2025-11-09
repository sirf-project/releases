target "default" {
  name        = variant
  description = "Build Sirf Project base image for Ubuntu ${variant}"
  inherits    = ["common"]

  matrix = {
    variant = ["current", "core24", "dev", "lts"]
  }

  args = {
    PLYMOUTH_FONT       = "Ubuntu Sans 11"
    PLYMOUTH_TITLE_FONT = "Ubuntu Sans Light 30"
  }

  cache-to = cache_to("ubuntu:${variant}")

  cache-from = cache_from("ubuntu:${variant}")

  contexts = {
    ubuntu-base = "docker-image://docker.io/library/ubuntu:${tag(variant)}"
  }

  tags = image_tag("ubuntu:${variant}")

  annotations = oci_annotations(
    "Base Ubuntu:${variant} Image",
    "Base Ubuntu Image for Sirf Project with snapd, flatpak and kernel",
    "${variant}",
    "docker.io/library/ubuntu:${tag(variant)}"
  )

  labels = oci_labels(
    "Base Ubuntu ${variant} Image",
    "Base Ubuntu Image for Sirf Project with snapd, flatpak and kernel",
    "${variant}",
    "docker.io/library/ubuntu:${tag(variant)}"
  )
}

function "tag" {
  params = [variant]
  result = lookup(
    {
      current = "rolling"
      core24  = "24.04"
      dev     = "devel"
      lts     = "latest"
    },
    variant,
    "rolling"
  )
}

