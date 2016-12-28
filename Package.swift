import PackageDescription

let package = Package(
    name: "TermDraw",
    dependencies: [
        .Package(url:  "https://github.com/Bouke/CNCurses.git", majorVersion: 3),
    ]
)
