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
