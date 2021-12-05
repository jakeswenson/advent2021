load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "build_bazel_rules_apple",
    sha256 = "77e8bf6fda706f420a55874ae6ee4df0c9d95da6c7838228b26910fc82eea5a2",
    url = "https://github.com/bazelbuild/rules_apple/releases/download/0.32.0/rules_apple.0.32.0.tar.gz",
)

load(
    "@build_bazel_rules_apple//apple:repositories.bzl",
    "apple_rules_dependencies",
)

apple_rules_dependencies()

load(
    "@build_bazel_rules_swift//swift:repositories.bzl",
    "swift_rules_dependencies",
)

swift_rules_dependencies()

load(
    "@build_bazel_rules_swift//swift:extras.bzl",
    "swift_rules_extra_dependencies",
)

swift_rules_extra_dependencies()

load(
    "@build_bazel_apple_support//lib:repositories.bzl",
    "apple_support_dependencies",
)

apple_support_dependencies()

http_archive(
    name = "cgrindel_rules_spm",
    sha256 = "fab28a41793744f3944ad2606cdd9c0f8e2f4861dd29fb1d61aa4263c7a1400a",
    strip_prefix = "rules_spm-0.6.0",
    urls = ["https://github.com/cgrindel/rules_spm/archive/v0.6.0.tar.gz"],
)

load(
    "@cgrindel_rules_spm//spm:deps.bzl",
    "spm_rules_dependencies",
)

spm_rules_dependencies()

load("@cgrindel_rules_spm//spm:spm.bzl", "spm_pkg", "spm_repositories")

spm_repositories(
    name = "swift_pkgs",
    dependencies = [
        spm_pkg(
            "https://github.com/apple/swift-log.git",
            from_version = "1.0.0",
            products = ["Logging"],
        ),
        spm_pkg(
            "git@github.com:apple/swift-collections.git",
            from_version = "1.0.2",
            products = ["Collections"],
        ),
        spm_pkg(
            "git@github.com:apple/swift-algorithms.git",
            from_version = "1.0.0",
            products = ["Algorithms"],
        ),
        spm_pkg(
            "git@github.com:pointfreeco/swift-parsing.git",
            from_version = "0.3.1",
            products = ["Parsing"]

        ),
        spm_pkg(
            "https://github.com/apple/swift-argument-parser.git",
            from_version = "1.0.0",
            products = ["ArgumentParser"]
        ),
    ],
)

spm_repositories(
    name = "swift_utils",
    dependencies = [
        spm_pkg(
            "https://github.com/realm/SwiftLint.git",
            from_version = "0.45.0",
            products = ["swiftlint"],
        ),
        spm_pkg(
            "https://github.com/nicklockwood/SwiftFormat.git",
            from_version = "0.48.18",
            products = [
                "swiftformat",
            ],
        ),
    ],
    platforms = [
        ".macOS(.v10_12)",
    ],
)