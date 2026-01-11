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
                TextField("Type your message...", text: $viewModel.inputText)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.isLoading)
                    .onSubmit {
                        Task { await viewModel.sendMessage() }
                    }

                Button("Send") {
                    Task { await viewModel.sendMessage() }
                }
                .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
            }
            .padding()
        }
//        .workingDirectoryTitlebar(session: session)
//        .onChange(of: session.workingDirectory) { oldValue, newValue in
//            updateWorkingDirectory()
//        }
    }

    private func updateWorkingDirectory() {
        // TODO:
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Session.self, inMemory: true)
}
