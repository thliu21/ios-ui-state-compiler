import Darwin
import Foundation
import UIStateCore

@main
struct UICompilerCLI {
  static func main() {
    let arguments = Array(CommandLine.arguments.dropFirst())

    guard arguments.first == "compile" else {
      let command = CLIParser.parse(arguments: arguments)
      print(CLIText.render(command: command))
      return
    }

    if arguments.contains("--help") {
      print(CLIText.render(command: .help))
      return
    }

    do {
      let options = try CompileOptions.parse(arguments: Array(arguments.dropFirst()))
      let screenshotData = try options.screenshotPath.map(readFile)
      let treeData = try options.treePath.map(readFile)
      let result = try OfflineCompiler().compile(
        OfflineCompileRequest(
          screenID: options.screenID,
          capturedAt: options.capturedAt,
          screenshotData: screenshotData,
          nativeTreeXML: options.treeFormat == .xml ? treeData : nil,
          xcuiTestSnapshotJSON: options.treeFormat == .xcuiTestJSON ? treeData : nil,
          imageSizePixels: options.imageSize,
          viewportSizePoints: try options.requiredViewportSize,
          orientation: options.orientation,
          treeCapturedAt: treeData == nil ? nil : options.treeCapturedAt ?? options.capturedAt
        ))

      let representation: Data
      switch options.format {
      case .json:
        representation = result.json
      case .compact:
        representation = Data(result.compactText.utf8)
      }

      write(representation, to: .standardOutput)
      write(Data("\n".utf8), to: .standardOutput)

      let timingEncoder = JSONEncoder()
      timingEncoder.outputFormatting = [.sortedKeys]
      write(try timingEncoder.encode(result.timings), to: .standardError)
      write(Data("\n".utf8), to: .standardError)
    } catch let error as CompileArgumentError {
      fail("invalid arguments: \(error.message)")
    } catch is CocoaError {
      fail("unable to read input file")
    } catch {
      fail("offline compilation failed")
    }
  }

  private static func readFile(_ path: String) throws -> Data {
    try Data(contentsOf: URL(fileURLWithPath: path), options: [.mappedIfSafe])
  }

  private static func write(_ data: Data, to handle: FileHandle) {
    handle.write(data)
  }

  private static func fail(_ message: String) -> Never {
    write(Data("error: \(message)\n".utf8), to: .standardError)
    Darwin.exit(2)
  }
}

private struct CompileOptions {
  enum OutputFormat: String {
    case json
    case compact
  }

  enum TreeFormat: String {
    case xml
    case xcuiTestJSON = "xcuitest-json"
  }

  var screenshotPath: String?
  var treePath: String?
  var imageSize: UIStateSize?
  var viewportSize: UIStateSize?
  var capturedAt = Date()
  var treeCapturedAt: Date?
  var screenID = "screen"
  var orientation = ScreenOrientation.unknown
  var format = OutputFormat.json
  var treeFormat = TreeFormat.xml

  var requiredViewportSize: UIStateSize {
    get throws {
      guard let viewportSize else {
        throw CompileArgumentError("viewport size is required")
      }
      return viewportSize
    }
  }

  static func parse(arguments: [String]) throws -> CompileOptions {
    var options = CompileOptions()
    var index = 0

    while index < arguments.count {
      let option = arguments[index]
      let value = try argumentValue(after: option, index: &index, arguments: arguments)

      switch option {
      case "--screenshot":
        options.screenshotPath = value
      case "--tree":
        options.treePath = value
      case "--tree-format":
        guard let format = TreeFormat(rawValue: value) else {
          throw CompileArgumentError("tree format must be xml or xcuitest-json")
        }
        options.treeFormat = format
      case "--image-size":
        options.imageSize = try parseSize(value)
      case "--viewport-size":
        options.viewportSize = try parseSize(value)
      case "--captured-at":
        options.capturedAt = try parseDate(value)
      case "--tree-captured-at":
        options.treeCapturedAt = try parseDate(value)
      case "--screen-id":
        guard !value.isEmpty else { throw CompileArgumentError("screen ID is empty") }
        options.screenID = value
      case "--orientation":
        guard let orientation = ScreenOrientation(rawValue: value) else {
          throw CompileArgumentError("unsupported orientation")
        }
        options.orientation = orientation
      case "--format":
        guard let format = OutputFormat(rawValue: value) else {
          throw CompileArgumentError("format must be json or compact")
        }
        options.format = format
      default:
        throw CompileArgumentError("unknown option")
      }

      index += 1
    }

    guard options.screenshotPath != nil || options.treePath != nil else {
      throw CompileArgumentError("provide a screenshot or tree")
    }
    guard options.viewportSize != nil else {
      throw CompileArgumentError("viewport size is required")
    }
    if options.screenshotPath == nil, options.imageSize == nil {
      throw CompileArgumentError("image size is required for tree-only input")
    }

    return options
  }

  private static func argumentValue(
    after option: String,
    index: inout Int,
    arguments: [String]
  ) throws -> String {
    let valueIndex = index + 1
    guard valueIndex < arguments.count, !arguments[valueIndex].hasPrefix("--") else {
      throw CompileArgumentError("missing value for \(option)")
    }
    index = valueIndex
    return arguments[valueIndex]
  }

  private static func parseSize(_ rawValue: String) throws -> UIStateSize {
    let parts = rawValue.lowercased().split(separator: "x", maxSplits: 1)
    guard
      parts.count == 2,
      let width = Double(parts[0]),
      let height = Double(parts[1]),
      width.isFinite,
      height.isFinite,
      width > 0,
      height > 0
    else {
      throw CompileArgumentError("size must be positive WxH")
    }
    return UIStateSize(width: width, height: height)
  }

  private static func parseDate(_ rawValue: String) throws -> Date {
    let formatter = ISO8601DateFormatter()
    if let date = formatter.date(from: rawValue) {
      return date
    }

    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    guard let date = formatter.date(from: rawValue) else {
      throw CompileArgumentError("timestamp must be ISO-8601")
    }
    return date
  }
}

private struct CompileArgumentError: Error {
  let message: String

  init(_ message: String) {
    self.message = message
  }
}
