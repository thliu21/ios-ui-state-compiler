public enum CLICommand: Equatable, Sendable {
  case help
  case version
}

public enum CLIParser {
  public static func parse(arguments: [String]) -> CLICommand {
    arguments.contains("--version") ? .version : .help
  }
}

public enum CLIText {
  public static func render(command: CLICommand) -> String {
    switch command {
    case .help:
      """
      iOS UI State Compiler

      Usage:
        ui-compiler --help
        ui-compiler --version
        ui-compiler compile (--screenshot <png> | --tree <path>) --viewport-size <WxH> [options]

      Compile options:
        --screenshot <png>       Saved screenshot input
        --tree <path>            Optional native hierarchy input
        --tree-format <value>    xml (default) or xcuitest-json
        --image-size <WxH>       Required for tree-only input
        --viewport-size <WxH>    Logical viewport in points
        --captured-at <ISO-8601> Capture timestamp; defaults to now
        --tree-captured-at <ISO-8601> Optional native-tree timestamp
        --screen-id <id>         Stable screen identifier; defaults to screen
        --orientation <value>    Schema orientation; defaults to unknown
        --format <json|compact>  Representation written to stdout

      Timing JSON is written separately to stderr.
      """
    case .version:
      "ui-compiler 0.1.0-dev"
    }
  }
}
