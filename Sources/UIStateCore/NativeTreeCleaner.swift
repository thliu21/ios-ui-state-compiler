struct NativeTreeCleaningResult: Sendable {
  let nodes: [NativeTreeNode]
  let collapsedWrapperCount: Int
  let removedDuplicateSubtreeCount: Int
  let removedDuplicateNodeCount: Int
}

/// A deliberately narrow cleaner for normalized native-tree baselines.
///
/// It collapses only semantic-empty, single-child wrappers whose frame exactly
/// matches their child. It removes only exact duplicate sibling subtrees made
/// entirely of unknown-role, identifier-free nodes. Raw compiler output remains
/// the default baseline.
struct NativeTreeCleaner: Sendable {
  func clean(_ nodes: [NativeTreeNode]) -> NativeTreeCleaningResult {
    let order = nodes.map(\.id)
    var drafts = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, Draft($0)) })
    var collapsedWrapperCount = 0

    for id in order {
      guard
        let wrapper = drafts[id],
        isCollapsible(wrapper),
        let parentID = wrapper.parentID,
        let parent = drafts[parentID],
        let childID = wrapper.childIDs.first,
        let child = drafts[childID],
        let wrapperFrame = wrapper.frame,
        let childFrame = child.frame,
        wrapperFrame == childFrame,
        let childIndex = parent.childIDs.firstIndex(of: id)
      else {
        continue
      }

      parent.childIDs[childIndex] = childID
      child.parentID = parentID
      drafts.removeValue(forKey: id)
      collapsedWrapperCount += 1
    }

    var removedDuplicateSubtreeCount = 0
    var removedDuplicateNodeCount = 0

    for id in order.reversed() {
      guard let parent = drafts[id] else { continue }
      var firstChildBySignature: [TreeSignature: String] = [:]
      var retainedChildIDs: [String] = []

      for childID in parent.childIDs {
        guard let child = drafts[childID] else { continue }
        let signature = treeSignature(child, drafts: drafts)

        if isDuplicateCandidate(child, drafts: drafts),
          firstChildBySignature[signature] != nil
        {
          let duplicateIDs = subtreeIDs(child, drafts: drafts)
          for duplicateID in duplicateIDs {
            drafts.removeValue(forKey: duplicateID)
          }
          removedDuplicateSubtreeCount += 1
          removedDuplicateNodeCount += duplicateIDs.count
        } else {
          retainedChildIDs.append(childID)
          if isDuplicateCandidate(child, drafts: drafts) {
            firstChildBySignature[signature] = childID
          }
        }
      }

      parent.childIDs = retainedChildIDs
    }

    return NativeTreeCleaningResult(
      nodes: order.compactMap { drafts[$0]?.node },
      collapsedWrapperCount: collapsedWrapperCount,
      removedDuplicateSubtreeCount: removedDuplicateSubtreeCount,
      removedDuplicateNodeCount: removedDuplicateNodeCount
    )
  }

  private func isCollapsible(_ node: Draft) -> Bool {
    node.role == .unknown
      && node.label == nil
      && node.value == nil
      && node.nativeIdentifier == nil
      && node.visible != false
      && node.enabled != false
      && node.selected != true
      && node.childIDs.count == 1
  }

  private func isDuplicateCandidate(
    _ node: Draft,
    drafts: [String: Draft]
  ) -> Bool {
    guard node.role == .unknown, node.nativeIdentifier == nil else { return false }
    return node.childIDs.allSatisfy { childID in
      guard let child = drafts[childID] else { return false }
      return isDuplicateCandidate(child, drafts: drafts)
    }
  }

  private func subtreeIDs(_ node: Draft, drafts: [String: Draft]) -> [String] {
    [node.id]
      + node.childIDs.flatMap { childID in
        drafts[childID].map { subtreeIDs($0, drafts: drafts) } ?? []
      }
  }

  private func treeSignature(
    _ node: Draft,
    drafts: [String: Draft]
  ) -> TreeSignature {
    TreeSignature(
      role: node.role.rawValue,
      label: node.label,
      value: node.value,
      nativeIdentifier: node.nativeIdentifier,
      frame: node.frame.map(FrameSignature.init),
      visible: node.visible,
      enabled: node.enabled,
      selected: node.selected,
      children: node.childIDs.compactMap { childID in
        drafts[childID].map { treeSignature($0, drafts: drafts) }
      }
    )
  }
}

private final class Draft {
  let id: String
  let role: ElementRole
  let label: String?
  let value: String?
  let nativeIdentifier: String?
  let frame: CoordinateRect<ScreenPointSpace>?
  let visible: Bool?
  let enabled: Bool?
  let selected: Bool?
  var parentID: String?
  var childIDs: [String]

  init(_ node: NativeTreeNode) {
    id = node.id
    role = node.role
    label = node.label
    value = node.value
    nativeIdentifier = node.nativeIdentifier
    frame = node.frame
    visible = node.visible
    enabled = node.enabled
    selected = node.selected
    parentID = node.parentID
    childIDs = node.childIDs
  }

  var node: NativeTreeNode {
    NativeTreeNode(
      id: id,
      role: role,
      label: label,
      value: value,
      nativeIdentifier: nativeIdentifier,
      frame: frame,
      visible: visible,
      enabled: enabled,
      selected: selected,
      parentID: parentID,
      childIDs: childIDs
    )
  }
}

private struct FrameSignature: Hashable {
  let x: Double
  let y: Double
  let width: Double
  let height: Double

  init(_ frame: CoordinateRect<ScreenPointSpace>) {
    x = frame.x
    y = frame.y
    width = frame.width
    height = frame.height
  }
}

private struct TreeSignature: Hashable {
  let role: String
  let label: String?
  let value: String?
  let nativeIdentifier: String?
  let frame: FrameSignature?
  let visible: Bool?
  let enabled: Bool?
  let selected: Bool?
  let children: [TreeSignature]
}
