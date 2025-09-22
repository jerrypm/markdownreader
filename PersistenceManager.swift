//  PersistenceManager.swift
//  MarkdownReader
//
//  Idea by Jerrypm create by claude code  on 26/06/25.
//  Copyright © 2025 JPM. All rights reserved.

import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()

    private let userDefaults = UserDefaults.standard
    private let recentFoldersKey = "RecentFolders"
    private let lastSelectedFolderKey = "LastSelectedFolder"
    private let expandedFoldersKey = "ExpandedFolders"
    private let maxRecentFolders = 5

    private init() {}

    // MARK: - Recent Folders Management

    func saveRecentFolder(_ path: String) {
        var recentFolders = getRecentFolders()

        // Remove if already exists to avoid duplicates
        recentFolders.removeAll { $0 == path }

        // Add to front
        recentFolders.insert(path, at: 0)

        // Keep only max number of recent folders
        if recentFolders.count > maxRecentFolders {
            recentFolders = Array(recentFolders.prefix(maxRecentFolders))
        }

        userDefaults.set(recentFolders, forKey: recentFoldersKey)
        userDefaults.set(path, forKey: lastSelectedFolderKey)

        print("📁 Saved recent folder: \(path)")
    }

    func getRecentFolders() -> [String] {
        return userDefaults.stringArray(forKey: recentFoldersKey) ?? []
    }

    func getLastSelectedFolder() -> String? {
        return userDefaults.string(forKey: lastSelectedFolderKey)
    }

    func removeRecentFolder(_ path: String) {
        var recentFolders = getRecentFolders()
        recentFolders.removeAll { $0 == path }
        userDefaults.set(recentFolders, forKey: recentFoldersKey)

        // If this was the last selected folder, clear it
        if getLastSelectedFolder() == path {
            userDefaults.removeObject(forKey: lastSelectedFolderKey)
        }

        print("🗑️ Removed recent folder: \(path)")
    }

    func clearAllRecentFolders() {
        userDefaults.removeObject(forKey: recentFoldersKey)
        userDefaults.removeObject(forKey: lastSelectedFolderKey)
        clearExpandedFolders()

        print("🧹 Cleared all recent folders and expanded state")
    }

    // MARK: - Expanded Folders State

    func saveExpandedFolders(_ expandedFolders: Set<String>) {
        let expandedArray = Array(expandedFolders)
        userDefaults.set(expandedArray, forKey: expandedFoldersKey)
    }

    func getExpandedFolders() -> Set<String> {
        let expandedArray = userDefaults.stringArray(forKey: expandedFoldersKey) ?? []
        return Set(expandedArray)
    }

    func clearExpandedFolders() {
        userDefaults.removeObject(forKey: expandedFoldersKey)
    }

    // MARK: - Validation

    func validateFolderExists(_ path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    func cleanupInvalidFolders() {
        let recentFolders = getRecentFolders()
        let validFolders = recentFolders.filter { validateFolderExists($0) }

        if validFolders.count != recentFolders.count {
            userDefaults.set(validFolders, forKey: recentFoldersKey)

            // Check if last selected folder is still valid
            if let lastFolder = getLastSelectedFolder(), !validateFolderExists(lastFolder) {
                userDefaults.removeObject(forKey: lastSelectedFolderKey)
            }

            print("🧹 Cleaned up \(recentFolders.count - validFolders.count) invalid folders")
        }
    }
}