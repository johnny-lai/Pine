//
//  Configuration.swift
//  Pine
//
//  Created by Bing-Chang Lai on 1/1/26.
//

import Foundation
import TOMLKit

struct Configuration: Codable {
    var workingDirectory: String?
    var enabledTools: [String]
    var modelParameters: ModelParameters?

    struct ModelParameters: Codable {
        var temperature: Double?
        var maxTokens: Int?

        enum CodingKeys: String, CodingKey {
            case temperature
            case maxTokens = "max_tokens"
        }
    }

    enum CodingKeys: String, CodingKey {
        case workingDirectory = "working_directory"
        case enabledTools = "enabled_tools"
        case modelParameters = "model_parameters"
    }

    static let `default` = Configuration(
        workingDirectory: FileManager.default.currentDirectoryPath,
        enabledTools: ["bashShell"]
    )

    static func load() -> Configuration {
        guard let configURL = configFileURL() else {
            return .default
        }

        guard let tomlString = try? String(contentsOf: configURL, encoding: .utf8),
              let table = try? TOMLTable(string: tomlString),
              let data = try? JSONEncoder().encode(table),
              let config = try? JSONDecoder().decode(Configuration.self, from: data) else {
            return .default
        }

        return config
    }

    static func loadSystemPrompt() -> String? {
        guard let promptURL = systemPromptFileURL() else {
            return nil
        }

        return try? String(contentsOf: promptURL, encoding: .utf8)
    }

    static func configFileURL() -> URL? {
        guard let homeDir = FileManager.default.homeDirectoryForCurrentUser as URL? else {
            return nil
        }
        return homeDir
            .appendingPathComponent(".config")
            .appendingPathComponent("pine")
            .appendingPathComponent("config.toml")
    }

    static func systemPromptFileURL() -> URL? {
        guard let homeDir = FileManager.default.homeDirectoryForCurrentUser as URL? else {
            return nil
        }
        return homeDir
            .appendingPathComponent(".config")
            .appendingPathComponent("pine")
            .appendingPathComponent("prompts")
            .appendingPathComponent("AGENT.md")
    }
}
