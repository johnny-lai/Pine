//
//  Item.swift
//  Pine
//
//  Created by Bing-Chang Lai on 12/31/25.
//

import Foundation
import SwiftData
import FoundationModels

@Model
final class Session {
    var id: UUID
    var title: String?
    var createdAt: Date
    var updatedAt: Date
    
    // Store transcript as JSON in external storage for efficiency
    @Attribute(.externalStorage)
    var transcriptData: Data?

    init(title: String? = nil) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // Computed property for seamless transcript access
    var transcript: Transcript {
        get {
            guard let data = transcriptData else { return Transcript() }
            
            do {
                return try JSONDecoder().decode(Transcript.self, from: data)
            } catch {
                print("Transcript decode error: \(error)")
                return Transcript()
            }
        }
        set {
            do {
                transcriptData = try JSONEncoder().encode(newValue)
                updatedAt = Date()
            } catch {
                print("Transcript encode error: \(error)")
            }
        }
    }

    // Computed property for display title with fallback
    var displayTitle: String {
        title ?? "Session \(createdAt.formatted(date: .numeric, time: .shortened))"
    }

    // Computed property to derive current working directory from transcript
    var currentWorkingDirectory: String? {
        // Scan transcript backwards to find most recent ChangeDirectory tool output
        for entry in transcript.reversed() {
            if case .toolOutput(let toolOutput) = entry {
                // Check if this is a ChangeDirectory tool output
                if toolOutput.toolName == "ChangeDirectory" {
                    // Extract the path from the segments
                    // The segment should contain text like "Changed working directory to: /path"
                    for segment in toolOutput.segments {
                        if case .text(let textSegment) = segment {
                            let text = textSegment.content
                            if text.hasPrefix("Changed working directory to: ") {
                                let path = text.dropFirst("Changed working directory to: ".count)
                                return String(path)
                            }
                        }
                    }
                }
            }
        }

        // No directory change found in transcript
        return nil
    }
}
