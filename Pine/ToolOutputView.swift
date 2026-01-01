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

    init(_ toolOutput: Transcript.ToolOutput) {
        self.toolOutput = toolOutput
    }

    var body: some View {
        Text("Tool Output: \(String(describing: toolOutput))")
            .foregroundColor(.cyan)
    }
}
