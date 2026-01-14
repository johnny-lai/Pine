//
//  InputTextField.swift
//  Pine
//
//  Created by Claude on 1/12/26.
//

import SwiftUI

/// Text input field with tab completion for `/cd` command
struct InputTextField: View {
    @Binding var text: String
    var isLoading: Bool
    var getCurrentDirectory: () -> String
    var onSubmit: () -> Void
    var onStop: () -> Void

    @State private var directoryCompleter = DirectoryCompleter()
    @State private var showDropdown = false
    @State private var dropdownSuggestions: [String] = []
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack {
                TextField("Type your message...", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFocused)
                    .disabled(isLoading)
                    .onKeyPress(.tab) {
                        handleTabCompletion()
                        return .handled // Prevent default tab behavior
                    }
                    .onKeyPress(.escape) {
                        // Close dropdown on Escape
                        showDropdown = false
                        return .handled
                    }
                    .onChange(of: text) { oldValue, newValue in
                        // Hide dropdown and reset completion state if user manually edited text
                        if !newValue.hasPrefix("/cd ") || newValue != oldValue {
                            showDropdown = false
                            directoryCompleter.reset()
                        }
                    }
                    .onSubmit { handleSubmit() }
                if isLoading {
                    Button("Stop", action: onStop)
                } else {
                    Button(action: handleSubmit) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .disabled(text.isEmpty)
                }
            }

            // Dropdown suggestions
            if showDropdown && !dropdownSuggestions.isEmpty {
                directoryGrid(suggestions: dropdownSuggestions)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(6)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .scrollIndicators(.hidden)
                    .padding(.top, 28) // Position below text field
                    .zIndex(1000)
            }
        }
        .onAppear {
            isFocused = true
        }
    }

    func handleSubmit() {
        showDropdown = false
        onSubmit()
    }

    func columnsNeeded(rowCount: Int, maxColumnCount: Int) -> Int {
        (rowCount + maxColumnCount - 1) / maxColumnCount
    }

    func directoryGrid(suggestions: [String]) -> some View {
        let rowCount = 3
        return ScrollView(.horizontal) {
            LazyHGrid(
                rows: Array(
                    repeating: GridItem(.flexible()),
                    count: rowCount
                )
            ) {
                ForEach(suggestions, id: \.self) { suggestion in
                    directoryView(suggestion: suggestion)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .scrollIndicators(.visible)
    }

    func directoryView(suggestion: String) -> some View {
        return Button(action: {
            selectSuggestion(suggestion)
        }) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 12))
                Text(suggestion)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
        .background(Color.clear)
        .contentShape(Rectangle())
        .onHover { isHovered in
            // Could add hover effect here
        }
    }

    private func handleTabCompletion() {
        guard text.hasPrefix("/cd ") else { return }

        let currentDir = getCurrentDirectory()
        let result = directoryCompleter.complete(text, currentDirectory: currentDir)

        switch result {
        case .noMatches:
            showDropdown = false

        case .singleMatch(let completed):
            text = completed
            showDropdown = false

        case .commonPrefix(let completed):
            text = completed
            showDropdown = false

        case .showDropdown(let suggestions):
            dropdownSuggestions = suggestions
            showDropdown = true
        }
    }

    private func selectSuggestion(_ suggestion: String) {
        let currentDir = getCurrentDirectory()
        guard text.hasPrefix("/cd ") else { return }

        let path = String(text.dropFirst(4))

        // Build the completed path
        let expandedPath = directoryCompleter.expandPath(path, relativeTo: currentDir)
        let (directory, _) = directoryCompleter.splitPath(expandedPath)
        let completed = (directory as NSString).appendingPathComponent(suggestion)
        let normalized = (completed as NSString).standardizingPath

        text = "/cd \(normalized)/"
        showDropdown = false
        directoryCompleter.reset()
    }
}

// Extension to make DirectoryCompleter methods accessible
extension DirectoryCompleter {
    func expandPath(_ path: String, relativeTo currentDir: String) -> String {
        if path.hasPrefix("~/") {
            return (path as NSString).expandingTildeInPath
        } else if path.hasPrefix("/") {
            return path
        } else {
            return (currentDir as NSString).appendingPathComponent(path)
        }
    }

    func splitPath(_ path: String) -> (directory: String, prefix: String) {
        if path.hasSuffix("/") || path.isEmpty {
            return (path.isEmpty ? "/" : path, "")
        } else {
            let directory = (path as NSString).deletingLastPathComponent
            let prefix = (path as NSString).lastPathComponent
            return (directory.isEmpty ? "/" : directory, prefix)
        }
    }
}

#Preview {
    InputTextField(
        text: .constant(""),
        isLoading: false,
        getCurrentDirectory: { "~/" },
        onSubmit: { },
        onStop: { }
    )
}
