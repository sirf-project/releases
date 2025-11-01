target "default" {
    name = "${base}-${variant}"
    description = "Build Sirf Project base image for Ubuntu ${base} with ${variant} variant"
    pull = true
    matrix = {
        base = ["core24", "lts", "stable"]
        variant = ["all", "apt", "flatpak", "snap"]
    }
    dockerfile = "Dockerfile"

    attest = [
        "type=sbom",
        "type=provenance,mode=max"
    ]

    contexts = {
        ubuntu-base = "docker-image://docker.io/library/ubuntu:${tag(base)}"
    }

    platforms = ["linux/amd64", "linux/arm64"]
    target = variant

    tags = [
        "ghcr.io/sirf-project/releases/${base}:${variant}",
        "quay.io/sirf-project/releases/${base}:${variant}"
    ]

    output = ["type=image,push=true,compression=zstd,compression-level=9,oci-mediatypes=true"]

    cache-to = [
        "type=registry,ref=ghcr.io/sirf-project/releases/cache:${base}-${variant},mode=max,compression=zstd,compression-level=3,oci-mediatypes=true",
        "type=inline"
    ]
    cache-from = [
        "type=registry,ref=ghcr.io/sirf-project/releases/cache:${base}-${variant}",
        "type=registry,ref=ghcr.io/sirf-project/releases/cache:${base}-apt",
        "type=registry,ref=ghcr.io/sirf-project/releases/${base}:${variant}",
        "type=registry,ref=ghcr.io/sirf-project/releases/${base}:apt"
    ]

    annotations = [
        "org.opencontainers.image.title=Sirf Base Image: ${base} - ${variant}",
        "org.opencontainers.image.description=Base Ubuntu image for Sirf Project with ${variant} variant",
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
        "org.opencontainers.image.title" = "Sirf Base Image: ${base} - ${variant}"
        "org.opencontainers.image.description" = "Base Ubuntu image for Sirf Project with ${variant} variant."
        "org.opencontainers.image.version" = "${base}"
        "org.opencontainers.image.url" = "https://github.com/sirf-project/releases"
        "org.opencontainers.image.source" = "https://github.com/sirf-project/releases"
        "org.opencontainers.image.documentation" = "https://github.com/sirf-project/releases#readme"
        "org.opencontainers.image.licenses" = "GPL-3.0-or-later"
        "org.opencontainers.image.created" = "${timestamp()}"
        "org.opencontainers.image.authors" = "Sirf Project Contributors"
        "org.opencontainers.image.vendor" = "Sirf Project"
        "org.opencontainers.image.base.name" = "docker.io/library/ubuntu:${tag(base)}"
    }
}

function "tag" {
    params = [base]
    result = base == "core24" ? "24.04" : base == "lts" ? "latest" : base == "stable" ? "rolling" : "rolling"
}

