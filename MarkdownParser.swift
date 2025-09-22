import Foundation

class MarkdownParser {
    static func parseContent(_ content: String, basePath: String) -> [MarkdownElement] {
        let lines = content.components(separatedBy: .newlines)
        var elements: [MarkdownElement] = []
        var i = 0

        while i < lines.count {
            let line = lines[i]

            if line.hasPrefix("# ") {
                elements.append(.heading1(String(line.dropFirst(2))))
            } else if line.hasPrefix("## ") {
                elements.append(.heading2(String(line.dropFirst(3))))
            } else if line.hasPrefix("### ") {
                elements.append(.heading3(String(line.dropFirst(4))))
            } else if line.hasPrefix("#### ") {
                elements.append(.heading4(String(line.dropFirst(5))))
            } else if line.hasPrefix("```") {
                let language = String(line.dropFirst(3))
                var codeLines: [String] = []
                i += 1

                while i < lines.count && !lines[i].hasPrefix("```") {
                    codeLines.append(lines[i])
                    i += 1
                }

                elements.append(.codeBlock(codeLines.joined(separator: "\n"), language))
            } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
                var listItems: [String] = []

                while i < lines.count && (lines[i].hasPrefix("- ") || lines[i].hasPrefix("* ")) {
                    let item = String(lines[i].dropFirst(2))
                    listItems.append(item)
                    i += 1
                }
                i -= 1

                elements.append(.bulletList(listItems))
            } else if line.trimmingCharacters(in: .whitespaces).isEmpty {
                if !elements.isEmpty {
                    elements.append(.lineBreak)
                }
            } else {
                elements.append(.paragraph(line))
            }

            i += 1
        }

        return elements
    }

    static func parseLinks(in text: String) -> [(text: String, url: String, range: NSRange)] {
        let pattern = #"\[([^\]]+)\]\(([^)]+)\)"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))

        return matches.compactMap { match in
            guard match.numberOfRanges == 3 else { return nil }

            let textRange = Range(match.range(at: 1), in: text)!
            let urlRange = Range(match.range(at: 2), in: text)!

            let linkText = String(text[textRange])
            let linkUrl = String(text[urlRange])

            return (text: linkText, url: linkUrl, range: match.range)
        }
    }
}