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
            renderTextWithLinks(text)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 16)
                .padding(.bottom, 8)

        case .heading2(let text):
            renderTextWithLinks(text)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 12)
                .padding(.bottom, 6)

        case .heading3(let text):
            renderTextWithLinks(text)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 8)
                .padding(.bottom, 4)

        case .heading4(let text):
            renderTextWithLinks(text)
                .font(.title3)
                .fontWeight(.medium)
                .padding(.top, 6)
                .padding(.bottom, 3)

        case .paragraph(let text):
            renderTextWithLinks(text)
                .font(.body)
                .lineSpacing(2)

        case .codeBlock(let code, let language):
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading) {
                    if !language.isEmpty {
                        HStack {
                            Text(language)
                                .font(.caption)
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
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                        )
                )
            }

        case .bulletList(let items):
            VStack(alignment: .leading, spacing: 4) {
                ForEach(items.indices, id: \.self) { index in
                    HStack(alignment: .top) {
                        Text("•")
                            .font(.body)
                            .padding(.trailing, 4)
                        renderTextWithLinks(items[index])
                            .font(.body)
                    }
                }
            }
            .padding(.leading, 16)

        case .lineBreak:
            Spacer()
                .frame(height: 8)
        }
    }

    @ViewBuilder
    private func renderTextWithLinks(_ text: String) -> some View {
        let links = MarkdownParser.parseLinks(in: text)

        if links.isEmpty {
            Text(text)
                .textSelection(.enabled)
        } else {
            let components = createTextComponents(from: text, links: links)

            HStack(alignment: .top, spacing: 0) {
                ForEach(components.indices, id: \.self) { index in
                    switch components[index] {
                    case .text(let content):
                        Text(content)
                            .textSelection(.enabled)
                    case .link(let linkText, let url):
                        Button(linkText) {
                            handleLinkNavigation(url)
                        }
                        .buttonStyle(LinkButtonStyle())
                    }
                }
            }
        }
    }

    private func createTextComponents(from text: String, links: [(text: String, url: String, range: NSRange)]) -> [TextComponent] {
        var components: [TextComponent] = []
        var lastIndex = 0

        for link in links.sorted(by: { $0.range.location < $1.range.location }) {
            if link.range.location > lastIndex {
                let beforeText = String(text[text.index(text.startIndex, offsetBy: lastIndex)..<text.index(text.startIndex, offsetBy: link.range.location)])
                if !beforeText.isEmpty {
                    components.append(.text(beforeText))
                }
            }

            components.append(.link(link.text, link.url))
            lastIndex = link.range.location + link.range.length
        }

        if lastIndex < text.count {
            let afterText = String(text[text.index(text.startIndex, offsetBy: lastIndex)...])
            if !afterText.isEmpty {
                components.append(.text(afterText))
            }
        }

        return components
    }

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