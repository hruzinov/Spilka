//
//  Created by Evhen Gruzinov on 20.09.2023.
//

import Foundation
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
