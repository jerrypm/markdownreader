import Foundation

struct MarkdownFile: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let path: String
    let content: String
    let relativePath: String

    var displayName: String {
        String(name.dropLast(3))
    }
}

struct FileNode: Identifiable {
    let id = UUID()
    let name: String
    let isFolder: Bool
    var children: [FileNode] = []
    let file: MarkdownFile?
    let folderPath: String // Full path for unique identification

    init(name: String, isFolder: Bool, children: [FileNode] = [], file: MarkdownFile? = nil, folderPath: String = "") {
        self.name = name
        self.isFolder = isFolder
        self.children = children
        self.file = file
        self.folderPath = folderPath.isEmpty ? name : folderPath
    }
}

enum MarkdownElement {
    case heading1(String)
    case heading2(String)
    case heading3(String)
    case heading4(String)
    case paragraph(String)
    case codeBlock(String, String)
    case bulletList([String])
    case lineBreak
}

enum TextComponent {
    case text(String)
    case link(String, String)
}