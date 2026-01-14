//
//  ChatView.swift
//  Pine
//
//  Created by Bing-Chang Lai on 1/10/26.
//

import FoundationModels
import SwiftUI
import SwiftData

/// Wrapper for interleaved display of transcript entries and session events
enum DisplayEntry: Identifiable {
    case transcript(Transcript.Entry)
    case event(SessionEvent)

    var id: String {
        switch self {
        case .transcript(let entry): return "t-\(entry.id)"
        case .event(let event): return "e-\(event.id)"
        }
    }
}

struct ChatView: View {
    @Bindable var viewModel: ChatViewModel

    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
    }

    /// Interleave transcript entries and session events by position
    var interleavedEntries: [DisplayEntry] {
        var result: [DisplayEntry] = []
        var eventIndex = 0
        let events = viewModel.session.events
        let transcript = Array(viewModel.languageModelSession.transcript)

        for (i, entry) in transcript.enumerated() {
            // Insert events that belong at this position
            while eventIndex < events.count && events[eventIndex].transcriptPosition == i {
                result.append(.event(events[eventIndex]))
                eventIndex += 1
            }
            result.append(.transcript(entry))
        }

        // Append remaining events after transcript
        while eventIndex < events.count {
            result.append(.event(events[eventIndex]))
            eventIndex += 1
        }

        return result
    }

    private var scrollAnchorID: String { "scroll-anchor" }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: ChatLayout.bubbleSpacing) {
                        ForEach(interleavedEntries) { entry in
                            switch entry {
                            case .transcript(let transcriptEntry):
                                TranscriptEntryView(entry: transcriptEntry)
                            case .event(let sessionEvent):
                                SessionEventView(event: sessionEvent)
                            }
                        }
                        if viewModel.isLoading {
                            Text("Thinking")
                        }
                        Color.clear
                            .frame(height: 1)
                            .id(scrollAnchorID)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .onChange(of: interleavedEntries.count) {
                    withAnimation {
                        proxy.scrollTo(scrollAnchorID, anchor: .bottom)
                    }
                }
                .onChange(of: viewModel.isLoading) {
                    withAnimation {
                        proxy.scrollTo(scrollAnchorID, anchor: .bottom)
                    }
                }
                .onAppear {
                    proxy.scrollTo(scrollAnchorID, anchor: .bottom)
                }
            }
            Divider()

            HStack {
                InputTextField(
                    text: $viewModel.inputText,
                    isLoading: viewModel.isLoading,
                    getCurrentDirectory: { viewModel.getCurrentDirectory() },
                    onSubmit: { viewModel.submit() },
                    onStop: { viewModel.stop() }
                )
            }
            .padding()
        }
        .workingDirectoryTitlebar(session: viewModel.session)
    }
}

/// Helper view to render a single transcript entry
struct TranscriptEntryView: View {
    let entry: Transcript.Entry

    var body: some View {
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

#Preview {
    ContentView()
        .modelContainer(for: Session.self, inMemory: true)
}
