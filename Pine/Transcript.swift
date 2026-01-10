//
//  Transcript.swift
//  Pine
//
//  Created by Bing-Chang Lai on 1/1/26.
//

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


//public struct Session {
//    init (configuration: Configuration) {
//
//    }
//
//    public var languageModelSession: LanguageModelSession {
//        // read agents.md instructions, etc?
//        // or get from Configuration?
//        // load from disk
//        fatalError("Not implemented")
//    }
//
//    public var workingDirectory: String // <-- is part of a agent's state?
//
//    public var transcript: Transcript {
//        fatalError("Not implemented")
//    }
//}
