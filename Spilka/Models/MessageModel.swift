//
//  Created by Evhen Gruzinov on 05.10.2023.
//

import Foundation
import FirebaseFirestoreSwift

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    let from: String
    // swiftlint:disable:next identifier_name
    let to: String
    var text: String
    var isUnread: Bool
    let dateTime: Date
//        let attachments

    enum CodingKeys: String, CodingKey {
        // swiftlint:disable:next identifier_name
        case id, from, to, text
        case isUnread = "is_unread"
        case dateTime = "timestamp"
    }
}
