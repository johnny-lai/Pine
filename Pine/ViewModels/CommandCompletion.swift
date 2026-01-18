//
//  CommandCompletion.swift
//  Pine
//
//  Created by Claude on 1/17/26.
//

import Foundation

/// Completion strategy for slash commands
class CommandCompletion: CompletionStrategy {
    // Available commands - easily extensible for future commands
    private let availableCommands = ["/cd"]

    func canHandle(_ input: String) -> Bool {
        // Handle when input starts with "/" but isn't yet a full command with space
        return input.hasPrefix("/") && !input.hasPrefix("/cd ")
    }

    func getCompletions(for input: String, currentDirectory: String) -> [String] {
        guard input.hasPrefix("/") else { return [] }

        // Extract command prefix (remove leading "/")
        let prefix = String(input.dropFirst()).lowercased()

        // Filter commands that match the prefix
        return availableCommands
            .filter { command in
                let commandName = String(command.dropFirst()) // Remove "/" from command
                return commandName.lowercased().hasPrefix(prefix)
            }
            .sorted()
    }

    func buildCompletion(from input: String, suggestion: String, currentDirectory: String) -> String {
        // Return the command with a trailing space for immediate input
        return "\(suggestion) "
    }
}
