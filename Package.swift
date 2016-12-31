import PackageDescription

let package = Package(
    name: "ncurses-example",
    dependencies: [
        .Package(url:  "https://github.com/Bouke/CNCurses.git", majorVersion: 3),
    ]
)
