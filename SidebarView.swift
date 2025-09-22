//  SidebarView.swift
//  MarkdownReader
//
//  Idea by Jerrypm create by claude code  on 26/06/25.
//  Copyright © 2025 JPM. All rights reserved.

import SwiftUI

// MARK: - Animation Configuration
struct AnimationConfig {
    static let folderToggle = Animation.easeInOut(duration: 0.25)
    static let fileSelection = Animation.easeInOut(duration: 0.2)
    static let folderContentTransition = AnyTransition.asymmetric(
        insertion: .move(edge: .top).combined(with: .opacity),
        removal: .move(edge: .top).combined(with: .opacity)
    )
}

struct SidebarView: View {
    let files: [MarkdownFile]
    @Binding var selectedFile: MarkdownFile?
    let fileManager: DocumentFileManager

    @State private var expandedFolders: Set<String> = []
    @State private var showingRecentFolders = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with folder selection and recent folders
            HStack {
                Text("Files")
                    .font(.headline)
                Spacer()

                // Recent folders menu
                if !fileManager.recentFolders.isEmpty {
                    Menu {
                        ForEach(fileManager.recentFolders, id: \.self) { folderPath in
                            Button(action: {
                                fileManager.loadRecentFolder(folderPath)
                            }) {
                                HStack {
                                    Image(systemName: "folder")
                                    Text(URL(fileURLWithPath: folderPath).lastPathComponent)
                                    Spacer()
                                    Button(action: {
                                        fileManager.removeRecentFolder(folderPath)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }

                        Divider()

                        Button("Clear All Recent") {
                            fileManager.clearAllRecentFolders()
                            expandedFolders.removeAll()
                        }
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.orange)
                    }
                    .help("Recent folders")
                }

                // Select new folder button
                Button(action: {
                    fileManager.selectFolder()
                }) {
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
        .onAppear {
            loadExpandedFoldersState()
        }
        .onChange(of: expandedFolders) { newValue in
            saveExpandedFoldersState()
        }
    }

    private func loadExpandedFoldersState() {
        expandedFolders = PersistenceManager.shared.getExpandedFolders()
    }

    private func saveExpandedFoldersState() {
        PersistenceManager.shared.saveExpandedFolders(expandedFolders)
    }

    private var fileStructure: [FileNode] {
        var structure: [FileNode] = []

        // Group files by their actual directory structure
        let groupedFiles = Dictionary(grouping: files) { file in
            let url = URL(fileURLWithPath: file.path)
            let parentDir = url.deletingLastPathComponent().lastPathComponent
            return parentDir
        }

        // Sort folders by name for consistent ordering
        for (folderName, filesInFolder) in groupedFiles.sorted(by: { $0.key < $1.key }) {
            // Only treat actual directories as folders, not individual files
            if filesInFolder.count > 1 || folderName != filesInFolder.first?.displayName {
                // Create a stable identifier based on actual directory path, not index
                let actualFolderPath = filesInFolder.first?.path.components(separatedBy: "/").dropLast().joined(separator: "/") ?? ""
                let uniqueFolderPath = "FOLDER_\(actualFolderPath.replacingOccurrences(of: "/", with: "_"))_\(folderName)"

                let folderNode = FileNode(
                    name: folderName,
                    isFolder: true,
                    children: filesInFolder.sorted { $0.name < $1.name }.map { file in
                        FileNode(name: file.displayName, isFolder: false, file: file, folderPath: file.path)
                    },
                    folderPath: uniqueFolderPath
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

                    Image(systemName: "folder.fill")
                        .foregroundColor(.blue)

                    Text(node.name)
                        .font(.headline)

                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    toggleFolder()
                }
                .padding(.vertical, 4)

                // Children - with smooth slide animation
                if isExpanded {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(node.children, id: \.id) { child in
                            FileRowView(
                                node: child,
                                selectedFile: $selectedFile,
                                expandedFolders: $expandedFolders
                            )
                            .padding(.leading, 20)
                        }
                    }
                    .transition(AnimationConfig.folderContentTransition)
                }
            }
            .animation(AnimationConfig.folderToggle, value: isExpanded)
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
            .animation(AnimationConfig.fileSelection, value: selectedFile?.id)
            .onTapGesture {
                if let file = node.file {
                    withAnimation(AnimationConfig.fileSelection) {
                        selectedFile = file
                    }
                }
            }
        }
    }

    private func toggleFolder() {
        withAnimation(AnimationConfig.folderToggle) {
            if expandedFolders.contains(node.folderPath) {
                expandedFolders.remove(node.folderPath)
            } else {
                expandedFolders.insert(node.folderPath)
            }
        }
    }
}