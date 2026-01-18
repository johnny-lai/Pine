//
//  CompletionStrategy.swift
//  Pine
//
//  Created by Claude on 1/17/26.
//

import Foundation

/// Protocol for auto-completion strategies
protocol CompletionStrategy {
    /// Determine if this strategy should handle the given input
    /// - Parameter input: The current input text
    /// - Returns: True if this strategy can handle the input
    func canHandle(_ input: String) -> Bool

    /// Get completion suggestions for the given input
    /// - Parameters:
    ///   - input: The current input text
    ///   - currentDirectory: Current working directory (for context)
    /// - Returns: Array of completion suggestions
    func getCompletions(for input: String, currentDirectory: String) -> [String]

    /// Build the completed text from the original input and selected suggestion
    /// - Parameters:
    ///   - input: The original input text
    ///   - suggestion: The selected suggestion
    ///   - currentDirectory: Current working directory
    /// - Returns: The completed text to insert into the input field
    func buildCompletion(from input: String, suggestion: String, currentDirectory: String) -> String
}
