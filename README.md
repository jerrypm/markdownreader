# Markdown Reader

A modern macOS application for reading and navigating markdown files with an intuitive folder-based interface.

## Features

### 📁 **Folder Management**
- **Smart Folder Selection**: Browse and select folders containing markdown files
- **Recent Folders**: Quick access to recently opened folders with persistent storage
- **Folder Persistence**: Remembers last opened folder across app restarts
- **Remove Folders**: Remove unwanted folders from recent list

### 📄 **Markdown Viewing**
- **Rich Markdown Rendering**: Full markdown support with proper formatting
- **Syntax Highlighting**: Swift code blocks with Xcode color scheme
- **Link Navigation**: Click on relative markdown links to navigate between files
- **Clean Reading Interface**: Distraction-free reading experience

### 🗂 **File Navigation**
- **Sidebar Explorer**: Tree-view navigation of markdown files and folders
- **Expandable Folders**: Show/hide folder contents with smooth animations
- **Persistent State**: Folder expansion state maintained across app sessions
- **File Selection**: Quick file switching with visual selection feedback

### 🎨 **User Interface**
- **Native macOS Design**: Built with SwiftUI for modern macOS experience
- **Smooth Animations**: Fluid folder expand/collapse animations
- **App Icon**: Custom markdown logo for easy identification
- **Responsive Layout**: Adaptive interface that works on different screen sizes

### 💾 **Data Persistence**
- **Recent Folders Storage**: Up to 5 recent folders saved automatically
- **Folder State Memory**: Expanded/collapsed folder states persist
- **Last Session Restore**: Automatically reopens last selected folder
- **Clean Data Management**: Easy clearing of all stored data

## How to Use

### 🚀 **Getting Started**

1. **Launch the App**: Double-click `MarkdownReader.app` to start
2. **Select a Folder**: Click the folder icon (📁+) to choose a directory containing markdown files
3. **Browse Files**: Use the sidebar to navigate through your markdown files
4. **Read Content**: Click on any file to view its contents in the main area

### 📁 **Working with Folders**

#### Adding Folders
- Click the **folder icon** in the sidebar header
- Select any directory containing `.md` files
- The folder will be added to your recent folders list automatically

#### Recent Folders Menu
- Click the **clock icon** (🕐) to see recent folders
- Click any recent folder to quickly switch to it
- Click the **X** button next to a folder to remove it from the list
- Use **"Clear All Recent"** to remove all folders and reset the app

#### Folder Navigation
- Click on folder names to **expand/collapse** their contents
- Folder expansion state is **automatically saved**
- Nested folders are supported and properly organized

### 📖 **Reading Markdown**

#### File Selection
- Click on any `.md` file in the sidebar to open it
- Selected files are highlighted for easy identification
- Content appears instantly in the main reading area

#### Link Navigation
- Click on relative markdown links (e.g., `[link](./other-file.md)`)
- Automatically navigates to linked files in the same folder
- Supports standard markdown link formats

#### Code Highlighting
- Swift code blocks are automatically highlighted
- Uses **Xcode color scheme** for familiar syntax coloring
- Supports other programming languages with basic highlighting

### ⚙️ **App Management**

#### Data Persistence
- **Automatic Saving**: Recent folders and states are saved automatically
- **Session Restore**: Last opened folder loads on app restart
- **State Memory**: Folder expand/collapse states persist between sessions

#### Clearing Data
- Use **"Clear All Recent"** to remove all saved folders
- This also clears folder expansion states
- Useful for starting fresh or troubleshooting

## Building from Source

### Requirements
- **macOS 13.0+** (Ventura or later)
- **Swift 5.5+**
- **Xcode Command Line Tools** (for building without Xcode)

### Build Instructions

1. **Clone or Download** the project
2. **Open Terminal** and navigate to project directory
3. **Run the build script**:
   ```bash
   ./build.sh
   ```
4. **Launch the app**:
   ```bash
   open MarkdownReader.app
   ```

### Build Script Features
- **Automatic Compilation**: Builds Swift code with production optimizations
- **Icon Generation**: Creates proper macOS app icon from PNG source
- **App Bundle Creation**: Generates complete `.app` bundle structure
- **No Xcode Required**: Uses Swift Package Manager for building

## Technical Details

### Architecture
- **SwiftUI Framework**: Modern declarative UI framework
- **MVVM Pattern**: Clean separation of concerns
- **State Management**: Reactive state updates with `@Published` and `@StateObject`
- **Persistence Layer**: UserDefaults-based data storage

### File Structure
```
MarkdownReader/
├── MarkdownReaderApp.swift      # App entry point
├── ContentView.swift            # Main app layout
├── SidebarView.swift            # File navigation sidebar
├── MarkdownView.swift           # Markdown content renderer
├── FileManager.swift            # File system operations
├── PersistenceManager.swift     # Data persistence
├── Models.swift                 # Data models
├── MarkdownParser.swift         # Markdown processing
├── SwiftCodeView.swift          # Code syntax highlighting
├── build.sh                     # Build automation script
└── logo-md.png                  # App icon source
```

### Key Technologies
- **Swift Package Manager**: Dependency-free building
- **NSOpenPanel**: Native file/folder selection
- **UserDefaults**: Lightweight data persistence
- **NSAttributedString**: Rich text rendering
- **SwiftUI Navigation**: Modern navigation patterns

## Troubleshooting

### Common Issues

**App Won't Launch**
- Ensure macOS 13.0+ is installed
- Check that app has proper permissions
- Try rebuilding with `./build.sh`

**Folders Not Showing**
- Verify the selected directory contains `.md` files
- Check folder permissions are readable
- Try clearing recent folders and re-adding

**Links Not Working**
- Ensure linked files exist in the same directory
- Check that links use relative paths (e.g., `./file.md`)
- Verify linked files have `.md` extension

**State Not Persisting**
- Check app has write permissions for UserDefaults
- Try clearing all data and starting fresh
- Restart the app to reload saved state

## License

Copyright © 2025 Jerrypm. All rights reserved.

Created by Claude Code with inspiration from Jerrypm.

---

## Support

For issues, questions, or feature requests, please refer to the project documentation or contact the development team.

**Enjoy reading your markdown files! 📚✨**