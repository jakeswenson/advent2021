load(
    "@build_bazel_rules_apple//apple:versioning.bzl",
    "apple_bundle_version",
)

alias(
    name = "swiftlint",
    actual = "@swift_utils//SwiftLint:swiftlint",
)

alias(
    name = "swiftformat",
    actual = "@swift_utils//SwiftFormat:swiftformat",
)


apple_bundle_version(
    name = "version",
    build_version = "1.0",
    visibility = ["//visibility:public"],
)