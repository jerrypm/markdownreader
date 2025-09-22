//  Models.swift
//  MarkdownReader
//
//  Idea by Jerrypm create by claude code  on 26/06/25.
//  Copyright © 2025 JPM. All rights reserved.

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
    case inlineCode(String)
    case bulletList([String])
    case numberedList([String])
    case blockquote(String)
    case horizontalRule
    case lineBreak
}

enum TextComponent {
    case text(String)
    case link(String, String)
    case bold(String)
    case italic(String)
    case inlineCode(String)
}