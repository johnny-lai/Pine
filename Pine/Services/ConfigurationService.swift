//
//  ConfigurationService.swift
//  Pine
//
//  Created by Claude on 1/11/26.
//

import Foundation

/// Protocol for configuration service to enable dependency injection and testing
protocol ConfigurationServiceProtocol {
    /// Load configuration from file or return default
    func loadConfiguration() -> Configuration

    /// Load system prompt from file if it exists
    func loadSystemPrompt() -> String?
}

/// Service that wraps Configuration loading for testability
class ConfigurationService: ConfigurationServiceProtocol {
    func loadConfiguration() -> Configuration {
        Configuration.load()
    }

    func loadSystemPrompt() -> String? {
        Configuration.loadSystemPrompt()
    }
}
