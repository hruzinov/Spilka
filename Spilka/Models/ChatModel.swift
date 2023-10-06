//
//  Created by Evhen Gruzinov on 05.10.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Chat: Identifiable, Codable {
    @DocumentID var id: String?
    let type: ChatType
    var user: UserAccount?
    var messages: [Message] = []

    private enum CodingKeys: String, CodingKey {
        case id, type
    }
}

enum ChatType: String, Codable {
    case dialog, group
}
