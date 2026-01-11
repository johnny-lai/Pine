//
//  Transcript.swift
//  Pine
//
//  Created by Bing-Chang Lai on 1/1/26.
//

import Foundation
import FoundationModels

public struct Transcript {
    public enum Entry {
        case foundation(FoundationModels.Transcript.Entry)
        case process(Process)
    }

    public struct Process {
        let pid: Int
        let stdout: String
        let stderr: String
    }

    typealias Instructions = FoundationModels.Transcript.Instructions
    typealias Prompt = FoundationModels.Transcript.Prompt
    typealias Response = FoundationModels.Transcript.Response
    typealias ToolCalls = FoundationModels.Transcript.ToolCalls
    typealias ToolOutput = FoundationModels.Transcript.ToolOutput

    let entries: [Entry]
}


// MARK: - Transcript Serialization

struct SerializableTranscriptEntry: Codable {
    let id: String
    let type: EntryType
    let content: String

    enum EntryType: String, Codable {
        case instructions
        case prompt
        case response
        case toolCalls
        case toolOutput
    }
}

extension Array where Element == FoundationModels.Transcript.Entry {
    func serialize() throws -> Data {
        let serializableEntries = self.compactMap { entry -> SerializableTranscriptEntry? in
            switch entry {
            case .instructions(let instructions):
                return SerializableTranscriptEntry(
                    id: String(describing: entry.id),
                    type: .instructions,
                    content: String(describing: instructions)
                )
            case .prompt(let prompt):
                return SerializableTranscriptEntry(
                    id: String(describing: entry.id),
                    type: .prompt,
                    content: String(describing: prompt)
                )
            case .response(let response):
                return SerializableTranscriptEntry(
                    id: String(describing: entry.id),
                    type: .response,
                    content: String(describing: response)
                )
            case .toolCalls(let toolCalls):
                return SerializableTranscriptEntry(
                    id: String(describing: entry.id),
                    type: .toolCalls,
                    content: String(describing: toolCalls)
                )
            case .toolOutput(let toolOutput):
                return SerializableTranscriptEntry(
                    id: String(describing: entry.id),
                    type: .toolOutput,
                    content: String(describing: toolOutput)
                )
            @unknown default:
                return nil
            }
        }

        let encoder = JSONEncoder()
        return try encoder.encode(serializableEntries)
    }
}
