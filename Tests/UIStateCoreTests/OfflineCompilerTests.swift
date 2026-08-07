import Foundation
import Testing
import UIStateCore

@Suite("Offline compiler boundaries")
struct OfflineCompilerTests {
  @Test("Compilation requires at least one evidence input")
  func missingInputFails() {
    let request = OfflineCompileRequest(
      screenID: "missing-input",
      capturedAt: Date(timeIntervalSince1970: 0),
      viewportSizePoints: UIStateSize(width: 390, height: 844)
    )

    #expect(throws: OfflineCompilerError.missingInput) {
      try OfflineCompiler().compile(request)
    }
  }

  @Test("Invalid image bytes fail without producing a partial state")
  func invalidImageFails() {
    let request = OfflineCompileRequest(
      screenID: "invalid-image",
      capturedAt: Date(timeIntervalSince1970: 0),
      screenshotData: Data("not an image".utf8),
      viewportSizePoints: UIStateSize(width: 390, height: 844)
    )

    #expect(throws: OfflineCompilerError.invalidImageData) {
      try OfflineCompiler().compile(request)
    }
  }

  @Test("Screenshot byte limits fail before image decoding")
  func screenshotByteLimitFails() {
    let request = OfflineCompileRequest(
      screenID: "oversized-image",
      capturedAt: Date(timeIntervalSince1970: 0),
      screenshotData: Data([0, 1]),
      viewportSizePoints: UIStateSize(width: 390, height: 844)
    )
    let limits = OfflineCompilerLimits(maximumScreenshotBytes: 1, maximumImagePixelCount: 100)

    #expect(throws: OfflineCompilerError.screenshotTooLarge(limit: 1)) {
      try OfflineCompiler(limits: limits).compile(request)
    }
  }
}
