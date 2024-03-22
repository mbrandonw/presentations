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
    assertMacro {
      """
      @CasePathable
      enum Event {
        case load(user: User)
        case load(userID: Int)
      }
      """
    } diagnostics: {
      """
      @CasePathable
      enum Event {
        case load(user: User)
        case load(userID: Int)
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
      }
      """,
      expandedSource: """
      enum Event {
        case load(user: User)

          public struct AllCasePaths {
              public var load: CasePaths.AnyCasePath<Event, User> {
                  CasePaths.AnyCasePath<Event, User>(
                      embed: Event.load,
                      extract: {
                          guard case let .load(v0) = $0 else {
                              return nil
                          }
                          return v0
                      }
                  )
              }
          }
          public static var allCasePaths: AllCasePaths { AllCasePaths() }
      }

      extension Event: CasePaths.CasePathable {
      }
      """,
      macros: ["CasePathable": CasePathableMacro.self]
    )
  }

  func testOverloadedCaseName_AssertMacroExpansion() {
    assertMacroExpansion(
      """
      @CasePathable
      enum Event {
        case load(user: User)
        case load(id: User.ID)
      }
      """,
      expandedSource: """
      enum Event {
        case load(user: User)
        case load(id: User.ID)
      }

      extension Event: CasePaths.CasePathable {
      }
      """,
      diagnostics: [
        DiagnosticSpec(message: "'@CasePathable' cannot be applied to overloaded case name 'load'", line: 4, column: 8)
      ],
      macros: ["CasePathable": CasePathableMacro.self]
    )
  }
}
