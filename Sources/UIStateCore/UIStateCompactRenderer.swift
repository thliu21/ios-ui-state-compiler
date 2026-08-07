import Foundation

public enum UIStateCompactRenderer {
  public static func render(_ state: UIState) -> String {
    var lines = ["ui_state|schema=\(state.schemaVersion)"]
    lines.append(renderScreen(state.screen))
    lines.append(contentsOf: state.elements.map(renderElement))
    lines.append("relations|count=\(state.relations.count)")
    lines.append("changes|count=\(state.changes.count)")
    return lines.joined(separator: "\n")
  }

  private static func renderScreen(_ screen: UIStateScreen) -> String {
    [
      "screen",
      "id=\(escaped(screen.id))",
      "captured_at=\(iso8601(screen.capturedAt))",
      "image_pixels=\(number(screen.imageSizePixels.width))x\(number(screen.imageSizePixels.height))",
      "viewport_points=\(number(screen.viewportSizePoints.width))x\(number(screen.viewportSizePoints.height))",
      "orientation=\(screen.orientation.rawValue)",
      "sources=\(screen.sources.map(\.rawValue).joined(separator: ","))",
    ].joined(separator: "|")
  }

  private static func renderElement(_ element: UIStateElement) -> String {
    [
      "element",
      "id=\(escaped(element.id))",
      "role=\(element.role.rawValue)",
      "label=\(quoted(element.label))",
      "value=\(quoted(element.value))",
      "frame=\(renderFrame(element.frames.first))",
      "visible=\(triState(element.visible))",
      "enabled=\(triState(element.enabled))",
      "selected=\(triState(element.selected))",
      "parent=\(element.parentID.map(escaped) ?? "null")",
      "children=\((element.childIDs ?? []).map(escaped).joined(separator: ","))",
      "actions=\(element.actions.map(renderAction).joined(separator: ","))",
    ].joined(separator: "|")
  }

  private static func renderAction(_ action: UIStateAction) -> String {
    guard let target = action.target else { return action.type.rawValue }
    return
      "\(action.type.rawValue)@\(target.coordinateSpace.rawValue):\(number(target.x)),\(number(target.y))"
  }

  private static func renderFrame(_ frame: UIStateRect?) -> String {
    guard let frame else { return "null" }
    return [
      frame.coordinateSpace.rawValue,
      number(frame.x),
      number(frame.y),
      number(frame.width),
      number(frame.height),
    ].joined(separator: ":")
  }

  private static func triState(_ value: Bool?) -> String {
    value.map(String.init) ?? "unknown"
  }

  private static func quoted(_ value: String?) -> String {
    guard let value else { return "null" }
    let data = try? JSONEncoder().encode(value)
    return data.map { String(decoding: $0, as: UTF8.self) } ?? "null"
  }

  private static func escaped(_ value: String) -> String {
    value
      .replacingOccurrences(of: "\\", with: "\\\\")
      .replacingOccurrences(of: "|", with: "\\|")
      .replacingOccurrences(of: ",", with: "\\,")
      .replacingOccurrences(of: "=", with: "\\=")
  }

  private static func number(_ value: Double) -> String {
    String(format: "%.15g", locale: Locale(identifier: "en_US_POSIX"), value)
  }

  private static func iso8601(_ date: Date) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter.string(from: date)
  }
}
