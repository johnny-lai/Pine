//
//  ToolCallsView.swift
//  Pine
//
//  Created by Bing-Chang Lai on 12/31/25.
//

import FoundationModels
import SwiftUI

struct ToolCallsView: View {
    let toolCalls: Transcript.ToolCalls
    @State private var isExpanded = false

    init(_ toolCalls: Transcript.ToolCalls) {
        self.toolCalls = toolCalls
    }

    var body: some View {
        // Check if this is a directory change tool call
        if isChangeDirectoryTool {
            directoryChangeView
        } else {
            genericToolCallView
        }
    }

    private var isChangeDirectoryTool: Bool {
        // Check if any tool call has toolName "ChangeDirectory"
        return toolCalls.contains { $0.toolName == "ChangeDirectory" }
    }

    private var directoryPath: String? {
        // Find the ChangeDirectory tool call and extract the path from arguments
        guard let changeDirectoryCall = toolCalls.first(where: { $0.toolName == "ChangeDirectory" }) else {
            return nil
        }

        // Try to extract the path from the GeneratedContent arguments
        do {
            let path: String = try changeDirectoryCall.arguments.value(forProperty: "path")
            return path
        } catch {
            // If we can't extract the path, return nil
            return nil
        }
    }

    private var directoryChangeView: some View {
        MessageBubble(
            alignment: .leading,
            backgroundColor: ChatColors.toolBubble,
            textColor: ChatColors.toolText,
            icon: "folder.fill",
            label: nil
        ) {
            HStack(spacing: 8) {
                Image(systemName: "folder.fill")
                    .foregroundColor(ChatColors.toolAccent)
                if let path = directoryPath {
                    Text("Changed directory to: \(path)")
                        .font(ChatTypography.labelFont)
                        .foregroundColor(ChatColors.toolText)
                } else {
                    Text("Changed directory")
                        .font(ChatTypography.labelFont)
                        .foregroundColor(ChatColors.toolText)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var genericToolCallView: some View {
        MessageBubble(
            alignment: .leading,
            backgroundColor: ChatColors.toolBubble,
            textColor: ChatColors.toolText,
            icon: "wrench.and.screwdriver.fill",
            label: nil
        ) {
            VStack(alignment: .leading, spacing: 8) {
                Button(action: { isExpanded.toggle() }) {
                    HStack {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .foregroundColor(ChatColors.toolAccent)
                        Text("Tool Call")
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
                    Text(String(describing: toolCalls))
                        .font(ChatTypography.toolFont)
                        .foregroundColor(ChatColors.toolText)
                        .textSelection(.enabled)
                }
            }
        }
    }
}
