//
//  SessionListViewModel.swift
//  Pine
//
//  Created by Claude on 1/11/26.
//

import Foundation
import SwiftData

/// ViewModel for managing session list state and operations
@Observable
class SessionListViewModel {
    private let sessionService: SessionServiceProtocol
    private let configService: ConfigurationServiceProtocol

    var sessions: [Session] = []
    var selectedSession: Session?

    init(
        sessionService: SessionServiceProtocol,
        configService: ConfigurationServiceProtocol
    ) {
        self.sessionService = sessionService
        self.configService = configService
        loadSessions()
    }

    func loadSessions() {
        sessions = sessionService.fetchSessions()
    }

    func createNewSession() {
        let config = configService.loadConfiguration()
        try? sessionService.createSession(
            workingDirectory: config.workingDirectory,
            title: nil
        )
        loadSessions()
    }

    func deleteSession(_ session: Session) {
        try? sessionService.deleteSession(session)
        loadSessions()
    }

    func deleteSessions(at offsets: IndexSet, from sessions: [Session]) {
        for index in offsets {
            try? sessionService.deleteSession(sessions[index])
        }
        loadSessions()
    }
}
