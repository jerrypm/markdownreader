import Foundation
import SwiftUI

class DocumentFileManager: ObservableObject {
    @Published var markdownFiles: [MarkdownFile] = []
    @Published var selectedFile: MarkdownFile?
    @Published var selectedFolderPath: String?

    private var basePath: String = ""

    func selectFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = false
        panel.title = "Select Documentation Folder"
        panel.message = "Choose the folder containing your markdown documentation"

        if panel.runModal() == .OK {
            if let url = panel.url {
                selectedFolderPath = url.path
                loadMarkdownFiles(from: url.path)
            }
        }
    }

    func loadMarkdownFiles(from path: String) {
        basePath = path
        markdownFiles = []

        let fileManager = FileManager.default
        let url = URL(fileURLWithPath: path)

        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) {
            for case let fileURL as URL in enumerator {
                if fileURL.pathExtension == "md" {
                    do {
                        let content = try String(contentsOf: fileURL, encoding: .utf8)
                        let relativePath = String(fileURL.path.dropFirst(path.count))

                        let markdownFile = MarkdownFile(
                            name: fileURL.lastPathComponent,
                            path: fileURL.path,
                            content: content,
                            relativePath: relativePath
                        )

                        markdownFiles.append(markdownFile)
                    } catch {
                        print("Error reading file \(fileURL.path): \(error)")
                    }
                }
            }
        }

        markdownFiles.sort { $0.name < $1.name }
    }

    func navigateToFile(_ linkPath: String, from currentFile: MarkdownFile) {
        let targetPath = resolvePath(linkPath, from: currentFile)

        if let file = markdownFiles.first(where: { $0.path == targetPath }) {
            if Thread.isMainThread {
                self.selectedFile = file
            } else {
                DispatchQueue.main.async {
                    self.selectedFile = file
                }
            }
        } else {
            print("File not found: \(targetPath)")
        }
    }

    private func resolvePath(_ linkPath: String, from currentFile: MarkdownFile) -> String {
        if linkPath.hasPrefix("/") {
            return linkPath
        }

        let currentDir = URL(fileURLWithPath: currentFile.path).deletingLastPathComponent()
        let targetURL = currentDir.appendingPathComponent(linkPath)

        return targetURL.standardized.path
    }
}