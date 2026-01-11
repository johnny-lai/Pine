# Pine - Architecture & Roadmap

## Current State

Pine is a macOS Swift app that provides a chat interface for interacting with language models. As of January 2026, the app has been refactored to use **clean MVVM architecture** with proper separation of concerns.

### Architecture Overview

Pine follows a layered MVVM architecture with dependency injection:

```
Pine/
├── Models/          # Domain models (SwiftData entities)
├── ViewModels/      # Presentation logic & UI state
├── Services/        # Business logic & data operations
├── Views/           # UI components (no business logic)
├── Tools/           # Tool implementations (e.g., BashShell)
├── Configuration.swift
└── PineApp.swift   # App entry point + dependency injection
```

### Technologies

- **SwiftUI** + **SwiftData** for UI and persistence
- **FoundationModels** for LLM integration
- **@Observable** for reactive state management
- **Environment-based DI** for service injection

### Architecture Principles

- **Models**: SwiftData entities
- **Views**: Pure UI, no business logic
- **ViewModels**: State management and presentation logic
- **Services**: Business logic, data operations, external integrations

All services use protocol-based design for testability and flexibility.

---

## Future: LLM Provider Flexibility

**Status**: Architecture ready, implementation pending

**Goal**: Support multiple LLM providers (FoundationModels, Ollama, OpenAI, etc.)

### Implementation Plan

The current `LanguageModelServiceProtocol` supports provider swapping:
- `Transcript` type serves as universal message format
- Only `PineApp.swift` needs changes to switch providers
- No changes required in Views or ViewModels

### How to Add Ollama

```swift
// 1. Create OllamaService implementing LanguageModelServiceProtocol
class OllamaService: LanguageModelServiceProtocol {
    private let ollamaClient: OllamaClient
    private let modelContext: ModelContext

    func createSession(for session: Session, tools: [any Tool], systemPrompt: String?) -> LanguageModelSession {
        // Create Ollama session wrapper
        // Restore from session.transcript if not empty
    }

    func sendMessage(_ message: String, session: LanguageModelSession) async throws -> LanguageModelSession {
        // Call Ollama API
        // Convert response to Transcript format
    }

    func saveTranscript(_ transcript: Transcript, to session: Session) throws {
        session.transcript = transcript
        try modelContext.save()
    }
}

// 2. Switch provider in PineApp.swift
.environment(\.languageModelService, OllamaService(
    modelContext: sharedModelContainer.mainContext,
    ollamaClient: OllamaClient(baseURL: "http://localhost:11434")
))
```
