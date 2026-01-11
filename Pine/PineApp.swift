//
//  PineApp.swift
//  Pine
//
//  Created by Bing-Chang Lai on 12/31/25.
//

import SwiftUI
import SwiftData

// MARK: - Environment Keys for Dependency Injection

private struct SessionServiceKey: EnvironmentKey {
    static let defaultValue: SessionServiceProtocol? = nil
}

private struct ConfigurationServiceKey: EnvironmentKey {
    static let defaultValue: ConfigurationServiceProtocol = ConfigurationService()
}

private struct LanguageModelServiceKey: EnvironmentKey {
    static let defaultValue: LanguageModelServiceProtocol? = nil
}

private struct ToolFactoryKey: EnvironmentKey {
    static let defaultValue: ToolFactoryProtocol = ToolFactory()
}

extension EnvironmentValues {
    var sessionService: SessionServiceProtocol? {
        get { self[SessionServiceKey.self] }
        set { self[SessionServiceKey.self] = newValue }
    }

    var configurationService: ConfigurationServiceProtocol {
        get { self[ConfigurationServiceKey.self] }
        set { self[ConfigurationServiceKey.self] = newValue }
    }

    var languageModelService: LanguageModelServiceProtocol? {
        get { self[LanguageModelServiceKey.self] }
        set { self[LanguageModelServiceKey.self] = newValue }
    }

    var toolFactory: ToolFactoryProtocol {
        get { self[ToolFactoryKey.self] }
        set { self[ToolFactoryKey.self] = newValue }
    }
}

// MARK: - App

@main
struct PineApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Session.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.sessionService, SessionService(
                    modelContext: sharedModelContainer.mainContext
                ))
                .environment(\.languageModelService, LanguageModelService(
                    modelContext: sharedModelContainer.mainContext
                ))
                .environment(\.configurationService, ConfigurationService())
                .environment(\.toolFactory, ToolFactory())
        }
        .modelContainer(sharedModelContainer)
    }
}
