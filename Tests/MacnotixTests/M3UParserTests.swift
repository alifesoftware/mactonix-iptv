import XCTest
@testable import Macnotix

final class M3UParserTests: XCTestCase {
    func testM3UParserWithLiveChannels() async {
        let m3uContent = """
        #EXTM3U
        #EXTINF:-1 tvg-id="BBC1.uk" tvg-name="BBC One HD" tvg-logo="https://example.com/bbc1.png" group-title="United Kingdom",BBC One HD
        http://localhost:4600/stream/bbc1.m3u8
        #EXTINF:-1 tvg-id="CNN.us" tvg-name="CNN International" tvg-logo="https://example.com/cnn.png" group-title="United States",CNN International
        http://localhost:4600/stream/cnn.m3u8
        """
        
        let provider = Provider(name: "Test Stalkerhek", type: .stalkerhek, url: "http://localhost:4600")
        let result = await M3UParserActor.shared.parse(content: m3uContent, provider: provider)
        
        XCTAssertEqual(result.channels.count, 2)
        XCTAssertEqual(result.channels[0].name, "BBC One HD")
        XCTAssertEqual(result.channels[0].tvgId, "BBC1.uk")
        XCTAssertEqual(result.channels[0].groupTitle, "United Kingdom")
        XCTAssertEqual(result.channels[0].streamURL.absoluteString, "http://localhost:4600/stream/bbc1.m3u8")
        
        XCTAssertEqual(result.channels[1].name, "CNN International")
        XCTAssertEqual(result.channels[1].groupTitle, "United States")
        
        XCTAssertEqual(result.groups.count, 2)
    }
    
    func testM3UParserWithSeriesAndEpisodes() async {
        let m3uContent = """
        #EXTM3U
        #EXTINF:-1 tvg-logo="https://example.com/breakingbad.png" group-title="SERIES",Breaking Bad S01 E01 Pilot
        http://example.com/bb_s01e01.mp4
        #EXTINF:-1 tvg-logo="https://example.com/breakingbad.png" group-title="SERIES",Breaking Bad S01 E02 Cat's in the Bag
        http://example.com/bb_s01e02.mp4
        """
        
        let provider = Provider(name: "Test M3U", type: .m3uURL, url: "http://example.com/playlist.m3u")
        let result = await M3UParserActor.shared.parse(content: m3uContent, provider: provider)
        
        XCTAssertEqual(result.series.count, 1)
        let serie = result.series[0]
        XCTAssertEqual(serie.name, "Breaking Bad")
        XCTAssertEqual(serie.seasons.count, 1)
        XCTAssertEqual(serie.seasons[0].episodes.count, 2)
    }
    
    func testM3UParserWithVODMovies() async {
        let m3uContent = """
        #EXTM3U
        #EXTINF:-1 tvg-logo="https://example.com/inception.png" group-title="VOD Movies",Inception (2010)
        http://example.com/inception.mp4
        """
        
        let provider = Provider(name: "Test VOD", type: .m3uURL, url: "http://example.com/vod.m3u")
        let result = await M3UParserActor.shared.parse(content: m3uContent, provider: provider)
        
        XCTAssertEqual(result.movies.count, 1)
        XCTAssertEqual(result.movies[0].name, "Inception (2010)")
    }
}
