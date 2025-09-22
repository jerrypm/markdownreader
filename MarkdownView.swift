//  MarkdownView.swift
//  MarkdownReader
//
//  Idea by Jerrypm create by claude code  on 26/06/25.
//  Copyright © 2025 JPM. All rights reserved.

import SwiftUI
import Combine

struct MarkdownView: View {
    let file: MarkdownFile
    let onLinkTapped: (String) -> Void

    @State private var elements: [MarkdownElement] = []

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(elements.indices, id: \.self) { index in
                    renderElement(elements[index])
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .onAppear {
            parseMarkdown()
        }
        .id(file.id)
        .navigationTitle(file.displayName)
    }

    private func parseMarkdown() {
        elements = MarkdownParser.parseContent(file.content, basePath: file.path)
    }

    @ViewBuilder
    private func renderElement(_ element: MarkdownElement) -> some View {
        switch element {
        case .heading1(let text):
            renderFormattedText(text)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
                .padding(.bottom, 10)

        case .heading2(let text):
            renderFormattedText(text)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 16)
                .padding(.bottom, 8)

        case .heading3(let text):
            renderFormattedText(text)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 12)
                .padding(.bottom, 6)

        case .heading4(let text):
            renderFormattedText(text)
                .font(.title3)
                .fontWeight(.medium)
                .padding(.top, 8)
                .padding(.bottom, 4)

        case .paragraph(let text):
            renderFormattedText(text)
                .font(.body)
                .lineSpacing(4)

        case .codeBlock(let code, let language):
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    if !language.isEmpty {
                        HStack {
                            Text(language.uppercased())
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }

                    if language.lowercased() == "swift" {
                        SwiftCodeView(code: code)
                    } else {
                        Text(code)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                            .foregroundColor(.primary)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                        )
                )
            }

        case .inlineCode(let code):
            Text(code)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(4)

        case .bulletList(let items):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(items.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                        renderFormattedText(items[index])
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.leading, 16)

        case .numberedList(let items):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(items.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                        renderFormattedText(items[index])
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.leading, 16)

        case .blockquote(let text):
            HStack(alignment: .top, spacing: 12) {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: 4)
                VStack(alignment: .leading) {
                    renderFormattedText(text)
                        .font(.body)
                        .italic()
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 16)

        case .horizontalRule:
            Divider()
                .padding(.vertical, 8)

        case .lineBreak:
            Spacer()
                .frame(height: 12)
        }
    }

    @ViewBuilder
    private func renderFormattedText(_ text: String) -> some View {
        let components = MarkdownParser.parseInlineFormatting(in: text)

        // Use a wrapping flow layout that properly handles text
        FlowLayout(components: components, onLinkTapped: handleLinkNavigation)
    }
}

struct FlowLayout: View {
    let components: [TextComponent]
    let onLinkTapped: (String) -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            // First try horizontal layout
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                ForEach(components.indices, id: \.self) { index in
                    componentView(components[index])
                }
            }

            // If too wide, use wrapping layout
            VStack(alignment: .leading, spacing: 2) {
                ForEach(components.indices, id: \.self) { index in
                    componentView(components[index])
                }
            }
        }
    }

    @ViewBuilder
    private func componentView(_ component: TextComponent) -> some View {
        switch component {
        case .text(let content):
            Text(content)
                .textSelection(.enabled)
        case .link(let linkText, let url):
            Button(linkText) {
                onLinkTapped(url)
            }
            .buttonStyle(LinkButtonStyle())
        case .bold(let content):
            Text(content)
                .fontWeight(.bold)
                .textSelection(.enabled)
        case .italic(let content):
            Text(content)
                .italic()
                .textSelection(.enabled)
        case .inlineCode(let content):
            Text(content)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(4)
                .textSelection(.enabled)
        }
    }
}

extension MarkdownView {
    private func handleLinkNavigation(_ link: String) {
        if link.hasSuffix(".md") && !link.hasPrefix("http") {
            onLinkTapped(link)
        } else if link.hasPrefix("http") {
            if let url = URL(string: link) {
                NSWorkspace.shared.open(url)
            }
        }
    }
}