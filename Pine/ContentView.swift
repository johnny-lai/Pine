//
//  ContentView.swift
//  Pine
//
//  Created by Bing-Chang Lai on 12/31/25.
//

import FoundationModels
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var session: LanguageModelSession
    @State private var transcriptCount = 0
    @State private var inputText = ""

    init() {
        let config = Configuration.load()
        let systemPrompt = Configuration.loadSystemPrompt()

        let tools: [any Tool] = config.enabledTools.compactMap { toolName in
            switch toolName {
            case "bashShell":
                return BashShell(workingDirectory: config.workingDirectory ?? FileManager.default.currentDirectoryPath)
            default:
                return nil
            }
        }

        _session = State(initialValue: LanguageModelSession(
            tools: tools,
            instructions: systemPrompt
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(session.transcript) { entry in
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
            .padding()
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

    private func sendMessage() {
        let input = inputText
        inputText = ""

        Task { @MainActor in
            do {
                _ = try await session.respond(to: input)
                transcriptCount += 1
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
