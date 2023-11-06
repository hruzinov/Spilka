//
//  Created by Evhen Gruzinov on 20.09.2023.
//

import SwiftyRSA
import FirebaseFirestoreSwift
import SwiftUI
import UniformTypeIdentifiers

struct CryptoKeys {
    var privateKey: PrivateKey?
    var publicKey: PublicKey?

    init() {
        do {
            let keyPair = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
            privateKey = keyPair.privateKey
            publicKey = keyPair.publicKey
        } catch {
            ErrorLog.save(error)
        }
    }

    static func checkValidity(privateKeyData: Data, publicKeyData: Data) -> Bool {
        do {
            let privateKey = try PrivateKey(data: privateKeyData)
            let publicKey = try PublicKey(data: publicKeyData)
            let inputString = "Hi Alice! This is Bob!"

            let clear = try ClearMessage(string: inputString, using: .utf8)
            let encryptedBase64 = try clear.encrypted(with: publicKey, padding: .PKCS1).base64String

            let encrypted = try EncryptedMessage(base64Encoded: encryptedBase64)
            let clearDecrypt = try encrypted.decrypted(with: privateKey, padding: .PKCS1)
            let outputString = try clearDecrypt.string(encoding: .utf8)

            return inputString == outputString
        } catch {
            ErrorLog.save(error)
            return false
        }
    }
}

struct ServerKeyData: Codable {
    @DocumentID var uid: String?
    var keyHex: String
    var initVector: String

    enum CodingKeys: String, CodingKey {
        case uid, keyHex
        case initVector = "iv"
    }
}

struct CryptoKeyFile: FileDocument, Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.data)
            .suggestedFileName("Spilka_PrivateKey")
    }

    static var readableContentTypes: [UTType] = [UTType.data]
    var data: Data = .init()

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard configuration.file.regularFileContents != nil else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}
