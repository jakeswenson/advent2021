load(
    "@build_bazel_rules_apple//apple:macos.bzl",
    "macos_command_line_application",
)

load(
    "@build_bazel_rules_swift//swift:swift.bzl",
    "swift_library",
)

swift_library(
    name = "Sources",
    srcs = ["src/main.swift"],
    data = ["resources/data.txt"],
    deps = [
        "@swift_pkgs//swift-log:Logging",
        "@swift_pkgs//swift-collections:Collections",
        "@swift_pkgs//swift-algorithms:Algorithms",
    ],
)


macos_command_line_application(
    name = "cli",
    bundle_id = "io.jakes.advent.advent21",
    infoplists = [":Info.plist"],
    minimum_os_version = "10.11",
    version = "//:version",
    deps = [":Sources"],
)
