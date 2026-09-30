import XCTest
@testable import Macnotix

final class StalkerhekAdapterTests: XCTestCase {
    func testStalkerhekAdapterInitialization() {
        let provider = Provider(
            name: "My Local Stalkerhek",
            type: .stalkerhek,
            url: "http://localhost:4600"
        )
        
        let adapter = StalkerhekAdapter(provider: provider)
        XCTAssertEqual(adapter.provider.url, "http://localhost:4600")
        XCTAssertEqual(adapter.provider.type, .stalkerhek)
    }
}
