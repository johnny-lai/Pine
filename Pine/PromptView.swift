//
//  PromptView.swift
//  Pine
//
//  Created by Bing-Chang Lai on 1/1/26.
//


import FoundationModels
import SwiftUI

struct PromptView: View {
    let prompt: Transcript.Prompt

    init(_ prompt: Transcript.Prompt) {
        self.prompt = prompt
    }

    var body: some View {
        MessageBubble(
            alignment: .trailing,
            backgroundColor: ChatColors.userBubble,
            textColor: ChatColors.userText,
            icon: "person.fill",
            label: "You"
        ) {
            Text(String(describing: prompt))
                .font(ChatTypography.messageFont)
                .lineSpacing(ChatTypography.messageLineSpacing)
        }
    }
}
