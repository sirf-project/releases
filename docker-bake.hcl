target "default" {
  name        = base
  description = "Build Sirf Project base image for Ubuntu ${base}"
  pull        = true
  matrix = {
    base = ["core24", "lts", "stable"]
  }
  dockerfile = "Dockerfile"

  attest = [
    "type=sbom,generator=docker/buildkit-syft-scanner",
    "type=provenance,mode=max"
  ]

  contexts = {
    ubuntu-base = "docker-image://docker.io/library/ubuntu:${tag(base)}"
  }

  platforms = ["linux/amd64", "linux/arm64"]

  tags = [
    "ghcr.io/sirf-project/releases/${base}",
    "quay.io/sirf-project/releases/${base}"
  ]

  output = ["type=image,push=true,compression=zstd,compression-level=13"]

  cache-to = [
    "type=registry,ref=ghcr.io/sirf-project/releases/${base}:buildcache,mode=max,compression=zstd,compression-level=5",
    "type=inline"
  ]
  cache-from = [
    "type=registry,ref=ghcr.io/sirf-project/releases/${base}:buildcache",
    "type=registry,ref=ghcr.io/sirf-project/releases/${base}"
  ]

  annotations = [
    "org.opencontainers.image.title=Sirf Base Image: ${base}",
    "org.opencontainers.image.description=Base Ubuntu image for Sirf Project with snapd, flatpak, and essential utilities",
    "org.opencontainers.image.version=${base}",
    "org.opencontainers.image.url=https://github.com/sirf-project/releases",
    "org.opencontainers.image.source=https://github.com/sirf-project/releases",
    "org.opencontainers.image.documentation=https://github.com/sirf-project/releases#readme",
    "org.opencontainers.image.licenses=GPL-3.0-or-later",
    "org.opencontainers.image.created=${timestamp()}",
    "org.opencontainers.image.authors=Sirf Project Contributors",
    "org.opencontainers.image.vendor=Sirf Project",
    "org.opencontainers.image.base.name=docker.io/library/ubuntu:${tag(base)}"
  ]

  labels = {
    "org.opencontainers.image.title"         = "Sirf Base Image: ${base}"
    "org.opencontainers.image.description"   = "Base Ubuntu image for Sirf Project with snapd, flatpak, and essential utilities"
    "org.opencontainers.image.version"       = "${base}"
    "org.opencontainers.image.url"           = "https://github.com/sirf-project/releases"
    "org.opencontainers.image.source"        = "https://github.com/sirf-project/releases"
    "org.opencontainers.image.documentation" = "https://github.com/sirf-project/releases#readme"
    "org.opencontainers.image.licenses"      = "GPL-3.0-or-later"
    "org.opencontainers.image.created"       = "${timestamp()}"
    "org.opencontainers.image.authors"       = "Sirf Project Contributors"
    "org.opencontainers.image.vendor"        = "Sirf Project"
    "org.opencontainers.image.base.name"     = "docker.io/library/ubuntu:${tag(base)}"
  }
}

function "tag" {
  params = [base]
  result = lookup(
    {
      core24 = "24.04"
      lts    = "latest"
      stable = "rolling"
    },
    base,
    "rolling"
  )
}

