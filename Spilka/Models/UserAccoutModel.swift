//
//  Created by Evhen Gruzinov on 20.09.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

struct UserAccount: Codable {
    @DocumentID var uuid: String?
    var name: String
    var countryCode: String?
    var phoneNumber: String?
    var profileImageID: String?
    var profileImageSmall: UIImage?
//    var profileImageLarge: UIImage? = nil
    var username: String?
    var description: String?
    var publicKey: String

    enum CodingKeys: String, CodingKey {
        case uuid
        case name
        case countryCode
        case phoneNumber
        case profileImageID = "profile_image"
        case username
        case description
        case publicKey
    }

    func getProfileImageSmall(completion: @escaping(_ image: UIImage?) -> Void) {
        guard let imageID = self.profileImageID else { completion(nil); return }
        let imageRef = Storage.storage().reference(withPath: "avatars/512px/\(imageID).jpg")
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error {
                ErrorLog.save(error)
                completion(nil)
            } else if let data {
                completion(UIImage(data: data))
            }
        }
    }

    static func getData(with userUID: String, completion: @escaping(_ userAccount: UserAccount?) -> Void) {
        let dbase = Firestore.firestore()
        let accountRef = dbase.collection("accounts").document(userUID)

        accountRef.getDocument { user, error in
            if let error {
                ErrorLog.save(error)
            } else if let user, user.exists {
                completion(try? user.data(as: UserAccount.self))
            } else {
                ErrorLog.save("user not exist")
            }
        }
    }
}
