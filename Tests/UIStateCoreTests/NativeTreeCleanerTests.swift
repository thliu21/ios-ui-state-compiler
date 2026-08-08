import Testing

@testable import UIStateCore

@Suite("Native tree cleaner")
struct NativeTreeCleanerTests {
  @Test("Collapses equal-frame empty wrappers and exact unknown duplicate subtrees")
  func conservativeCleaning() throws {
    let full = try rect(x: 0, y: 0, width: 402, height: 874)
    let scrollbar = try rect(x: 369, y: 116, width: 30, height: 696)
    let thumb = try rect(x: 396, y: 320, width: 3, height: 489)
    let nodes = [
      NativeTreeNode(
        id: "root",
        role: .unknown,
        label: "Synthetic app",
        frame: full,
        childIDs: ["wrapper", "scroll-a", "scroll-b"]
      ),
      NativeTreeNode(
        id: "wrapper",
        role: .unknown,
        frame: full,
        enabled: true,
        selected: false,
        parentID: "root",
        childIDs: ["button"]
      ),
      NativeTreeNode(
        id: "button",
        role: .button,
        label: "Continue",
        nativeIdentifier: "fixture.continue",
        frame: full,
        enabled: true,
        selected: false,
        parentID: "wrapper"
      ),
      NativeTreeNode(
        id: "scroll-a",
        role: .unknown,
        label: "Vertical scroll bar, 1 page",
        value: "0%",
        frame: scrollbar,
        enabled: true,
        selected: false,
        parentID: "root",
        childIDs: ["thumb-a"]
      ),
      NativeTreeNode(
        id: "thumb-a",
        role: .unknown,
        frame: thumb,
        enabled: true,
        selected: false,
        parentID: "scroll-a"
      ),
      NativeTreeNode(
        id: "scroll-b",
        role: .unknown,
        label: "Vertical scroll bar, 1 page",
        value: "0%",
        frame: scrollbar,
        enabled: true,
        selected: false,
        parentID: "root",
        childIDs: ["thumb-b"]
      ),
      NativeTreeNode(
        id: "thumb-b",
        role: .unknown,
        frame: thumb,
        enabled: true,
        selected: false,
        parentID: "scroll-b"
      ),
    ]

    let result = NativeTreeCleaner().clean(nodes)
    let root = try #require(result.nodes.first { $0.id == "root" })
    let button = try #require(result.nodes.first { $0.id == "button" })

    #expect(result.nodes.map(\.id) == ["root", "button", "scroll-a", "thumb-a"])
    #expect(result.collapsedWrapperCount == 1)
    #expect(result.removedDuplicateSubtreeCount == 1)
    #expect(result.removedDuplicateNodeCount == 2)
    #expect(root.childIDs == ["button", "scroll-a"])
    #expect(button.parentID == "root")
  }

  @Test("Preserves wrappers with content, state, or distinct geometry")
  func meaningfulWrappersRemain() throws {
    let full = try rect(x: 0, y: 0, width: 402, height: 874)
    let inset = try rect(x: 16, y: 100, width: 370, height: 52)
    let nodes = [
      NativeTreeNode(
        id: "root",
        role: .unknown,
        label: "Synthetic app",
        frame: full,
        childIDs: ["labelled", "different-frame", "disabled"]
      ),
      NativeTreeNode(
        id: "labelled",
        role: .unknown,
        label: "Meaningful group",
        frame: full,
        parentID: "root",
        childIDs: ["labelled-child"]
      ),
      NativeTreeNode(
        id: "labelled-child",
        role: .staticText,
        label: "Label",
        frame: full,
        parentID: "labelled"
      ),
      NativeTreeNode(
        id: "different-frame",
        role: .unknown,
        frame: full,
        parentID: "root",
        childIDs: ["different-frame-child"]
      ),
      NativeTreeNode(
        id: "different-frame-child",
        role: .staticText,
        label: "Inset",
        frame: inset,
        parentID: "different-frame"
      ),
      NativeTreeNode(
        id: "disabled",
        role: .unknown,
        frame: full,
        enabled: false,
        parentID: "root",
        childIDs: ["disabled-child"]
      ),
      NativeTreeNode(
        id: "disabled-child",
        role: .staticText,
        label: "Disabled context",
        frame: full,
        parentID: "disabled"
      ),
    ]

    let result = NativeTreeCleaner().clean(nodes)

    #expect(result.nodes == nodes)
    #expect(result.collapsedWrapperCount == 0)
    #expect(result.removedDuplicateSubtreeCount == 0)
    #expect(result.removedDuplicateNodeCount == 0)
  }

  private func rect(
    x: Double,
    y: Double,
    width: Double,
    height: Double
  ) throws -> CoordinateRect<ScreenPointSpace> {
    try CoordinateRect(x: x, y: y, width: width, height: height)
  }
}
