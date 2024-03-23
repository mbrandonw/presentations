import CasePathsMacros
import MacroTesting
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class CasePathableMacroTests_TrySwift: XCTestCase {
  override func invokeTest() {
    withMacroTesting(
      //isRecording: true,
      macros: [CasePathableMacro.self]
    ) {
      super.invokeTest()
    }
  }

  func testBasics_AssertMacro() {
    let x =   1
    assertMacro(record: true) {
      """
      @CasePathable
      enum Event {
        case load(user: User)
        case load(userID: User.ID)
      }
      """
    } diagnostics: {
      """
      @CasePathable
      enum Event {
        case load(user: User)
        case load(userID: User.ID)
             ┬───
             ╰─ 🛑 '@CasePathable' cannot be applied to overloaded case name 'load'
      }
      """
    } 
  }

  func testBasics_AssertMacroExpansion() {
    assertMacroExpansion(
      """
      @CasePathable
      enum Event {
        case load(user: User)
        case load(userID: User.ID)
      }
      """,
      expandedSource: """
      enum Event {
        case load(user: User)
        case load(userID: User.ID)
      }

      extension Event: CasePaths.CasePathable {
      }
      """,
      diagnostics: [DiagnosticSpec(message: "'@CasePathable' cannot be applied to overloaded case name 'load'", line: 4, column: 8)],
      macros: ["CasePathable": CasePathableMacro.self]
    )
  }
}
