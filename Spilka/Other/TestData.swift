//
//  Created by Evhen Gruzinov on 05.10.2023.
//

import Foundation

struct TestData {
    static var testAccount = UserAccount(
        uuid: "testUserAccount",
        name: "Test Account",
        countryCode: "UA",
        phoneNumber: "123456789",
        profileImageID: nil,
        username: "test",
        description: "This is test user. Don't write me, please 🥸",
        publicKey:
            "3081880281805654c4eef3b96105afba8d9f71e8b8ee7d6fc5d655af2cc774113f432fe2b96b8110049c6b216986364925c9abf77df0c9b7b3a0fa794b0bb1a3a7282ec8047edfedcfcfbe5bcf31b54d06ab204440c0a9220123dae0ede9fdcfa2cc1f62a587d6cd22fb6f2d447eab756568d6dc00b3c55faedb8d5b1e3b03836f3e7ba069550203010001" // swiftlint:disable:this line_length
    )
    static var testUserPrivateKey = "3082025a0201000281805654c4eef3b96105afba8d9f71e8b8ee7d6fc5d655af2cc774113f432fe2b96b8110049c6b216986364925c9abf77df0c9b7b3a0fa794b0bb1a3a7282ec8047edfedcfcfbe5bcf31b54d06ab204440c0a9220123dae0ede9fdcfa2cc1f62a587d6cd22fb6f2d447eab756568d6dc00b3c55faedb8d5b1e3b03836f3e7ba0695502030100010281801bce29af9ca8346b9471cd737148b76778d72b2d2163ce545f39beda70ede13292db09e1275017a0b69350ac67cacab16706d7c01d6c3b93849f6513381e0bf44119ead8e7c47fc7171edd79ac95df7060e27952e23a092496357aab34dd3bd162cb1a1c332812fcb15e894c1e7a8965caa09d1b0b38c55e8ce535bf554ca37102410087b56030a79ced1614adc6e3aae6b427620d83f620d291f8615ec3d8217765af452e3aaaba95b363dd8373c28c2d892d530fd87803401883701af0be27ed9ec7024100a2dacec4c053f7a7045701c6133af5a639fedfc9b31b8fead3c4bcfc704e4db05203d9d189fead9ee642585ddd8b7daea9bb7d5f69757da5e3cbd0c590d30b0302407c276651fcf6273d1d3c028a44cefda04e275943f2b15253ef18d88941cccedd73a8208a135b639c088afb7bcfecd4e3ff6aaebad5166d96ca180b899c53daff0240048ff4b2f66063d3bdff6201569094492fdec00e3a824f29d8fcedfe7476fd1e2f6e0430269987eba7afbc22050edf5a814ecb585ceff9b1280c91b0b739f259024036b37002c31d2f916420ce594dfca192b47ad66090e91011bef8a1e005b426d57643e636668ee8a13967bc921b24442e7522005dcf59a64258ecade3830afe0d" // swiftlint:disable:this line_length

    static let testUsersUUIDs: [String] = [
        "73AD3AE2-AAB9-4B5E-AF1D-C95B74F0366F",
        "C8655C34-3D06-427B-843D-42A53E1D8974",
        "16A5BE41-D7B7-4A2F-9804-37A45B3EC2FD"
    ]

    // swiftlint:disable line_length
    static let testChat: Chat = Chat(id: "", user: testAccount, messagesDictionary: generateMessagesDictionary())

    static private func generateMessagesDictionary() -> [String: Message] {
        let UUID1 = UUID().uuidString
        let UUID2 = UUID().uuidString
        let messagesDictionary = [
            UUID1: Message(id: UUID1, fromID: "73AD3AE2-AAB9-4B5E-AF1D-C95B74F0366F",
                    toID: "testUserAccount", text: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.", isUnread: false, dateTime: Date.now),
            UUID2: Message(id: UUID2, fromID: "testUserAccount",
                    toID: "73AD3AE2-AAB9-4B5E-AF1D-C95B74F0366F", text: "Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur?", isUnread: false, dateTime: Date.now)
        ]
        return messagesDictionary
    }
    // swiftlint:enable line_length
}
