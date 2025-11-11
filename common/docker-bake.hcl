# Common Docker Bake configuration for EDAP/CDP Docker images
target "common" {
  pull = true
  attest = [
    "type=sbom,generator=docker/buildkit-syft-scanner",
    "type=provenance,mode=max"
  ]

  dockerfile = "Dockerfile"
  output     = ["type=image,compression=zstd,compression-level=13"]

  contexts = {
    plymouth  = "../plymouth"
    overrides = "../overrides"
  }

}

# Function to define cache-from with platform-specific paths
function "cache_from" {
  params = [tag]
  result = [
    "type=registry,ref=ghcr.io/sirf-project/releases/${split("/", BAKE_LOCAL_PLATFORM)[1]}/${tag}-buildcache",
    "type=registry,ref=ghcr.io/sirf-project/releases/${split("/", BAKE_LOCAL_PLATFORM)[1]}/${tag}"
  ]
}

# Function to define cache-to with max mode and zstd compression
function "cache_to" {
  params = [tag]
  result = [
    "type=registry,ref=ghcr.io/sirf-project/releases/${split("/", BAKE_LOCAL_PLATFORM)[1]}/${tag}-buildcache,mode=max,compression=zstd,compression-level=5,ignore-error=true",
    "type=inline"
  ]
}

# Function to generate common OCI annotations
function "oci_annotations" {
  params = [title, description, version, base_name]
  result = [
    "org.opencontainers.image.title=${title}",
    "org.opencontainers.image.description=${description}",
    "org.opencontainers.image.version=${version}",
    "org.opencontainers.image.url=https://github.com/sirf-project/releases",
    "org.opencontainers.image.source=https://github.com/sirf-project/releases",
    "org.opencontainers.image.documentation=https://github.com/sirf-project/releases#readme",
    "org.opencontainers.image.licenses=GPL-3.0-or-later",
    "org.opencontainers.image.created=${timestamp()}",
    "org.opencontainers.image.authors=Sirf Project Contributors",
    "org.opencontainers.image.vendor=Sirf Project",
    "org.opencontainers.image.base.name=${base_name}"
  ]
}

# Function to generate common OCI labels
function "oci_labels" {
  params = [title, description, version, base_name]
  result = {
    "org.opencontainers.image.title"         = title
    "org.opencontainers.image.description"   = description
    "org.opencontainers.image.version"       = version
    "org.opencontainers.image.url"           = "https://github.com/sirf-project/releases"
    "org.opencontainers.image.source"        = "https://github.com/sirf-project/releases"
    "org.opencontainers.image.documentation" = "https://github.com/sirf-project/releases#readme"
    "org.opencontainers.image.licenses"      = "GPL-3.0-or-later"
    "org.opencontainers.image.created"       = timestamp()
    "org.opencontainers.image.authors"       = "Sirf Project Contributors"
    "org.opencontainers.image.vendor"        = "Sirf Project"
    "org.opencontainers.image.base.name"     = base_name
  }
}

# Function to generate image tags for EDAP and CDP registries with platform prefix
function "image_tag" {
  params = [tag]
  result = [
    "ghcr.io/sirf-project/releases/${split("/", BAKE_LOCAL_PLATFORM)[1]}/${tag}",
    "quay.io/sirf-project/releases/${split("/", BAKE_LOCAL_PLATFORM)[1]}/${tag}"
  ]
}
