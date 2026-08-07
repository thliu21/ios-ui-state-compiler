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
          ui-compiler compile (--screenshot <png> | --tree <xml>) --viewport-size <WxH> [options]

        Compile options:
          --screenshot <png>       Saved screenshot input
          --tree <xml>             Optional native hierarchy input
          --image-size <WxH>       Required for tree-only input
          --viewport-size <WxH>    Logical viewport in points
          --captured-at <ISO-8601> Capture timestamp; defaults to now
          --tree-captured-at <ISO-8601> Optional native-tree timestamp
          --screen-id <id>         Stable screen identifier; defaults to screen
          --orientation <value>    Schema orientation; defaults to unknown
          --format <json|compact>  Representation written to stdout

        Timing JSON is written separately to stderr.
        """)
  }

  @Test("Renders the development version")
  func rendersVersion() {
    #expect(CLIText.render(command: .version) == "ui-compiler 0.1.0-dev")
  }
}
