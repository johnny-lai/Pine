//
//  SessionEventView.swift
//  Pine
//
//  Created by Claude on 1/13/26.
//

import SwiftUI

struct SessionEventView: View {
    let event: SessionEvent

    var body: some View {
        switch event.type {
        case .directoryChange(let from, let to):
            DirectoryChangeView(from: from, to: to)
        }
    }
}

struct DirectoryChangeView: View {
    let from: String?
    let to: String

    var body: some View {
        MessageBubble(
            alignment: .leading,
            backgroundColor: ChatColors.toolBubble,
            textColor: ChatColors.toolText,
            icon: "folder.fill",
            label: nil
        ) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Changed directory to: \(to)")
                    .font(ChatTypography.labelFont)
                    .foregroundColor(ChatColors.toolText)
            }
            .padding(.vertical, 4)
        }
    }
}
