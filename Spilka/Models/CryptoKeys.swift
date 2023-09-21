//
//  Created by Evhen Gruzinov on 20.09.2023.
//

import Foundation
import SwiftyRSA

struct CryptoKeys {
    let privateKey: PrivateKey
    var publicKey: PublicKey

    init() {
        (privateKey,publicKey) = try! SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
    }
}
