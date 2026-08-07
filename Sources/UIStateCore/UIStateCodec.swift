import Foundation

public enum UIStateCodec {
  public static func decode(_ data: Data) throws -> UIState {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(UIState.self, from: data)
  }

  public static func encode(
    _ state: UIState,
    prettyPrinted: Bool = false
  ) throws -> Data {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601

    var formatting: JSONEncoder.OutputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    if prettyPrinted {
      formatting.insert(.prettyPrinted)
    }
    encoder.outputFormatting = formatting

    return try encoder.encode(state)
  }
}
