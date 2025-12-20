variable "GITHUB_SHA" {
  default = "main"
}

variable "BAKE_LOCAL_PLATFORM" {
  default = "linux/amd64"
  validation {
    condition     = can(regex("^linux/(amd64|arm64|arm/v7|arm/v8|386|ppc64le|s390x|riscv64)$", BAKE_LOCAL_PLATFORM))
    error_message = "BAKE_LOCAL_PLATFORM must be a valid linux platform (e.g., linux/amd64, linux/arm64)"
  }
}

variable "BASE_IMAGE_DIGEST" {
  default = ""
}

variable "BUILD_NUMBER" {
  default = ""
}

target "common" {
  pull    = true
  network = "default"
  attest = [
    "type=sbom,generator=docker/buildkit-syft-scanner",
    "type=provenance,mode=max"
  ]

  dockerfile = "Dockerfile"
  output     = ["type=image,compression=zstd,compression-level=19,oci-mediatypes=true,force-compression=true"]

}

# Extracts architecture from BAKE_LOCAL_PLATFORM (e.g., "linux/amd64" → "amd64")
function "platform_arch" {
  params = []
  result = split("/", BAKE_LOCAL_PLATFORM)[1]
}

# Generates cache source references for BuildKit with multi-registry fallback
function "cache_from" {
  params = [tag]
  result = [
    "type=registry,ref=ghcr.io/sirf-project/releases/${platform_arch()}/${tag}-buildcache",
    "type=registry,ref=quay.io/sirf-project/releases/${platform_arch()}/${tag}-buildcache",
    "type=registry,ref=ghcr.io/sirf-project/releases/${platform_arch()}/${tag}",
    "type=registry,ref=quay.io/sirf-project/releases/${platform_arch()}/${tag}",
  ]
}

# Generates cache destination with max mode, zstd compression, and dual registry push
function "cache_to" {
  params = [tag]
  result = [
    "type=registry,ref=ghcr.io/sirf-project/releases/${platform_arch()}/${tag}-buildcache,mode=max,compression=zstd,compression-level=19,ignore-error=true",
    "type=registry,ref=quay.io/sirf-project/releases/${platform_arch()}/${tag}-buildcache,mode=max,compression=zstd,compression-level=19,ignore-error=true",
    "type=inline"
  ]
}

# Generates OCI-compliant annotations array for image manifest
function "oci_annotations" {
  params = [title, description, version, base_name, ref_name]
  result = concat(
    [
      "index:org.opencontainers.image.created=${timestamp()}",
      "index:org.opencontainers.image.authors=Sirf Project Contributors",
      "index:org.opencontainers.image.url=https://github.com/sirf-project/releases",
      "index:org.opencontainers.image.documentation=https://github.com/sirf-project/releases#readme",
      "index:org.opencontainers.image.source=https://github.com/sirf-project/releases",
      "index:org.opencontainers.image.version=${version}",
      "index:org.opencontainers.image.revision=${GITHUB_SHA}",
      "index:org.opencontainers.image.vendor=Sirf Project",
      "index:org.opencontainers.image.licenses=GPL-3.0-or-later",
      "index:org.opencontainers.image.title=${title}",
      "index:org.opencontainers.image.description=${description}",
      "index:org.opencontainers.image.base.name=${base_name}",
      "index:org.opencontainers.image.ref.name=${ref_name}",
      "manifest:org.opencontainers.image.created=${timestamp()}",
      "manifest:org.opencontainers.image.authors=Sirf Project Contributors",
      "manifest:org.opencontainers.image.url=https://github.com/sirf-project/releases",
      "manifest:org.opencontainers.image.documentation=https://github.com/sirf-project/releases#readme",
      "manifest:org.opencontainers.image.source=https://github.com/sirf-project/releases",
      "manifest:org.opencontainers.image.version=${version}",
      "manifest:org.opencontainers.image.revision=${GITHUB_SHA}",
      "manifest:org.opencontainers.image.vendor=Sirf Project",
      "manifest:org.opencontainers.image.licenses=GPL-3.0-or-later",
      "manifest:org.opencontainers.image.title=${title}",
      "manifest:org.opencontainers.image.description=${description}",
      "manifest:org.opencontainers.image.base.name=${base_name}",
      "manifest:org.opencontainers.image.ref.name=${ref_name}",
      "manifest:org.opencontainers.image.architecture=${platform_arch()}",
      "manifest:org.opencontainers.image.os=linux"
    ],
    BASE_IMAGE_DIGEST != "" ? [
      "index:org.opencontainers.image.base.digest=${BASE_IMAGE_DIGEST}",
      "manifest:org.opencontainers.image.base.digest=${BASE_IMAGE_DIGEST}"
    ] : [],
    BUILD_NUMBER != "" ? [
      "index:org.opencontainers.image.build.number=${BUILD_NUMBER}",
      "manifest:org.opencontainers.image.build.number=${BUILD_NUMBER}"
    ] : []
  )
}

# Generates OCI-compliant labels map for Dockerfile LABEL directive
function "oci_labels" {
  params = [title, description, version, base_name, ref_name]
  result = merge(
    {
      "org.opencontainers.image.title"         = title
      "org.opencontainers.image.description"   = description
      "org.opencontainers.image.version"       = version
      "org.opencontainers.image.revision"      = GITHUB_SHA
      "org.opencontainers.image.created"       = timestamp()
      "org.opencontainers.image.url"           = "https://github.com/sirf-project/releases"
      "org.opencontainers.image.source"        = "https://github.com/sirf-project/releases"
      "org.opencontainers.image.documentation" = "https://github.com/sirf-project/releases#readme"
      "org.opencontainers.image.licenses"      = "GPL-3.0-or-later"
      "org.opencontainers.image.vendor"        = "Sirf Project"
      "org.opencontainers.image.authors"       = "Sirf Project Contributors"
      "org.opencontainers.image.base.name"     = base_name
      "org.opencontainers.image.ref.name"      = ref_name
      "org.opencontainers.image.architecture"  = platform_arch()
      "org.opencontainers.image.os"            = "linux"
    },
    BASE_IMAGE_DIGEST != "" ? {
      "org.opencontainers.image.base.digest" = BASE_IMAGE_DIGEST
    } : {},
    BUILD_NUMBER != "" ? {
      "org.opencontainers.image.build.number" = BUILD_NUMBER
    } : {}
  )
}

# Generates platform-specific image tags for GHCR and Quay registries
function "image_tag" {
  params = [tag]
  result = [
    "ghcr.io/sirf-project/releases/${platform_arch()}/${tag}",
    "quay.io/sirf-project/releases/${platform_arch()}/${tag}"
  ]
}
