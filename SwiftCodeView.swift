//  SwiftCodeView.swift
//  MarkdownReader
//
//  Idea by Jerrypm create by claude code  on 26/06/25.
//  Copyright © 2025 JPM. All rights reserved.

import SwiftUI

struct SwiftCodeView: View {
    let code: String

    var body: some View {
        let attributedString = highlightSwiftCode(code)

        Text(AttributedString(attributedString))
            .font(.system(.body, design: .monospaced))
            .textSelection(.enabled)
    }

    private func highlightSwiftCode(_ code: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: code)
        let range = NSRange(location: 0, length: code.count)

        // Base text color (Xcode default)
        attributedString.addAttribute(.foregroundColor, value: NSColor.textColor, range: range)

        // First highlight strings and comments (these should take priority)
        // Strings (red in Xcode) - improved pattern to handle content better
        highlightPattern("\"[^\"]*\"", in: attributedString, color: NSColor.systemRed)

        // Multi-line strings
        highlightPattern("\"\"\"[\\s\\S]*?\"\"\"", in: attributedString, color: NSColor.systemRed)

        // Comments (green in Xcode)
        highlightPattern("//.*$", in: attributedString, color: NSColor.systemGreen)
        highlightPattern("/\\*[\\s\\S]*?\\*/", in: attributedString, color: NSColor.systemGreen)

        // Then highlight other elements (avoiding strings and comments)
        // Swift keywords (purple in Xcode) - but not inside strings or comments
        let keywords = [
            "import", "class", "struct", "enum", "protocol", "extension", "func", "var", "let",
            "if", "else", "for", "while", "switch", "case", "default", "return", "break", "continue",
            "public", "private", "internal", "fileprivate", "open", "static", "final", "override",
            "init", "deinit", "self", "super", "nil", "true", "false", "weak", "strong", "unowned",
            "mutating", "nonmutating", "lazy", "required", "optional", "throws", "rethrows", "try",
            "catch", "defer", "guard", "where", "as", "is", "in", "inout", "@objc", "@main"
        ]

        for keyword in keywords {
            highlightKeywordOutsideStringsAndComments("\\b\(keyword)\\b", in: attributedString, color: NSColor.systemPurple)
        }

        // Numbers (blue in Xcode) - but not inside strings or comments
        highlightKeywordOutsideStringsAndComments("\\b\\d+(\\.\\d+)?\\b", in: attributedString, color: NSColor.systemBlue)

        // Types and classes (teal/cyan in Xcode) - but not inside strings or comments
        highlightKeywordOutsideStringsAndComments("\\b[A-Z][a-zA-Z0-9_]*\\b", in: attributedString, color: NSColor.systemTeal)

        return attributedString
    }

    private func highlightPattern(_ pattern: String, in attributedString: NSMutableAttributedString, color: NSColor) {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
            let range = NSRange(location: 0, length: attributedString.length)
            let matches = regex.matches(in: attributedString.string, options: [], range: range)

            for match in matches {
                attributedString.addAttribute(.foregroundColor, value: color, range: match.range)
            }
        } catch {
            print("Regex error: \(error)")
        }
    }

    private func highlightKeywordOutsideStringsAndComments(_ pattern: String, in attributedString: NSMutableAttributedString, color: NSColor) {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
            let range = NSRange(location: 0, length: attributedString.length)
            let matches = regex.matches(in: attributedString.string, options: [], range: range)

            // Get ranges of strings and comments to avoid
            let stringRanges = getStringRanges(in: attributedString.string)
            let commentRanges = getCommentRanges(in: attributedString.string)
            let avoidRanges = stringRanges + commentRanges

            for match in matches {
                // Check if this match is inside a string or comment
                var shouldHighlight = true
                for avoidRange in avoidRanges {
                    if NSLocationInRange(match.range.location, avoidRange) {
                        shouldHighlight = false
                        break
                    }
                }

                if shouldHighlight {
                    attributedString.addAttribute(.foregroundColor, value: color, range: match.range)
                }
            }
        } catch {
            print("Regex error: \(error)")
        }
    }

    private func getStringRanges(in text: String) -> [NSRange] {
        var ranges: [NSRange] = []
        do {
            // Regular strings
            let stringRegex = try NSRegularExpression(pattern: "\"[^\"]*\"", options: [])
            let stringMatches = stringRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
            ranges.append(contentsOf: stringMatches.map { $0.range })

            // Multi-line strings
            let multiStringRegex = try NSRegularExpression(pattern: "\"\"\"[\\s\\S]*?\"\"\"", options: [])
            let multiStringMatches = multiStringRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
            ranges.append(contentsOf: multiStringMatches.map { $0.range })
        } catch {
            print("String regex error: \(error)")
        }
        return ranges
    }

    private func getCommentRanges(in text: String) -> [NSRange] {
        var ranges: [NSRange] = []
        do {
            // Single line comments
            let commentRegex = try NSRegularExpression(pattern: "//.*$", options: [.anchorsMatchLines])
            let commentMatches = commentRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
            ranges.append(contentsOf: commentMatches.map { $0.range })

            // Multi-line comments
            let multiCommentRegex = try NSRegularExpression(pattern: "/\\*[\\s\\S]*?\\*/", options: [])
            let multiCommentMatches = multiCommentRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
            ranges.append(contentsOf: multiCommentMatches.map { $0.range })
        } catch {
            print("Comment regex error: \(error)")
        }
        return ranges
    }
}

struct LinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.blue)
            .underline()
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}