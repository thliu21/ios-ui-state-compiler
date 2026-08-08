/// Structured failures in the deterministic fixture launch contract.
public enum FixtureLaunchError: Error, Equatable, Sendable {
  case missingScreenValue
  case unknownScreen(String)
  case duplicateScreenArgument
  case missingAppearanceValue
  case unknownAppearance(String)
  case duplicateAppearanceArgument
}

/// Explicit visual styles used by reproducible fixture captures.
public enum FixtureAppearance: String, CaseIterable, Codable, Sendable {
  case light
  case dark
}

/// Parses process arguments without reading global process state.
public struct FixtureLaunchConfiguration: Equatable, Sendable {
  public static let screenArgument = "--fixture-screen"
  public static let appearanceArgument = "--fixture-appearance"

  public let screen: FixtureScreen
  public let appearance: FixtureAppearance

  public init(arguments: [String]) throws {
    guard
      let screenValue = try Self.value(
        for: Self.screenArgument,
        in: arguments,
        missingValueError: .missingScreenValue,
        duplicateError: .duplicateScreenArgument
      )
    else {
      screen = .home
      appearance = try Self.parseAppearance(arguments: arguments)
      return
    }
    guard let requestedScreen = FixtureScreen(rawValue: screenValue) else {
      throw FixtureLaunchError.unknownScreen(screenValue)
    }

    screen = requestedScreen
    appearance = try Self.parseAppearance(arguments: arguments)
  }

  private static func parseAppearance(arguments: [String]) throws -> FixtureAppearance {
    guard
      let appearanceValue = try value(
        for: appearanceArgument,
        in: arguments,
        missingValueError: .missingAppearanceValue,
        duplicateError: .duplicateAppearanceArgument
      )
    else {
      return .light
    }
    guard let appearance = FixtureAppearance(rawValue: appearanceValue) else {
      throw FixtureLaunchError.unknownAppearance(appearanceValue)
    }
    return appearance
  }

  private static func value(
    for argument: String,
    in arguments: [String],
    missingValueError: FixtureLaunchError,
    duplicateError: FixtureLaunchError
  ) throws -> String? {
    let indices = arguments.indices.filter { arguments[$0] == argument }
    guard indices.count <= 1 else {
      throw duplicateError
    }
    guard let argumentIndex = indices.first else {
      return nil
    }

    let valueIndex = arguments.index(after: argumentIndex)
    guard valueIndex < arguments.endIndex else {
      throw missingValueError
    }
    return arguments[valueIndex]
  }
}
