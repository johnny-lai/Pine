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
        Text("User: \(String(describing: prompt))")
            .foregroundColor(.blue)
    }
}
