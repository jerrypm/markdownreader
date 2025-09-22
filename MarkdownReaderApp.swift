import SwiftUI

@main
struct MarkdownReaderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 900, minHeight: 700)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .commands {
            SidebarCommands()
            FileCommands()
        }
    }
}

struct FileCommands: Commands {
    var body: some Commands {
        CommandMenu("File") {
            Button("Select Folder...") {
                // This will be handled by the ContentView
            }
            .keyboardShortcut("o", modifiers: .command)
        }
    }
}