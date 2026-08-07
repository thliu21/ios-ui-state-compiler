import Testing

@testable import UIStateCore

@Suite("CLI parser")
struct CLIParserTests {
  @Test(
    "Recognizes help and version commands",
    arguments: [
      (arguments: [String](), expected: CLICommand.help),
      (arguments: ["--help"], expected: CLICommand.help),
      (arguments: ["--version"], expected: CLICommand.version),
    ])
  func recognizesCommand(example: (arguments: [String], expected: CLICommand)) {
    #expect(CLIParser.parse(arguments: example.arguments) == example.expected)
  }

  @Test("Renders command help")
  func rendersHelp() {
    #expect(
      CLIText.render(command: .help) == """
        iOS UI State Compiler

        Usage:
          ui-compiler --help
          ui-compiler --version
        """)
  }

  @Test("Renders the development version")
  func rendersVersion() {
    #expect(CLIText.render(command: .version) == "ui-compiler 0.1.0-dev")
  }
}
