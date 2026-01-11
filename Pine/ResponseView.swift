//
//  ResponseView.swift
//  Pine
//
//  Created by Bing-Chang Lai on 1/1/26.
//

import FoundationModels
import SwiftUI

struct ResponseView: View {
    let response: Transcript.Response

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
            Text(String(describing: response))
                .font(ChatTypography.messageFont)
                .lineSpacing(ChatTypography.messageLineSpacing)
        }
    }
}
