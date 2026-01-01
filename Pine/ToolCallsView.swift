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

    init(_ toolCalls: Transcript.ToolCalls) {
        self.toolCalls = toolCalls
    }

    var body: some View {
        Text("Tool Calls: \(String(describing: toolCalls))")
            .foregroundColor(.yellow)
    }
}
