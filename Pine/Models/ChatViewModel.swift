//
//  ChatViewModel.swift
//  Pine
//
//  Created by Bing-Chang Lai on 1/10/26.
//

import Foundation
import FoundationModels
import SwiftData
internal import Combine

@Observable
class ChatViewModel {
    var session: Session
    var languageModelSession: LanguageModelSession
    private let modelContext: ModelContext
    
    init(session: Session, modelContext: ModelContext) {
        self.session = session
        self.modelContext = modelContext

        let config = Configuration.load()

        // Use session's working directory with fallback chain
        var workingDir = session.workingDirectory
            ?? config.workingDirectory
            ?? FileManager.default.currentDirectoryPath

        // Validate directory exists
        if !FileManager.default.fileExists(atPath: workingDir) {
            workingDir = FileManager.default.currentDirectoryPath
        }

        let tools: [any Tool] = config.enabledTools.compactMap { toolName in
            switch toolName {
            case "bashShell":
                return BashShell(workingDirectory: workingDir)
            default:
                return nil
            }
        }

        // Try to restore transcript from saved data
        var initialSession: LanguageModelSession
        let transcript = session.transcript
        if transcript.isEmpty {
            // Create new session with no transcript
            let systemPrompt = Configuration.loadSystemPrompt()

            initialSession = LanguageModelSession(
                tools: tools,
                instructions: systemPrompt
            )
        } else {
            // Create session with restored transcript
            initialSession = LanguageModelSession(
                tools: tools,
                transcript: transcript
            )
        }

        self.languageModelSession = initialSession
    }
    
    func sendMessage(_ prompt: String) async {
        do {
            _ = try await languageModelSession.respond(to: prompt)

            // Persist updated transcript
            session.transcript = languageModelSession.transcript

            // Save to SwiftData
            try modelContext.save()
        } catch {
            print("Failed to send message: \(error)")
        }
    }
}
