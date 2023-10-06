//
//  Created by Evhen Gruzinov on 20.09.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

struct UserAccount: Codable {
    let uuid: String
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
                print(error)
                completion(nil)
            } else if let data {
                completion(UIImage(data: data))
            }
        }
    }

    static func getData(withAccountUID userUID: String, completion: @escaping(_ userAccount: UserAccount?) -> Void) {
        let dbase = Firestore.firestore()
        let accountRef = dbase.collection("accounts").document(userUID)

        accountRef.getDocument { user, error in
            if let error {
                print(error)
            } else if let user, user.exists {
                completion(try? user.data(as: UserAccount.self))
            } else {
                print("user not exist")
            }
        }
    }

    static func getData(withUUID userUUID: String, completion: @escaping(_ userAccount: UserAccount?) -> Void) {
        let dbase = Firestore.firestore()
        let accountRef = dbase.collection("accounts").whereField("uuid", isEqualTo: userUUID)

        accountRef.getDocuments { querySnapshot, error in
            if let error {
                print(error)
            } else if let querySnapshot, let user = querySnapshot.documents.first, user.exists {
                completion(try? user.data(as: UserAccount.self))
            } else {
                print("User not exist")
            }
        }
    }
}
