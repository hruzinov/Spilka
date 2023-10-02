//
//  Created by Evhen Gruzinov on 20.09.2023.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftyRSA

struct CryptoKeys {
    var privateKey: PrivateKey?
    var publicKey: PublicKey?

    init() {
        do {
            (privateKey, publicKey) = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
        } catch {
            print(error)
        }
    }
}

struct CryptoKeyFile: FileDocument, Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.data)
            .suggestedFileName("Spilka_PrivateKey")
    }

    static var readableContentTypes: [UTType] = [UTType.data]
    var data: Data = Data()

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard configuration.file.regularFileContents != nil else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }

}
