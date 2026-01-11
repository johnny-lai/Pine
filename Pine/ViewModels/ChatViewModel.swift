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
        toolFactory: ToolFactoryProtocol
    ) {
        self.session = session
        self.languageModelService = languageModelService
        self.configService = configService
        self.toolFactory = toolFactory

        // Setup language model session
        let config = configService.loadConfiguration()

        // Use session's working directory with fallback chain
        var workingDir = session.workingDirectory
            ?? config.workingDirectory
            ?? FileManager.default.currentDirectoryPath

        // Validate directory exists
        if !FileManager.default.fileExists(atPath: workingDir) {
            workingDir = FileManager.default.currentDirectoryPath
        }

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
}
