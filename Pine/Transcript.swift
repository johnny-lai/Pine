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
        // Try to use NSKeyedArchiver for serialization
        return try NSKeyedArchiver.archivedData(withRootObject: self as NSArray, requiringSecureCoding: false)
    }

    static func deserialize(from data: Data) throws -> [FoundationModels.Transcript.Entry] {
        guard let entries = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [FoundationModels.Transcript.Entry] else {
            throw NSError(domain: "TranscriptDeserialization", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to deserialize transcript entries"])
        }
        return entries
    }
}
