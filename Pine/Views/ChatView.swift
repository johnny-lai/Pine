//
//  ChatView.swift
//  Pine
//
//  Created by Bing-Chang Lai on 1/10/26.
//

import FoundationModels
import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var session: Session
    @State private var languageModelSession: LanguageModelSession
    @State private var transcriptCount = 0
    @State private var inputText = ""

    private var workingDirectory: String {
        let config = Configuration.load()
        var workingDir = session.workingDirectory
            ?? config.workingDirectory
            ?? FileManager.default.currentDirectoryPath

        if !FileManager.default.fileExists(atPath: workingDir) {
            workingDir = FileManager.default.currentDirectoryPath
        }

        return workingDir
    }

    init(session: Session) {
        self.session = session

        let initialSession = session.initialLanguageModelSession()
        _languageModelSession = State(initialValue: initialSession)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: ChatLayout.bubbleSpacing) {
                    ForEach(languageModelSession.transcript) { entry in
                        switch entry {
                        case let .instructions(instructions):
                            InstructionsView(instructions)
                        case let .prompt(prompt):
                            PromptView(prompt)
                        case let .toolCalls(toolCalls):
                            ToolCallsView(toolCalls)
                        case let .toolOutput(toolOutput):
                            ToolOutputView(toolOutput)
                        case let .response(response):
                            ResponseView(response)
                        @unknown default:
                            Text("Unknown entry type")
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            Divider()

            HStack {
                TextField("Type your message...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        sendMessage()
                    }

                Button("Send") {
                    sendMessage()
                }
            }
            .padding()
        }
        .workingDirectoryTitlebar(session: session)
        .onChange(of: session.workingDirectory) { oldValue, newValue in
            updateWorkingDirectory()
        }
        .onDisappear {
            saveTranscript()
        }
    }

    private func sendMessage() {
        let input = inputText
        inputText = ""

        Task { @MainActor in
            do {
                _ = try await languageModelSession.respond(to: input)
                transcriptCount += 1

                // Save transcript to Session after each interaction
                saveTranscript()
            } catch {
                print("Error: \(error)")
            }
        }
    }

    private func saveTranscript() {
        do {
            session.transcript = languageModelSession.transcript
            try modelContext.save()
        } catch {
            print("Warning: Failed to save transcript: \(error)")
        }
    }

    private func updateWorkingDirectory() {
        let config = Configuration.load()
        let systemPrompt = Configuration.loadSystemPrompt()

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

        // Create new session with updated tools
        languageModelSession = LanguageModelSession(
            tools: tools,
            instructions: systemPrompt
        )

        // Save the updated working directory
        try? modelContext.save()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Session.self, inMemory: true)
}
