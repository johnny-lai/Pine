//
//  BashShell.swift
//  Pine
//
//  Created by Bing-Chang Lai on 1/1/26.
//

import Foundation
import FoundationModels

struct BashShell: Tool {
  let name = "bashShell"
  let description = "Execute a bash command in a new shell"

  @Generable
  struct Arguments {
    @Guide(description: "The ID of the session. Start from 1. Start a new session by using a new ID.")
    var sessionId: Int

    @Guide(description: "Bash command to run. For example, `ls` or `pwd`")
    var command: String

    @Guide(description: "Arguments to the command")
    var arguments: [String]
  }

  @Generable
  struct ProcessOutput {
    var exitCode: Int
    var stderr: String
    var stdout: String
  }
  typealias Output = ProcessOutput

  func call(arguments: Arguments) async throws -> Self.Output {
    let process = Process()
    process.launchPath = "/bin/bash"

    var args: [String] = [ "-c", arguments.command ]
    args.append(contentsOf: arguments.arguments)
    process.arguments = args
    process.currentDirectoryURL = URL(filePath: "/Users/bing-changlai/Projects/Libra")

    let outputPipe = Pipe()
    let errorPipe = Pipe()

    process.standardOutput = outputPipe
    process.standardError = errorPipe

    process.launch()
    process.waitUntilExit()

    let stdoutData =
      (process.standardOutput as? Pipe)?.fileHandleForReading.readDataToEndOfFile() ?? Data()
    let stderrData =
      (process.standardError as? Pipe)?.fileHandleForReading.readDataToEndOfFile() ?? Data()
    let stdoutString = String(data: stdoutData, encoding: .utf8) ?? ""
    let stderrString = String(data: stderrData, encoding: .utf8) ?? ""

    let response = Self.Output(
      exitCode: Int(process.terminationStatus),
      stderr: stderrString,
      stdout: stdoutString
    )

    return response
  }
}
