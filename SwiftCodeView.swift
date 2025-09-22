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

        // Swift keywords (purple in Xcode)
        let keywords = [
            "import", "class", "struct", "enum", "protocol", "extension", "func", "var", "let",
            "if", "else", "for", "while", "switch", "case", "default", "return", "break", "continue",
            "public", "private", "internal", "fileprivate", "open", "static", "final", "override",
            "init", "deinit", "self", "super", "nil", "true", "false", "weak", "strong", "unowned",
            "mutating", "nonmutating", "lazy", "required", "optional", "throws", "rethrows", "try",
            "catch", "defer", "guard", "where", "as", "is", "in", "inout", "@objc", "@main"
        ]

        for keyword in keywords {
            highlightPattern("\\b\(keyword)\\b", in: attributedString, color: NSColor.systemPurple)
        }

        // Strings (red in Xcode)
        highlightPattern("\".*?\"", in: attributedString, color: NSColor.systemRed)

        // Comments (green in Xcode)
        highlightPattern("//.*$", in: attributedString, color: NSColor.systemGreen)
        highlightPattern("/\\*[\\s\\S]*?\\*/", in: attributedString, color: NSColor.systemGreen)

        // Numbers (blue in Xcode)
        highlightPattern("\\b\\d+(\\.\\d+)?\\b", in: attributedString, color: NSColor.systemBlue)

        // Types and classes (teal/cyan in Xcode)
        highlightPattern("\\b[A-Z][a-zA-Z0-9_]*\\b", in: attributedString, color: NSColor.systemTeal)

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
}

struct LinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.blue)
            .underline()
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}