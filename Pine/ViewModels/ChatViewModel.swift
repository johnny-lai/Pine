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
    private var currentTask: Task<Void, Never>?

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

    func submit() {
        currentTask = Task {
            await sendMessage()
        }
    }

    private func sendMessage() async {
        guard !inputText.isEmpty else { return }

        // Check for slash commands
        if await handleSlashCommand(inputText) {
            inputText = ""
            return
        }

        let message = inputText
        inputText = ""
        isLoading = true

        do {
            self.languageModelSession = try await languageModelService.sendMessage(
                message,
                session: languageModelSession
            )

            // Check if cancelled before saving
            guard !Task.isCancelled else { return }

            try languageModelService.saveTranscript(
                languageModelSession.transcript,
                to: session
            )
        } catch {
            print("Failed to send message: \(error)")
        }

        isLoading = false
    }

    func stop() {
        currentTask?.cancel()
        currentTask = nil
        isLoading = false
    }

    // MARK: - Directory Support

    /// Get current working directory for the session
    func getCurrentDirectory() -> String {
        Self.getCurrentWorkingDirectory(from: session, config: configService.loadConfiguration())
    }

    // MARK: - Directory Change Support

    /// Get current working directory from session's events
    private static func getCurrentWorkingDirectory(from session: Session, config: Configuration) -> String {
        // First try to get from session events
        if let workingDir = session.workingDirectory {
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
            // TODO: Could open a directory picker here or show error
            return true
        }

        await changeDirectory(to: path)
        return true
    }

    /// Change the working directory and record as session event
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
            // TODO: Could show error in UI
            print("Directory does not exist: \(finalPath)")
            return
        }

        if !isDirectory.boolValue {
            // TODO: Could show error in UI
            print("Path is not a directory: \(finalPath)")
            return
        }

        // Create event at current transcript position
        let position = languageModelSession.transcript.count
        let event = SessionEvent(
            type: .directoryChange(from: session.workingDirectory, to: finalPath),
            transcriptPosition: position
        )

        // Append event - workingDirectory is computed from events
        var events = session.events
        events.append(event)
        session.events = events

        // Recreate tools with new working directory
        await updateToolsWithCurrentDirectory()
    }

    /// Update tools with the current working directory
    private func updateToolsWithCurrentDirectory() async {
        let config = configService.loadConfiguration()
        let workingDir = Self.getCurrentWorkingDirectory(from: session, config: config)
        let tools = toolFactory.createTools(
            enabledTools: config.enabledTools,
            workingDirectory: workingDir
        )

        // Recreate language model session with updated tools
        languageModelSession = LanguageModelSession(
            tools: tools,
            transcript: languageModelSession.transcript
        )
    }
}
