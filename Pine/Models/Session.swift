//
//  Item.swift
//  Pine
//
//  Created by Bing-Chang Lai on 12/31/25.
//

import Foundation
import SwiftData

@Model
final class Session {
    var timestamp: Date
    var workingDirectory: String?
    var transcriptData: Data?
    var title: String?

    init(timestamp: Date, workingDirectory: String? = nil, title: String? = nil) {
        self.timestamp = timestamp
        self.workingDirectory = workingDirectory
        self.title = title
    }

    // Computed property for display title with fallback
    var displayTitle: String {
        title ?? "Session \(timestamp.formatted(date: .numeric, time: .shortened))"
    }
}
