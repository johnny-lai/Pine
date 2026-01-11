//
//  SessionService.swift
//  Pine
//
//  Created by Claude on 1/11/26.
//

import Foundation
import SwiftData

/// Protocol for session service to enable dependency injection and testing
protocol SessionServiceProtocol {
    /// Create a new session
    func createSession(workingDirectory: String?, title: String?) throws

    /// Delete an existing session
    func deleteSession(_ session: Session) throws

    /// Fetch all sessions sorted by creation date
    func fetchSessions() -> [Session]
}

/// Service that handles session CRUD operations
@Observable
class SessionService: SessionServiceProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createSession(workingDirectory: String?, title: String?) throws {
        let session = Session(workingDirectory: workingDirectory, title: title)
        modelContext.insert(session)
        try modelContext.save()
    }

    func deleteSession(_ session: Session) throws {
        modelContext.delete(session)
        try modelContext.save()
    }

    func fetchSessions() -> [Session] {
        let descriptor = FetchDescriptor<Session>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
