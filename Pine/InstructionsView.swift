//
//  InstructionsView.swift
//  Pine
//
//  Created by Bing-Chang Lai on 12/31/25.
//

import FoundationModels
import SwiftUI

struct InstructionsView: View {
    let instructions: Transcript.Instructions

    init(_ instructions: Transcript.Instructions) {
        self.instructions = instructions
    }

    var body: some View {
        Text("System: \(String(describing: instructions))")
            .foregroundColor(.gray)
    }
}
