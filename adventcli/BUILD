load(
    "@build_bazel_rules_apple//apple:macos.bzl",
    "macos_command_line_application",
    "macos_unit_test",
)

load(
    "@build_bazel_rules_swift//swift:swift.bzl",
    "swift_library",
)

swift_library(
    name = "Sources",
    srcs = glob(["adventcli/**/*.swift"]),
    deps = [
        "@swift_pkgs//swift-log:Logging",
        "@swift_pkgs//swift-collections:Collections",
        "@swift_pkgs//swift-algorithms:Algorithms",
        "@swift_pkgs//swift-parsing:Parsing",
        "@swift_pkgs//swift-argument-parser:ArgumentParser",
    ],
)

macos_command_line_application(
    name = "cli",
    bundle_id = "io.jakes.advent.advent21",
    infoplists = [":Info.plist"],
    minimum_os_version = "12",
    version = "//:version",
    deps = [":Sources"],
)
