//
//  ToolFactory.swift
//  Pine
//
//  Created by Claude on 1/11/26.
//

import Foundation
import FoundationModels

/// Protocol for tool factory to enable dependency injection and testing
protocol ToolFactoryProtocol {
    /// Create tools based on enabled tool names and working directory
    func createTools(enabledTools: [String], workingDirectory: String) -> [any Tool]
}

/// Factory for creating and configuring tools
class ToolFactory: ToolFactoryProtocol {
    func createTools(enabledTools: [String], workingDirectory: String) -> [any Tool] {
        enabledTools.compactMap { toolName in
            switch toolName {
            case "bashShell":
                return BashShell(workingDirectory: workingDirectory)
            default:
                return nil
            }
        }
    }
}
