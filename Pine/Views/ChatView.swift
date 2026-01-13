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
    @State private var isSelectingDirectory = false
    @State private var showDirectoryError = false
    @State private var directoryError: String?

    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: ChatLayout.bubbleSpacing) {
                    ForEach(viewModel.languageModelSession.transcript) { entry in
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
                    if viewModel.isLoading {
                        Text("Thinking")
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

                if viewModel.isLoading {
                    Button("Stop") {}
                } else {
                    Button("Send") {
                        Task { await viewModel.sendMessage() }
                    }
                    .disabled(viewModel.inputText.isEmpty)
                }
            }
            .padding()
        }
        .workingDirectoryTitlebar(session: viewModel.session)
        .onChange(of: viewModel.session.workingDirectory) { oldValue, newValue in
//            updateWorkingDirectory()
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
