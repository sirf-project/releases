target "default" {
    name = "${base}-${variant}"
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

    cache-to = ["type=gha,mode=max,scope=${base}-${variant}"]
    cache-from = ["type=gha,scope=${base}-${variant}"]

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

