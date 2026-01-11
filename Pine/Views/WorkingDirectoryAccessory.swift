//
//  WorkingDirectoryAccessory.swift
//  Pine
//
//  Created by Bing-Chang Lai on 1/10/26.
//

import AppKit
import SwiftData
import SwiftUI

// MARK: - SwiftUI View Modifier

struct WorkingDirectoryTitlebarModifier: ViewModifier {
    @Bindable var session: Session
    @State private var currentWindow: NSWindow?

    func body(content: Content) -> some View {
        content
            .background(WindowAccessor { window in
                currentWindow = window
                if let window = window {
                    updateWindowTitle(window: window)
                }
            })
            .onAppear {
                if let window = currentWindow {
                    updateWindowTitle(window: window)
                }
            }
            .onChange(of: session.workingDirectory) { _, _ in
                if let window = currentWindow {
                    updateWindowTitle(window: window)
                }
            }
            .onChange(of: session.title) { _, _ in
                if let window = currentWindow {
                    updateWindowTitle(window: window)
                }
            }
            .onChange(of: session.id) { _, _ in
                // Session changed - update immediately
                if let window = currentWindow {
                    updateWindowTitle(window: window)
                }
            }
    }

    private func updateWindowTitle(window: NSWindow) {
        window.title = session.displayTitle

        if let workingDir = session.workingDirectory {
            window.representedURL = URL(fileURLWithPath: workingDir)
        } else {
            window.representedURL = nil
        }

        window.titlebarAppearsTransparent = false
    }
}

// MARK: - Window Accessor

struct WindowAccessor: NSViewRepresentable {
    let callback: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.callback(view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            self.callback(nsView.window)
        }
    }
}

extension View {
    func workingDirectoryTitlebar(session: Session) -> some View {
        self.modifier(WorkingDirectoryTitlebarModifier(session: session))
    }
}
