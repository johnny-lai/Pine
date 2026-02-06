//
//  ResponseView.swift
//  Pine
//
//  Created by Bing-Chang Lai on 1/1/26.
//

import FoundationModels
import MarkdownUI
import SwiftUI

struct ResponseView: View {
    let response: Transcript.Response
    @State private var showsMarkdown = true

    init(_ response: Transcript.Response) {
        self.response = response
    }

    var body: some View {
        MessageBubble(
            alignment: .leading,
            backgroundColor: ChatColors.assistantBubble,
            textColor: ChatColors.assistantText,
            icon: "cpu",
            label: "Assistant"
        ) {
            if showsMarkdown {
                Markdown(String(describing: response))
                    .font(ChatTypography.messageFont)
            } else {
                Text(String(describing: response))
                    .font(ChatTypography.messageFont)
                    .lineSpacing(ChatTypography.messageLineSpacing)
            }
        } accessory: {
            Button(showsMarkdown ? "Show Raw" : "Show Markdown") {
                showsMarkdown.toggle()
            }
            .buttonStyle(.borderless)
            .font(ChatTypography.labelFont)
            .foregroundColor(ChatTypography.labelText)
        }
    }
}
