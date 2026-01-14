//
//  SessionEvent.swift
//  Pine
//
//  Created by Claude on 1/13/26.
//

import Foundation

/// Types of session events that can be displayed in the chat
enum SessionEventType: Codable, Equatable {
    case directoryChange(from: String?, to: String)
    // Future: case fileOpened(path: String)
    // Future: case error(message: String)
}

/// A session event that is displayed interleaved with transcript entries
struct SessionEvent: Codable, Identifiable, Equatable {
    let id: UUID
    let type: SessionEventType
    let transcriptPosition: Int  // Position in transcript when event occurred

    init(type: SessionEventType, transcriptPosition: Int) {
        self.id = UUID()
        self.type = type
        self.transcriptPosition = transcriptPosition
    }
}
