//
//  AutoCompleter.swift
//  Pine
//
//  Created by Claude on 1/12/26.
//

import Foundation

/// Handles auto-completion by coordinating completion strategies
@Observable
class AutoCompleter {
    // Completion strategies (ordered by priority)
    private var strategies: [CompletionStrategy] = [
        DirectoryCompletion(),
        CommandCompletion()
    ]

    /// Current completion state
    var currentSuggestions: [String] = []
    var lastCompletionInput: String = ""
    var tabPressCount: Int = 0

    /// Result of tab completion
    enum CompletionResult {
        case noMatches
        case singleMatch(String)
        case commonPrefix(String)
        case showDropdown([String])
    }

    /// Complete input on tab press
    func complete(_ input: String, currentDirectory: String) -> CompletionResult {
        // Find appropriate strategy for the input
        guard let strategy = findStrategy(for: input) else {
            return .noMatches
        }

        // If this is a new input, get fresh completions and reset tab count
        if input != lastCompletionInput {
            currentSuggestions = strategy.getCompletions(for: input, currentDirectory: currentDirectory)
            lastCompletionInput = input
            tabPressCount = 0
        }

        guard !currentSuggestions.isEmpty else { return .noMatches }

        // Increment tab press count
        tabPressCount += 1

        // If only one match, complete it immediately
        if currentSuggestions.count == 1 {
            let completed = strategy.buildCompletion(
                from: input,
                suggestion: currentSuggestions[0],
                currentDirectory: currentDirectory
            )
            return .singleMatch(completed)
        }

        // Multiple matches
        if tabPressCount == 1 {
            // First tab: complete to common prefix
            if let commonPrefix = findCommonPrefix(currentSuggestions) {
                let completed = strategy.buildCompletion(
                    from: input,
                    suggestion: commonPrefix,
                    currentDirectory: currentDirectory
                )
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

        return prefix.isEmpty ? nil : prefix
    }

    /// Find appropriate completion strategy for the input
    private func findStrategy(for input: String) -> CompletionStrategy? {
        return strategies.first { $0.canHandle(input) }
    }

    /// Get current strategy for the input (used by InputTextField)
    func currentStrategy(for input: String) -> CompletionStrategy? {
        return findStrategy(for: input)
    }

    /// Reset completion state (call when text changes not from Tab)
    func reset() {
        currentSuggestions = []
        lastCompletionInput = ""
        tabPressCount = 0
    }
}
