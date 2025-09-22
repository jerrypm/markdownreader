import SwiftUI

struct ContentView: View {
    @StateObject private var fileManager = DocumentFileManager()
    @State private var selectedFile: MarkdownFile?

    var body: some View {
        NavigationSplitView {
            SidebarView(
                files: fileManager.markdownFiles,
                selectedFile: $selectedFile,
                onSelectFolder: {
                    fileManager.selectFolder()
                }
            )
        } detail: {
            if let selectedFile = selectedFile {
                MarkdownView(
                    file: selectedFile,
                    onLinkTapped: { linkPath in
                        fileManager.navigateToFile(linkPath, from: selectedFile)
                    }
                )
            } else {
                EmptyStateView {
                    fileManager.selectFolder()
                }
            }
        }
        .onAppear {
            // Start with empty sidebar - user must select folder
        }
        .onReceive(fileManager.$selectedFile) { newFile in
            if let newFile = newFile, newFile.id != selectedFile?.id {
                selectedFile = newFile
            }
        }
        .onReceive(fileManager.$markdownFiles) { newFiles in
            // Auto-select first file when new files are loaded
            if selectedFile == nil && !newFiles.isEmpty {
                selectedFile = newFiles.first
            }
        }
    }
}

struct EmptyStateView: View {
    let onSelectFolder: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("Welcome to Markdown Reader")
                .font(.title2)
                .fontWeight(.medium)

            Text("Select a folder containing markdown files to get started")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Select Folder") {
                onSelectFolder()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}