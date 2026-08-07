import UIStateCore

@main
struct UICompilerCLI {
  static func main() {
    let arguments = Array(CommandLine.arguments.dropFirst())
    let command = CLIParser.parse(arguments: arguments)
    print(CLIText.render(command: command))
  }
}
