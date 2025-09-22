//  MarkdownParser.swift
//  MarkdownReader
//
//  Idea by Jerrypm create by claude code  on 26/06/25.
//  Copyright © 2025 JPM. All rights reserved.

import Foundation

class MarkdownParser {
    static func parseContent(_ content: String, basePath: String) -> [MarkdownElement] {
        let lines = content.components(separatedBy: .newlines)
        var elements: [MarkdownElement] = []
        var i = 0

        while i < lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespaces)

            // Skip empty lines at start, add line breaks between content
            if line.isEmpty {
                if !elements.isEmpty {
                    elements.append(.lineBreak)
                }
                i += 1
                continue
            }

            // Headers
            if line.hasPrefix("# ") {
                elements.append(.heading1(String(line.dropFirst(2)).trimmingCharacters(in: .whitespaces)))
            } else if line.hasPrefix("## ") {
                elements.append(.heading2(String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)))
            } else if line.hasPrefix("### ") {
                elements.append(.heading3(String(line.dropFirst(4)).trimmingCharacters(in: .whitespaces)))
            } else if line.hasPrefix("#### ") {
                elements.append(.heading4(String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)))
            }
            // Horizontal rule
            else if line.hasPrefix("---") || line.hasPrefix("***") || line.hasPrefix("___") {
                elements.append(.horizontalRule)
            }
            // Code blocks
            else if line.hasPrefix("```") {
                let language = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                var codeLines: [String] = []
                i += 1

                while i < lines.count && !lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                    codeLines.append(lines[i])
                    i += 1
                }

                elements.append(.codeBlock(codeLines.joined(separator: "\n"), language))
            }
            // Blockquotes
            else if line.hasPrefix("> ") {
                let quote = String(line.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                elements.append(.blockquote(quote))
            }
            // Bullet lists
            else if line.hasPrefix("- ") || line.hasPrefix("* ") || line.hasPrefix("+ ") {
                var listItems: [String] = []

                while i < lines.count {
                    let currentLine = lines[i].trimmingCharacters(in: .whitespaces)
                    if currentLine.hasPrefix("- ") || currentLine.hasPrefix("* ") || currentLine.hasPrefix("+ ") {
                        let item = String(currentLine.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                        listItems.append(item)
                        i += 1
                    } else {
                        break
                    }
                }
                i -= 1

                elements.append(.bulletList(listItems))
            }
            // Numbered lists
            else if line.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil {
                var listItems: [String] = []
                var currentIndex = i

                while currentIndex < lines.count {
                    let currentLine = lines[currentIndex].trimmingCharacters(in: .whitespaces)
                    if currentLine.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil {
                        // Remove the number and dot prefix (e.g., "1. " from "1. Item text")
                        let regex = try! NSRegularExpression(pattern: #"^\d+\.\s*"#)
                        let range = NSRange(location: 0, length: currentLine.utf16.count)
                        let item = regex.stringByReplacingMatches(in: currentLine, range: range, withTemplate: "")
                        listItems.append(item)
                        currentIndex += 1
                    } else {
                        break
                    }
                }
                i = currentIndex - 1

                elements.append(.numberedList(listItems))
            }
            // Regular paragraph
            else {
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

    static func parseInlineFormatting(in text: String) -> [TextComponent] {
        var components: [TextComponent] = []
        var currentIndex = 0
        let nsString = text as NSString

        // Define patterns for different inline formatting (order matters - bold before italic)
        let patterns = [
            (type: "inlineCode", pattern: #"`([^`]+)`"#, dropCount: 1),
            (type: "link", pattern: #"\[([^\]]+)\]\(([^)]+)\)"#, dropCount: 0),
            (type: "bold", pattern: #"\*\*([^*\n]+)\*\*"#, dropCount: 2),
            (type: "italic", pattern: #"(?<!\*)\*([^*\n]+)\*(?!\*)"#, dropCount: 1)
        ]

        var allMatches: [(type: String, range: NSRange, content: String, url: String?)] = []

        // Find all matches
        for pattern in patterns {
            let regex = try! NSRegularExpression(pattern: pattern.pattern)
            let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))

            for match in matches {
                var content = ""
                var url: String? = nil

                if pattern.type == "link" {
                    if match.numberOfRanges >= 3 {
                        let textRange = match.range(at: 1)
                        let urlRange = match.range(at: 2)
                        content = nsString.substring(with: textRange)
                        url = nsString.substring(with: urlRange)
                    }
                } else {
                    if match.numberOfRanges >= 2 {
                        let contentRange = match.range(at: 1)
                        content = nsString.substring(with: contentRange)
                    }
                }

                allMatches.append((type: pattern.type, range: match.range, content: content, url: url))
            }
        }

        // Sort matches by location
        allMatches.sort { $0.range.location < $1.range.location }

        // Process matches and create components
        for match in allMatches {
            // Add text before this match
            if match.range.location > currentIndex {
                let beforeText = nsString.substring(with: NSRange(location: currentIndex, length: match.range.location - currentIndex))
                if !beforeText.isEmpty {
                    components.append(.text(beforeText))
                }
            }

            // Add the formatted component
            switch match.type {
            case "bold":
                components.append(.bold(match.content))
            case "italic":
                components.append(.italic(match.content))
            case "inlineCode":
                components.append(.inlineCode(match.content))
            case "link":
                components.append(.link(match.content, match.url ?? ""))
            default:
                components.append(.text(match.content))
            }

            currentIndex = match.range.location + match.range.length
        }

        // Add remaining text
        if currentIndex < nsString.length {
            let remainingText = nsString.substring(from: currentIndex)
            if !remainingText.isEmpty {
                components.append(.text(remainingText))
            }
        }

        // If no formatting was found, return the whole text as a single component
        if components.isEmpty {
            components.append(.text(text))
        }

        return components
    }
}