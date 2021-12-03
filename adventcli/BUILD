load(
    "@build_bazel_rules_apple//apple:macos.bzl",
    "macos_command_line_application",
    "macos_unit_test",
)

load(
    "@build_bazel_rules_apple//apple:versioning.bzl",
    "apple_bundle_version",
)

load(
    "@build_bazel_rules_swift//swift:swift.bzl",
    "swift_library",
)

swift_library(
    name = "Sources",
    srcs = ["adventcli/main.swift", "adventcli/day01.swift", "adventcli/day02.swift", "adventcli/day03.swift"],
    deps = [
        "@swift_pkgs//swift-log:Logging",
        "@swift_pkgs//swift-collections:Collections",
        "@swift_pkgs//swift-algorithms:Algorithms",
        "@swift_pkgs//swift-parsing:Parsing"
    ],
)

swift_library(
    name = "testSources",
    srcs = ["src/tests.swift"],
    deps = [":Sources"]
)

macos_command_line_application(
    name = "cli",
    bundle_id = "io.jakes.advent.advent21",
    infoplists = [":Info.plist"],
    minimum_os_version = "10.11",
    version = "//:version",
    deps = [":Sources"],
)

macos_unit_test(
    name = "tests",
    deps = [":testSources"],
    minimum_os_version = "10.11",
    bundle_id = "io.jakes.advent.advent21.tests",
    infoplists = [":Info.plist"]
)
