// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MarkdownReader",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "MarkdownReader",
            targets: ["MarkdownReader"]
        )
    ],
    targets: [
        .executableTarget(
            name: "MarkdownReader",
            dependencies: [],
            path: ".",
            sources: [
                "MarkdownReaderApp.swift",
                "ContentView.swift",
                "SidebarView.swift",
                "MarkdownView.swift",
                "SwiftCodeView.swift",
                "Models.swift",
                "MarkdownParser.swift",
                "FileManager.swift",
                "PersistenceManager.swift"
            ]
        )
    ]
)