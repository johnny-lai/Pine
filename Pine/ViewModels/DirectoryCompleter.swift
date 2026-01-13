//
//  DirectoryCompleter.swift
//  Pine
//
//  Created by Claude on 1/12/26.
//

import Foundation


func expandPath(_ path: String, relativeTo currentDir: String) -> String {
    if path.hasPrefix("~/") {
        return (path as NSString).expandingTildeInPath
    } else if path.hasPrefix("/") {
        return path
    } else {
        return (currentDir as NSString).appendingPathComponent(path)
    }
}

func splitPath(_ path: String) -> (directory: String, prefix: String) {
    if path.hasSuffix("/") || path.isEmpty {
        // User typed trailing slash - complete from this directory
        return (path.isEmpty ? "/" : path, "")
    } else {
        // Complete the last component
        let directory = (path as NSString).deletingLastPathComponent
        let prefix = (path as NSString).lastPathComponent
        return (directory.isEmpty ? "/" : directory, prefix)
    }
}

/// Handles directory path completion for the `/cd` command
@Observable
class DirectoryCompleter {
    private let fileManager = FileManager.default

    /// Current completion state
    var currentSuggestions: [String] = []
    var lastCompletionPrefix: String = ""
    var tabPressCount: Int = 0

    /// Get directory completions for a partial path
    func getCompletions(for path: String, currentDirectory: String) -> [String] {
        let expandedPath = expandPath(path, relativeTo: currentDirectory)
        let (directory, prefix) = splitPath(expandedPath)

        guard let contents = try? fileManager.contentsOfDirectory(atPath: directory) else {
            return []
        }

        // Filter directories matching prefix
        return contents
            .filter { name in
                // Check if it's a directory
                var isDir: ObjCBool = false
                let fullPath = (directory as NSString).appendingPathComponent(name)
                guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDir),
                      isDir.boolValue else { return false }

                // Include hidden directories only if prefix starts with '.'
                if !prefix.hasPrefix(".") && name.hasPrefix(".") {
                    return false
                }

                // Check if name starts with prefix (case-insensitive on macOS)
                return name.lowercased().hasPrefix(prefix.lowercased())
            }
            .sorted()
    }

    /// Result of tab completion
    enum CompletionResult {
        case noMatches
        case singleMatch(String)
        case commonPrefix(String)
        case showDropdown([String])
    }

    /// Complete path on tab press
    func complete(_ input: String, currentDirectory: String) -> CompletionResult {
        // Extract the path after '/cd '
        guard input.hasPrefix("/cd ") else { return .noMatches }
        let path = String(input.dropFirst(4))

        // If this is a new prefix, get fresh completions and reset tab count
        if path != lastCompletionPrefix {
            currentSuggestions = getCompletions(for: path, currentDirectory: currentDirectory)
            lastCompletionPrefix = path
            tabPressCount = 0
        }

        guard !currentSuggestions.isEmpty else { return .noMatches }

        // Increment tab press count
        tabPressCount += 1

        // If only one match, complete it immediately
        if currentSuggestions.count == 1 {
            let completed = buildCompletedPath(path, suggestion: currentSuggestions[0], currentDirectory: currentDirectory)
            return .singleMatch(completed)
        }

        // Multiple matches
        if tabPressCount == 1 {
            // First tab: complete to common prefix
            if let commonPrefix = findCommonPrefix(currentSuggestions) {
                let completed = buildCompletedPath(path, suggestion: commonPrefix, currentDirectory: currentDirectory, addTrailingSlash: false)
                return .commonPrefix(completed)
            } else {
                // No common prefix, show dropdown immediately
                return .showDropdown(currentSuggestions)
            }
        } else {
            // Second tab: show dropdown
            return .showDropdown(currentSuggestions)
        }
    }

    /// Find the longest common prefix among suggestions
    private func findCommonPrefix(_ suggestions: [String]) -> String? {
        guard suggestions.count > 1 else { return suggestions.first }

        var prefix = suggestions[0]

        for suggestion in suggestions.dropFirst() {
            while !suggestion.hasPrefix(prefix) && !prefix.isEmpty {
                prefix = String(prefix.dropLast())
            }
            if prefix.isEmpty {
                return nil
            }
        }

        // Only return if it's longer than what we already have
        return prefix.isEmpty ? nil : prefix
    }

    /// Reset completion state (call when text changes not from Tab)
    func reset() {
        currentSuggestions = []
        lastCompletionPrefix = ""
        tabPressCount = 0
    }

    // MARK: - Helper Methods

    private func buildCompletedPath(_ originalPath: String, suggestion: String, currentDirectory: String, addTrailingSlash: Bool = true) -> String {
        let expandedPath = expandPath(originalPath, relativeTo: currentDirectory)
        let (directory, _) = splitPath(expandedPath)
        let completed = (directory as NSString).appendingPathComponent(suggestion)

        // Normalize the path
        let normalized = (completed as NSString).standardizingPath

        // Add trailing slash if requested (for full completions)
        if addTrailingSlash {
            return "/cd \(normalized)/"
        } else {
            return "/cd \(normalized)"
        }
    }
}
