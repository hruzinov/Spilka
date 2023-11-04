//
//  Created by Evhen Gruzinov on 20.09.2023.
//

import CryptoSwift
import FirebaseFirestoreSwift
import SwiftUI
import UniformTypeIdentifiers

struct CryptoKeys {
    var privateKey: RSA?
    var publicKeyRepresentation: Data?

    init() {
        do {
            privateKey = try RSA(keySize: 1024)
            publicKeyRepresentation = try privateKey!.publicKeyExternalRepresentation()
        } catch {
            ErrorLog.save(error)
        }
    }

    static func checkValidity(privateKeyData: Data, publicKeyData: Data) -> Bool {
        do {
            let privateKey = try RSA(rawRepresentation: privateKeyData)
            let publicKey = try RSA(rawRepresentation: publicKeyData)
            let inputString = "Hi Alice! This is Bob!"

            let encrypted = try publicKey.encrypt(inputString.bytes)
            let decrypted = try privateKey.decrypt(encrypted)
            let outputString = String(data: Data(decrypted), encoding: .utf8)

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
