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
        Text("Assistant: \(String(describing: response))")
            .foregroundColor(.green)
    }
}
