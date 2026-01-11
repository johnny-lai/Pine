//
//  Item.swift
//  Pine
//
//  Created by Bing-Chang Lai on 12/31/25.
//

import Foundation
import SwiftData
import FoundationModels

@Model
final class Session {
    var id: UUID
    var title: String?
    var workingDirectory: String?
    var createdAt: Date
    var updatedAt: Date
    
    // Store transcript as JSON in external storage for efficiency
    @Attribute(.externalStorage)
    var transcriptData: Data?

    init(workingDirectory: String? = nil, title: String? = nil) {
        self.id = UUID()
        self.title = title
        self.workingDirectory = workingDirectory
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // Computed property for seamless transcript access
    var transcript: Transcript {
        get {
            guard let data = transcriptData else { return Transcript() }
            
            do {
                return try JSONDecoder().decode(Transcript.self, from: data)
            } catch {
                print("Transcript decode error: \(error)")
                return Transcript()
            }
        }
        set {
            do {
                transcriptData = try JSONEncoder().encode(newValue)
                updatedAt = Date()
            } catch {
                print("Transcript encode error: \(error)")
            }
        }
    }

    // Computed property for display title with fallback
    var displayTitle: String {
        title ?? "Session \(createdAt.formatted(date: .numeric, time: .shortened))"
    }

    func initialLanguageModelSession() -> LanguageModelSession {
        let config = Configuration.load()

        // Use session's working directory with fallback chain
        var workingDir = self.workingDirectory
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
        if self.transcript.isEmpty {
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
                transcript: self.transcript
            )
        }

        return initialSession
    }
}
