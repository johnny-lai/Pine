//
//  ChatViewModel.swift
//  Pine
//
//  Created by Claude on 1/11/26.
//

import Foundation
import FoundationModels
import SwiftData

/// ViewModel for managing chat state and message sending
@Observable
class ChatViewModel {
    // Dependencies (injected)
    private let languageModelService: LanguageModelServiceProtocol
    private let configService: ConfigurationServiceProtocol
    private let toolFactory: ToolFactoryProtocol
    private let sessionService: SessionServiceProtocol

    // Model
    var session: Session

    // State
    var languageModelSession: LanguageModelSession
    var inputText: String = ""
    var isLoading: Bool = false

    init(
        session: Session,
        languageModelService: LanguageModelServiceProtocol,
        configService: ConfigurationServiceProtocol,
        toolFactory: ToolFactoryProtocol,
        sessionService: SessionServiceProtocol
    ) {
        self.session = session
        self.languageModelService = languageModelService
        self.configService = configService
        self.toolFactory = toolFactory
        self.sessionService = sessionService

        // Setup language model session
        let config = configService.loadConfiguration()

        // Derive working directory from transcript with fallback chain
        let workingDir = Self.getCurrentWorkingDirectory(from: session, config: config)

        let tools = toolFactory.createTools(
            enabledTools: config.enabledTools,
            workingDirectory: workingDir
        )

        let systemPrompt = configService.loadSystemPrompt()

        self.languageModelSession = languageModelService.createSession(
            for: session,
            tools: tools,
            systemPrompt: systemPrompt
        )
    }

    func sendMessage() async {
        guard !inputText.isEmpty else { return }

        // Check for slash commands
        if await handleSlashCommand(inputText) {
            inputText = ""
            return
        }

        let message = inputText
        inputText = ""
        isLoading = true

        defer { isLoading = false }

        do {
            self.languageModelSession = try await languageModelService.sendMessage(
                message,
                session: languageModelSession
            )

            try languageModelService.saveTranscript(
                languageModelSession.transcript,
                to: session
            )
        } catch {
            print("Failed to send message: \(error)")
        }
    }

    // MARK: - Directory Change Support

    /// Get current working directory from session's transcript
    private static func getCurrentWorkingDirectory(from session: Session, config: Configuration) -> String {
        // First try to get from transcript
        if let workingDir = session.currentWorkingDirectory {
            // Validate directory exists
            if FileManager.default.fileExists(atPath: workingDir) {
                return workingDir
            }
        }

        // Fallback chain
        let fallbackDir = config.workingDirectory ?? FileManager.default.currentDirectoryPath

        // Validate fallback directory exists
        if FileManager.default.fileExists(atPath: fallbackDir) {
            return fallbackDir
        }

        return FileManager.default.currentDirectoryPath
    }

    /// Handle slash commands (e.g., /cd)
    private func handleSlashCommand(_ input: String) async -> Bool {
        guard input.hasPrefix("/cd") else { return false }

        // Extract path from command
        let path = String(input.dropFirst(3)).trimmingCharacters(in: .whitespaces)

        if path.isEmpty {
            // TODO: Could open a directory picker here
            await appendDirectoryChangeToTranscript(path: "", success: false, error: "No path provided. Usage: /cd <path>")
            return true
        }

        await changeDirectory(to: path)
        return true
    }

    /// Change the working directory and record in transcript
    func changeDirectory(to path: String) async {
        // Expand tilde and resolve relative paths
        var finalPath = (path as NSString).expandingTildeInPath

        // If relative path, resolve against current working directory
        if !finalPath.hasPrefix("/") {
            let currentDir = Self.getCurrentWorkingDirectory(from: session, config: configService.loadConfiguration())
            finalPath = (currentDir as NSString).appendingPathComponent(finalPath)
        }

        // Resolve symlinks and standardize path
        finalPath = (finalPath as NSString).standardizingPath

        // Validate directory exists and is actually a directory
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: finalPath, isDirectory: &isDirectory) {
            await appendDirectoryChangeToTranscript(path: finalPath, success: false, error: "Directory does not exist: \(finalPath)")
            return
        }

        if !isDirectory.boolValue {
            await appendDirectoryChangeToTranscript(path: finalPath, success: false, error: "Path is not a directory: \(finalPath)")
            return
        }

        // Success - append to transcript
        await appendDirectoryChangeToTranscript(path: finalPath, success: true, error: nil)

        // Recreate tools with new working directory
        await updateToolsWithCurrentDirectory()
    }

    /// Manually append ToolCall and ToolOutput entries for directory change
    private func appendDirectoryChangeToTranscript(path: String, success: Bool, error: String?) async {
        let toolCallId = UUID().uuidString

        // Create arguments as GeneratedContent with properties
        let argumentsContent = GeneratedContent(properties: ["path": path])

        let toolCall = Transcript.ToolCall(
            id: toolCallId,
            toolName: "ChangeDirectory",
            arguments: argumentsContent
        )

        let toolCalls = Transcript.ToolCalls([toolCall])

        // Create the corresponding ToolOutput
        let outputMessage: String
        if success {
            outputMessage = "Changed working directory to: \(path)"
        } else {
            outputMessage = error ?? "Failed to change directory"
        }

        // Create a text segment for the output
        let textSegment = Transcript.TextSegment(content: outputMessage)
        let segment = Transcript.Segment.text(textSegment)

        let toolOutput = Transcript.ToolOutput(
            id: UUID().uuidString,
            toolName: "ChangeDirectory",
            segments: [segment]
        )

        // Create new transcript with the directory change entries appended
        let currentEntries = Array(languageModelSession.transcript)
        let newEntries: [Transcript.Entry] = [
            .toolCalls(toolCalls),
            .toolOutput(toolOutput)
        ]
        let updatedTranscript = Transcript(entries: currentEntries + newEntries)

        // Get current tools and system prompt from the session
        let config = configService.loadConfiguration()
        let workingDir = Self.getCurrentWorkingDirectory(from: session, config: config)
        let tools = toolFactory.createTools(
            enabledTools: config.enabledTools,
            workingDirectory: workingDir
        )

        // Recreate the session with the updated transcript
        languageModelSession = LanguageModelSession(
            tools: tools,
            transcript: updatedTranscript
        )

        // Save the updated transcript to the session
        do {
            try languageModelService.saveTranscript(updatedTranscript, to: session)
        } catch {
            print("Failed to save transcript: \(error)")
        }
    }

    /// Update tools with the current working directory
    /// Note: This is now handled by recreating the session with updated transcript in appendDirectoryChangeToTranscript
    private func updateToolsWithCurrentDirectory() async {
        // Tools are updated when we recreate the LanguageModelSession
        // with the new transcript in appendDirectoryChangeToTranscript
    }
}
