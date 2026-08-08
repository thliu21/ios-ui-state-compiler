/// Structured failures in the deterministic fixture launch contract.
public enum FixtureLaunchError: Error, Equatable, Sendable {
  case missingScreenValue
  case unknownScreen(String)
  case duplicateScreenArgument
}

/// Parses process arguments without reading global process state.
public struct FixtureLaunchConfiguration: Equatable, Sendable {
  public static let screenArgument = "--fixture-screen"

  public let screen: FixtureScreen

  public init(arguments: [String]) throws {
    let screenArgumentIndices = arguments.indices.filter {
      arguments[$0] == Self.screenArgument
    }

    guard screenArgumentIndices.count <= 1 else {
      throw FixtureLaunchError.duplicateScreenArgument
    }
    guard let argumentIndex = screenArgumentIndices.first else {
      screen = .home
      return
    }

    let valueIndex = arguments.index(after: argumentIndex)
    guard valueIndex < arguments.endIndex else {
      throw FixtureLaunchError.missingScreenValue
    }
    guard let requestedScreen = FixtureScreen(rawValue: arguments[valueIndex]) else {
      throw FixtureLaunchError.unknownScreen(arguments[valueIndex])
    }

    screen = requestedScreen
  }
}
