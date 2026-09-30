import Foundation

private final class XMLTVParserHelper: NSObject, XMLParserDelegate, @unchecked Sendable {
    var programs: [EPGProgram] = []
    private var currentElement = ""
    private var currentChannelId = ""
    private var currentStartTime: Date?
    private var currentEndTime: Date?
    private var currentTitle = ""
    private var currentDescription = ""
    
    private let xmltvDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyyMMddHHmmss Z"
        return df
    }()
    
    func parse(xmlData: Data) -> [EPGProgram] {
        programs.removeAll()
        let parser = XMLParser(data: xmlData)
        parser.delegate = self
        parser.parse()
        return programs
    }
    
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String] = [:]
    ) {
        currentElement = elementName
        if elementName == "programme" {
            currentChannelId = attributeDict["channel"] ?? ""
            if let startStr = attributeDict["start"] {
                currentStartTime = parseDate(startStr)
            }
            if let stopStr = attributeDict["stop"] {
                currentEndTime = parseDate(stopStr)
            }
            currentTitle = ""
            currentDescription = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "title" {
            currentTitle += string
        } else if currentElement == "desc" {
            currentDescription += string
        }
    }
    
    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        if elementName == "programme" {
            if let start = currentStartTime,
               let end = currentEndTime,
               !currentChannelId.isEmpty {
                let program = EPGProgram(
                    channelTvgId: currentChannelId,
                    title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                    showDescription: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                    startTime: start,
                    endTime: end
                )
                programs.append(program)
            }
        }
        currentElement = ""
    }
    
    private func parseDate(_ dateStr: String) -> Date? {
        if let direct = xmltvDateFormatter.date(from: dateStr) {
            return direct
        }
        let cleaned = dateStr.trimmingCharacters(in: .whitespaces)
        return xmltvDateFormatter.date(from: cleaned)
    }
}

public actor XMLTVParserActor {
    public static let shared = XMLTVParserActor()
    
    public init() {}
    
    public func parse(xmlData: Data) -> [EPGProgram] {
        let helper = XMLTVParserHelper()
        return helper.parse(xmlData: xmlData)
    }
}
