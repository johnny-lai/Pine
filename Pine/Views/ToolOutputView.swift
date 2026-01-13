//
//  ToolOutputView.swift
//  Pine
//
//  Created by Bing-Chang Lai on 12/31/25.
//

import FoundationModels
import SwiftUI

struct ToolOutputView: View {
    let toolOutput: Transcript.ToolOutput
    @State private var isExpanded = false

    init(_ toolOutput: Transcript.ToolOutput) {
        self.toolOutput = toolOutput
    }

    var body: some View {
        // Check if this is a directory change output
        if isDirectoryChangeOutput {
            directoryChangeOutputView
        } else {
            genericToolOutputView
        }
    }

    private var isDirectoryChangeOutput: Bool {
        // Check if this is a ChangeDirectory tool output
        return toolOutput.toolName == "ChangeDirectory"
    }

    private var outputContent: String {
        // Extract text from segments
        toolOutput.segments.compactMap { segment in
            if case .text(let textSegment) = segment {
                return textSegment.content
            }
            return nil
        }.joined(separator: "\n")
    }

    private var isSuccess: Bool {
        outputContent.hasPrefix("Changed working directory")
    }

    private var directoryChangeOutputView: some View {
        MessageBubble(
            alignment: .leading,
            backgroundColor: ChatColors.toolBubble,
            textColor: ChatColors.toolText,
            icon: isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill",
            label: nil
        ) {
            HStack(spacing: 8) {
                Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(isSuccess ? .green : .orange)
                Text(outputContent)
                    .font(ChatTypography.labelFont)
                    .foregroundColor(ChatColors.toolText)
            }
            .padding(.vertical, 4)
        }
    }

    private var genericToolOutputView: some View {
        MessageBubble(
            alignment: .leading,
            backgroundColor: ChatColors.toolBubble,
            textColor: ChatColors.toolText,
            icon: "terminal.fill",
            label: nil
        ) {
            VStack(alignment: .leading, spacing: 8) {
                Button(action: { isExpanded.toggle() }) {
                    HStack {
                        Image(systemName: "terminal.fill")
                            .foregroundColor(ChatColors.toolAccent)
                        Text("Tool Output")
                            .font(ChatTypography.labelFont)
                            .foregroundColor(ChatColors.toolText)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundColor(ChatColors.toolAccent)
                    }
                }
                .buttonStyle(.plain)

                if isExpanded {
                    Text(String(describing: toolOutput))
                        .font(ChatTypography.toolFont)
                        .foregroundColor(ChatColors.toolText)
                        .textSelection(.enabled)
                }
            }
        }
    }
}
