//
//  MessageBubble.swift
//  Pine
//
//  Created by Bing-Chang Lai on 1/10/26.
//

import SwiftUI

struct MessageBubble<Content: View, Accessory: View>: View {
    let alignment: HorizontalAlignment
    let backgroundColor: Color
    let textColor: Color
    let icon: String?
    let label: String?
    @ViewBuilder let content: Content
    @ViewBuilder let accessory: Accessory

    init(
        alignment: HorizontalAlignment,
        backgroundColor: Color,
        textColor: Color,
        icon: String?,
        label: String?,
        @ViewBuilder content: () -> Content,
        @ViewBuilder accessory: () -> Accessory = { EmptyView() }
    ) {
        self.alignment = alignment
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.icon = icon
        self.label = label
        self.content = content()
        self.accessory = accessory()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if alignment == .trailing {
                Spacer(minLength: 60)
            }

            VStack(alignment: alignment == .leading ? .leading : .trailing, spacing: 4) {
                if let label = label {
                    HStack(spacing: 4) {
                        if let icon = icon, alignment == .leading {
                            Image(systemName: icon)
                                .font(ChatTypography.labelFont)
                        }
                        Text(label)
                            .font(ChatTypography.labelFont)
                            .foregroundColor(ChatTypography.labelText)
                        if let icon = icon, alignment == .trailing {
                            Image(systemName: icon)
                                .font(ChatTypography.labelFont)
                        }
                        Spacer(minLength: 8)
                        accessory
                    }
                }

                content
                    .textSelection(.enabled)
                    .padding(ChatLayout.bubblePadding)
                    .background(backgroundColor)
                    .foregroundColor(textColor)
                    .cornerRadius(ChatLayout.bubbleCornerRadius)
                    .shadow(
                        color: Color.black.opacity(ChatLayout.shadowOpacity),
                        radius: ChatLayout.shadowRadius,
                        y: 1
                    )
            }
            .frame(maxWidth: ChatLayout.maxBubbleWidth, alignment: alignment == .leading ? .leading : .trailing)

            if alignment == .leading {
                Spacer(minLength: 60)
            }
        }
    }
}
