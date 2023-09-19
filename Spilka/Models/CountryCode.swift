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
        CountryCode.allCases.filter {$0.code == code}.first!
    }
}
