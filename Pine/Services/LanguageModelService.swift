//
//  LanguageModelService.swift
//  Pine
//
//  Created by Claude on 1/11/26.
//

import Foundation
import FoundationModels
import SwiftData

/// Protocol for language model service to enable dependency injection and testing
/// Supports swapping LLM providers (FoundationModels, Ollama, etc.)
protocol LanguageModelServiceProtocol {
    /// Create a language model session for the given session
    func createSession(
        for session: Session,
        tools: [any Tool],
        systemPrompt: String?
    ) -> LanguageModelSession

    /// Send a message and get updated session
    func sendMessage(
        _ message: String,
        session: LanguageModelSession
    ) async throws -> LanguageModelSession

    /// Save transcript to session
    func saveTranscript(
        _ transcript: Transcript,
        to session: Session
    ) throws
}

/// Service that manages LanguageModelSession lifecycle and transcript persistence
@Observable
class LanguageModelService: LanguageModelServiceProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createSession(
        for session: Session,
        tools: [any Tool],
        systemPrompt: String?
    ) -> LanguageModelSession {
        let transcript = session.transcript

        if transcript.isEmpty {
            // Create new session with no transcript
            return LanguageModelSession(
                tools: tools,
                instructions: systemPrompt
            )
        } else {
            // Create session with restored transcript
            return LanguageModelSession(
                tools: tools,
                transcript: transcript
            )
        }
    }

    func sendMessage(
        _ message: String,
        session: LanguageModelSession
    ) async throws -> LanguageModelSession {
        _ = try await session.respond(to: message)
        return session
    }

    func saveTranscript(
        _ transcript: Transcript,
        to session: Session
    ) throws {
        session.transcript = transcript
        session.updatedAt = Date()
        try modelContext.save()
    }
}
