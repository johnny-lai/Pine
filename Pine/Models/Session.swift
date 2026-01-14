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

    // Store session events as JSON in external storage
    @Attribute(.externalStorage)
    var eventsData: Data?

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

    // Computed property for session events
    var events: [SessionEvent] {
        get {
            guard let data = eventsData else { return [] }
            return (try? JSONDecoder().decode([SessionEvent].self, from: data)) ?? []
        }
        set {
            eventsData = try? JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }

    // Computed property - walks events backwards to find current directory
    var workingDirectory: String? {
        for event in events.reversed() {
            if case .directoryChange(_, let to) = event.type {
                return to
            }
        }
        return nil  // No directory change in events
    }
}
