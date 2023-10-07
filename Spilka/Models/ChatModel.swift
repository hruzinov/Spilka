//
//  Created by Evhen Gruzinov on 05.10.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Chat: Identifiable, Codable {
    @DocumentID var id: String?
    var user: UserAccount?
    var messagesDictionary: [String: Message] = [:]
    var messagesSorted: [Message] {
        if messagesDictionary.count >= 2 {
            return messagesDictionary.values.sorted {
                $0.dateTime < $1.dateTime
            }
        } else {
            return Array(messagesDictionary.values)
        }
    }

    var unreadedCount: Int {
        self.messagesSorted.filter { $0.isUnread && $0.fromID == id }.count
    }

    private enum CodingKeys: String, CodingKey {
        case id
    }
}
