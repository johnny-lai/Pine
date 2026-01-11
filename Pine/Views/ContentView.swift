//
//  ContentView.swift
//  Pine
//
//  Created by Bing-Chang Lai on 12/31/25.
//

import FoundationModels
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.sessionService) private var sessionService
    @Environment(\.configurationService) private var configurationService
    @Environment(\.languageModelService) private var languageModelService
    @Environment(\.toolFactory) private var toolFactory

    @State private var viewModel: SessionListViewModel?
    @Query private var sessions: [Session]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(sessions) { session in
                    NavigationLink {
                        if let languageModelService {
                            ChatView(
                                viewModel: ChatViewModel(
                                    session: session,
                                    languageModelService: languageModelService,
                                    configService: configurationService,
                                    toolFactory: toolFactory
                                )
                            )
                        }
                    } label: {
                        Text(session.displayTitle)
                    }
                }
                .onDelete(perform: deleteSessions)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: createNewSession) {
                        Label("New Session", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an session")
        }
        .onAppear {
            if viewModel == nil, let sessionService {
                viewModel = SessionListViewModel(
                    sessionService: sessionService,
                    configService: configurationService
                )
            }
        }
    }

    private func createNewSession() {
        withAnimation {
            viewModel?.createNewSession()
        }
    }

    private func deleteSessions(offsets: IndexSet) {
        withAnimation {
            viewModel?.deleteSessions(at: offsets, from: sessions)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Session.self, inMemory: true)
}
