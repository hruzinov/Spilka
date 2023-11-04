//
//  Created by Evhen Gruzinov on 05.10.2023.
//

import FirebaseFirestoreSwift
import Foundation

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    let fromID: String
    let toID: String
    var text: String
    var uncryptedText: String?
    var isUnread: Bool
    let dateTime: Date
//        let attachments

    enum CodingKeys: String, CodingKey {
        case id, text
        case fromID = "from_id"
        case toID = "to_id"
        case isUnread = "is_unread"
        case dateTime = "timestamp"
    }
}
