//  ContentView.swift
//  MarkdownReader
//
//  Idea by Jerrypm create by claude code  on 26/06/25.
//  Copyright © 2025 JPM. All rights reserved.

import SwiftUI

struct ContentView: View {
    @StateObject private var fileManager = DocumentFileManager()
    @State private var selectedFile: MarkdownFile?

    var body: some View {
        NavigationSplitView {
            SidebarView(
                files: fileManager.markdownFiles,
                selectedFile: $selectedFile,
                fileManager: fileManager
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
                EmptyStateView(fileManager: fileManager)
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
    let fileManager: DocumentFileManager

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("Welcome to Markdown Reader")
                .font(.title2)
                .fontWeight(.medium)

            Text("Select a folder containing markdown files to get started")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                Button("Select Folder") {
                    fileManager.selectFolder()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                // Show recent folders if available
                if !fileManager.recentFolders.isEmpty {
                    Text("or choose from recent:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 8) {
                        ForEach(fileManager.recentFolders.prefix(3), id: \.self) { folderPath in
                            Button(action: {
                                fileManager.loadRecentFolder(folderPath)
                            }) {
                                HStack {
                                    Image(systemName: "folder")
                                        .foregroundColor(.blue)
                                    Text(URL(fileURLWithPath: folderPath).lastPathComponent)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
        .padding()
    }
}