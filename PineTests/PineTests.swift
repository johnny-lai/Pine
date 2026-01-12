//
//  PineTests.swift
//  PineTests
//
//  Created by Bing-Chang Lai on 12/31/25.
//

import Testing
import Foundation
import SwiftData
import FoundationModels
@testable import Pine

// MARK: - Session Model Tests

@Suite("Session Model Tests")
struct SessionModelTests {
    @Test("Session initialization with default values")
    func testSessionInitialization() {
        let session = Session()

        #expect(session.title == nil)
        #expect(session.workingDirectory == nil)
        #expect(session.id != UUID())  // Should have a valid UUID
        #expect(session.createdAt != Date.distantPast)
    }

    @Test("Session initialization with custom values")
    func testSessionWithCustomValues() {
        let session = Session(workingDirectory: "/test/path", title: "Test Session")

        #expect(session.title == "Test Session")
        #expect(session.workingDirectory == "/test/path")
    }

    @Test("Session displayTitle returns title when set")
    func testDisplayTitleWithTitle() {
        let session = Session(title: "My Custom Title")
        #expect(session.displayTitle == "My Custom Title")
    }

    @Test("Session displayTitle returns formatted date when title is nil")
    func testDisplayTitleWithoutTitle() {
        let session = Session()
        #expect(session.displayTitle.starts(with: "Session"))
    }

    @Test("Session transcript data is initially nil")
    func testTranscriptDataInitiallyNil() {
        let session = Session()
        #expect(session.transcriptData == nil)
    }

    @Test("Session updates updatedAt when transcript is set")
    func testTranscriptUpdatesTimestamp() throws {
        let session = Session()
        let initialUpdatedAt = session.updatedAt

        // Wait a tiny bit to ensure timestamp changes
        Thread.sleep(forTimeInterval: 0.01)

        // Set a new transcript
        session.transcript = Transcript()

        // Verify updatedAt changed
        #expect(session.updatedAt > initialUpdatedAt)
    }
}

// MARK: - SessionService Tests

@Suite("SessionService Tests")
struct SessionServiceTests {
    @Test("Create session successfully")
    func testCreateSession() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Session.self, configurations: config)
        let context = ModelContext(container)

        let service = SessionService(modelContext: context)

        try service.createSession(workingDirectory: "/test", title: "Test")

        let sessions = service.fetchSessions()
        #expect(sessions.count == 1)
        #expect(sessions.first?.title == "Test")
        #expect(sessions.first?.workingDirectory == "/test")
    }

    @Test("Create multiple sessions")
    func testCreateMultipleSessions() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Session.self, configurations: config)
        let context = ModelContext(container)

        let service = SessionService(modelContext: context)

        try service.createSession(workingDirectory: "/test1", title: "Session 1")
        try service.createSession(workingDirectory: "/test2", title: "Session 2")
        try service.createSession(workingDirectory: "/test3", title: "Session 3")

        let sessions = service.fetchSessions()
        #expect(sessions.count == 3)
    }

    @Test("Delete session successfully")
    func testDeleteSession() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Session.self, configurations: config)
        let context = ModelContext(container)

        let service = SessionService(modelContext: context)

        try service.createSession(workingDirectory: "/test", title: "Test")
        var sessions = service.fetchSessions()
        #expect(sessions.count == 1)

        let sessionToDelete = sessions[0]
        try service.deleteSession(sessionToDelete)

        sessions = service.fetchSessions()
        #expect(sessions.count == 0)
    }

    @Test("Fetch sessions returns sorted by creation date")
    func testFetchSessionsSorted() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Session.self, configurations: config)
        let context = ModelContext(container)

        let service = SessionService(modelContext: context)

        // Create sessions with slight delay to ensure different timestamps
        try service.createSession(workingDirectory: "/first", title: "First")
        try await Task.sleep(nanoseconds: 1_000_000)  // 1ms delay
        try service.createSession(workingDirectory: "/second", title: "Second")

        let sessions = service.fetchSessions()
        #expect(sessions.count == 2)
        // Should be sorted in reverse order (newest first)
        #expect(sessions[0].title == "Second")
        #expect(sessions[1].title == "First")
    }
}

// MARK: - ToolFactory Tests

@Suite("ToolFactory Tests")
struct ToolFactoryTests {
    @Test("Create BashShell tool when enabled")
    func testCreateBashShellTool() {
        let factory = ToolFactory()

        let tools = factory.createTools(
            enabledTools: ["bashShell"],
            workingDirectory: "/test"
        )

        #expect(tools.count == 1)
        #expect(tools.first is BashShell)
    }

    @Test("Create no tools when empty list")
    func testCreateNoTools() {
        let factory = ToolFactory()

        let tools = factory.createTools(
            enabledTools: [],
            workingDirectory: "/test"
        )

        #expect(tools.isEmpty)
    }

    @Test("Ignore unknown tool names")
    func testIgnoreUnknownTools() {
        let factory = ToolFactory()

        let tools = factory.createTools(
            enabledTools: ["unknownTool", "anotherUnknown"],
            workingDirectory: "/test"
        )

        #expect(tools.isEmpty)
    }

    @Test("Create multiple tools when multiple enabled")
    func testCreateMultipleTools() {
        let factory = ToolFactory()

        let tools = factory.createTools(
            enabledTools: ["bashShell", "bashShell"],  // Multiple of same tool
            workingDirectory: "/test"
        )

        #expect(tools.count == 2)
    }
}

// MARK: - Configuration Tests

@Suite("Configuration Tests")
struct ConfigurationTests {
    @Test("Default configuration has expected values")
    func testDefaultConfiguration() {
        let config = Configuration.default

        #expect(!config.enabledTools.isEmpty)
        #expect(config.enabledTools.contains("bashShell"))
        #expect(config.workingDirectory != nil)
    }

    @Test("Configuration model parameters can be created")
    func testConfigurationModelParameters() {
        let params = Configuration.ModelParameters(
            temperature: 0.7,
            maxTokens: 1024
        )

        #expect(params.temperature == 0.7)
        #expect(params.maxTokens == 1024)
    }

    @Test("Configuration can be created with custom values")
    func testConfigurationCreation() {
        let config = Configuration(
            workingDirectory: "/test",
            enabledTools: ["bashShell"],
            modelParameters: Configuration.ModelParameters(
                temperature: 0.5,
                maxTokens: 2048
            )
        )

        #expect(config.workingDirectory == "/test")
        #expect(config.enabledTools == ["bashShell"])
        #expect(config.modelParameters?.temperature == 0.5)
        #expect(config.modelParameters?.maxTokens == 2048)
    }
}
