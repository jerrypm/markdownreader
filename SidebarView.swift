import SwiftUI

struct SidebarView: View {
    let files: [MarkdownFile]
    @Binding var selectedFile: MarkdownFile?
    let onSelectFolder: () -> Void

    @State private var expandedFolders: Set<String> = []

    var body: some View {
        VStack(spacing: 0) {
            // Header with folder selection button
            HStack {
                Text("Files")
                    .font(.headline)
                Spacer()
                Button(action: onSelectFolder) {
                    Image(systemName: "folder.badge.plus")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Select folder")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // File list
            List {
                if files.isEmpty {
                    VStack {
                        Image(systemName: "folder")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No markdown files found")
                            .foregroundColor(.secondary)
                        Text("Click the folder icon to select a directory")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    Section("Documentation") {
                        ForEach(fileStructure, id: \.id) { node in
                            FileRowView(
                                node: node,
                                selectedFile: $selectedFile,
                                expandedFolders: $expandedFolders
                            )
                        }
                    }
                }
            }
            .listStyle(SidebarListStyle())
        }
        .frame(minWidth: 250)
    }

    private var fileStructure: [FileNode] {
        var structure: [FileNode] = []

        // Group files by their actual directory structure
        let groupedFiles = Dictionary(grouping: files) { file in
            let url = URL(fileURLWithPath: file.path)
            let parentDir = url.deletingLastPathComponent().lastPathComponent
            return parentDir
        }

        for (folderName, filesInFolder) in groupedFiles.sorted(by: { $0.key < $1.key }) {
            // Only treat actual directories as folders, not individual files
            if filesInFolder.count > 1 || folderName != filesInFolder.first?.displayName {
                // This is a real folder with multiple files
                let fullFolderPath = filesInFolder.first?.path.components(separatedBy: "/").dropLast().joined(separator: "/") ?? folderName
                let folderNode = FileNode(
                    name: folderName,
                    isFolder: true,
                    children: filesInFolder.sorted { $0.name < $1.name }.map { file in
                        FileNode(name: file.displayName, isFolder: false, file: file, folderPath: file.path)
                    },
                    folderPath: fullFolderPath
                )
                structure.append(folderNode)
            } else {
                // Single file in root or other location
                for file in filesInFolder.sorted(by: { $0.name < $1.name }) {
                    structure.append(FileNode(name: file.displayName, isFolder: false, file: file, folderPath: file.path))
                }
            }
        }

        return structure
    }
}

struct FileRowView: View {
    let node: FileNode
    @Binding var selectedFile: MarkdownFile?
    @Binding var expandedFolders: Set<String>

    private var isExpanded: Bool {
        expandedFolders.contains(node.folderPath)
    }

    var body: some View {
        if node.isFolder {
            VStack(alignment: .leading, spacing: 0) {
                // Folder header - clickable to expand/collapse
                HStack {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 12)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)

                    Image(systemName: "folder.fill")
                        .foregroundColor(.blue)

                    Text(node.name)
                        .font(.headline)

                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)) {
                        // Toggle this specific folder using unique folderPath
                        if expandedFolders.contains(node.folderPath) {
                            expandedFolders.remove(node.folderPath)
                            print("🔽 Collapsed folder: \(node.name) (\(node.folderPath)) - Now expanded: \(expandedFolders)")
                        } else {
                            expandedFolders.insert(node.folderPath)
                            print("🔼 Expanded folder: \(node.name) (\(node.folderPath)) - Now expanded: \(expandedFolders)")
                        }
                    }
                }
                .padding(.vertical, 4)

                // Children - only show when expanded with smooth animation
                if isExpanded {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(node.children, id: \.id) { child in
                            FileRowView(
                                node: child,
                                selectedFile: $selectedFile,
                                expandedFolders: $expandedFolders
                            )
                            .padding(.leading, 20)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
                        }
                    }
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)).combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .scale(scale: 0.95))
                        )
                    )
                }
            }
        } else {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.secondary)
                Text(node.name)
                    .foregroundColor(.primary)
                Spacer()
            }
            .contentShape(Rectangle())
            .background(
                selectedFile?.id == node.file?.id ?
                Color.accentColor.opacity(0.2) : Color.clear
            )
            .cornerRadius(6)
            .onTapGesture {
                if let file = node.file {
                    selectedFile = file
                }
            }
        }
    }
}