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
    @Bindable var viewModel: ChatViewModel
    @State private var transcriptCount = 0
    @State private var inputText = ""

    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: ChatLayout.bubbleSpacing) {
                    ForEach(self.viewModel.languageModelSession.transcript) { entry in
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
//        .workingDirectoryTitlebar(session: session)
//        .onChange(of: session.workingDirectory) { oldValue, newValue in
//            updateWorkingDirectory()
//        }
    }

    private func sendMessage() {
        let input = inputText
        inputText = ""

        Task { @MainActor in
            _ = await viewModel.sendMessage(input)
            transcriptCount += 1
        }
    }

    private func updateWorkingDirectory() {
        // TODO:
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Session.self, inMemory: true)
}
