import XCTest
@testable import Macnotix

final class XtreamCodesAdapterTests: XCTestCase {
    func testXtreamCodesAdapterInitialization() {
        let provider = Provider(
            name: "Test Xtream",
            type: .xtream,
            url: "http://xtream.example.com:8080",
            username: "testuser",
            password: "testpassword"
        )
        
        let adapter = XtreamCodesAdapter(provider: provider)
        XCTAssertEqual(adapter.provider.username, "testuser")
        XCTAssertEqual(adapter.provider.password, "testpassword")
        XCTAssertEqual(adapter.provider.type, .xtream)
    }
}
