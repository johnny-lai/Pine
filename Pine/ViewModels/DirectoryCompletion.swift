//
//  DirectoryCompletion.swift
//  Pine
//
//  Created by Claude on 1/17/26.
//

import Foundation

/// Completion strategy for directory paths (used by /cd command)
class DirectoryCompletion: CompletionStrategy {
    private let fileManager = FileManager.default

    func canHandle(_ input: String) -> Bool {
        return input.hasPrefix("/cd ")
    }

    func getCompletions(for input: String, currentDirectory: String) -> [String] {
        // Extract path after "/cd "
        guard input.hasPrefix("/cd ") else { return [] }
        let path = String(input.dropFirst(4))

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

    func buildCompletion(from input: String, suggestion: String, currentDirectory: String) -> String {
        guard input.hasPrefix("/cd ") else { return input }
        let path = String(input.dropFirst(4))

        let expandedPath = expandPath(path, relativeTo: currentDirectory)
        let (directory, _) = splitPath(expandedPath)
        let completed = (directory as NSString).appendingPathComponent(suggestion)
        let normalized = (completed as NSString).standardizingPath

        return "/cd \(normalized)/"
    }

    // MARK: - Helper Methods

    private func expandPath(_ path: String, relativeTo currentDir: String) -> String {
        if path.hasPrefix("~/") {
            return (path as NSString).expandingTildeInPath
        } else if path.hasPrefix("/") {
            return path
        } else {
            return (currentDir as NSString).appendingPathComponent(path)
        }
    }

    private func splitPath(_ path: String) -> (directory: String, prefix: String) {
        if path.hasSuffix("/") || path.isEmpty {
            return (path.isEmpty ? "/" : path, "")
        } else {
            let directory = (path as NSString).deletingLastPathComponent
            let prefix = (path as NSString).lastPathComponent
            return (directory.isEmpty ? "/" : directory, prefix)
        }
    }
}
