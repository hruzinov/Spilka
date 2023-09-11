//
//  Created by Evhen Gruzinov on 10.09.2023.
//

import Foundation

struct CountryCode: Identifiable, Hashable, Codable {
    let id, title, flag, code: String
    let dialCode, pattern: String
    let limit: Int

    enum CodingKeys: String, CodingKey {
        case id, flag, code
        case title = "name"
        case dialCode = "dial_code"
        case pattern, limit
    }

    static var allCases: [CountryCode] = Bundle.main.decode("CountryNumbers.json")
    static func get(_ code: String) -> CountryCode {
        return CountryCode.allCases.filter {$0.code == code}.first!
    }



//    static var allCases: [CountryCode] = [
//        CountryCode(id: 235, title: "USA", flag: "🇺🇸", code: "US", dialCode: "+1", pattern: "### ### ####", limit: 10),
//        CountryCode(id: 232, title: "Ukraine", flag: "🇺🇦", code: "UA", dialCode: "+380", pattern: "## ### ## ##", limit: 8),
//        CountryCode(id: 177, title: "Poland", flag: "🇵🇱", code: "PL", dialCode: "+48", pattern: "### ### ###", limit: 9)
//    ]
}

