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
      """
    case .version:
      "ui-compiler 0.1.0-dev"
    }
  }
}
