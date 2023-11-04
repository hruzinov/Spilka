//
//  Testing view for adding and testing new features
//
//  Created by Evhen Gruzinov on 21.09.2023.
//
// swiftlint:disable all

import CryptoSwift
import SwiftUI

struct TestingView: View {
    var body: some View {
        Text("This is TestingView")
            .onAppear {
//                let privateKeyS = try! RSA(keySize: 1024)
//
//                let publickey = try! privateKeyS.publicKeyExternalRepresentation().base64EncodedString()
//                let privateKey = try! privateKeyS.externalRepresentation().base64EncodedString()
//
//                print(publickey)
//                print()
//                print(privateKey)


                let publicKey = try! RSA(rawRepresentation: Data(base64Encoded: "MIGIAoGAe2Tyu6757UxAMnkFfCpmqtT7o/KEy+BsAWpKmNC9m+Pl3rtYYWe+q0eExiemsAkmsHmSOEN8QqnsSK0xJe0l3YXz8mzij3D+GGPdAyExOz89XEGoqbL15WhpdTGCd5JJlPl++/W0U+yx+RGH1z4UfuJ6q/UtW+lvgyW5N9AemUkCAwEAAQ==")!)

//                let publicKey = try! RSA(rawRepresentation: Data(hex: "3081890281810090a9886df7a1d9841f6c759c8bdf724f1e095b16a34e964420ae9795a32c3416c24e9ae6c13fd1fd3ce76cc82b83bf33951472d6a533c23256667ecc3372736bf5d2adb976bd2e91494626f086f3bc28a5837276a45b8eee451a895d68814a3d49517916c164a1ab95285c2da982c0103f201cdc00cd6cd338c235bf5c78ca890203010001"))

//                let privateKey = try! RSA(rawRepresentation: Data(hex: "3082025b0201000281810090a9886df7a1d9841f6c759c8bdf724f1e095b16a34e964420ae9795a32c3416c24e9ae6c13fd1fd3ce76cc82b83bf33951472d6a533c23256667ecc3372736bf5d2adb976bd2e91494626f086f3bc28a5837276a45b8eee451a895d68814a3d49517916c164a1ab95285c2da982c0103f201cdc00cd6cd338c235bf5c78ca89020301000102818064c584613e5083aa930d45bca07f2e2cc8fab1764a9a92f8b05f8efed12518c005e925e4bb17cf1afe5324272890e51f74a942fa1d28ba0dc0bc3375e21cc7238f372af3c639b97e024fcee3ec0e1c090d39b7d76aa0b731074d6b7e91a7eba069c6be8e1f9a6ba9acedbad08a4dab116e412c1dca9b9042c2e251ad764dc2a5024100d45f6d9a4777b1613173c352513ef6ce5feaf5fec6ddf056c72f13d1e5fd009bc9fec1fde90f088eef89497a456cb24614e0cdbc31be301bf0aced2cd9426f5f024100ae613e696ecbd4741b9473f5b724f004f247cb2cb19c735d669cc68e8c5aee3b6795e9f25ef93228477c576e3a285680781f01f87aafd37495bf2eb90f08d71702407312ce39b595e6984a8a768089237bea315108402813a421f145d2107ef54b3a1f069aa8f17ac2e1686bd4539b809d4c9a0d818d02cb1218619de1d9d6534833024030da1d59fc282e44b8d54607385fa8be3a01d2f19a7072016095db2a6437b535ff37086b562009e52ee1aebcba9e425d8b49648bf01301f24f6157fd9030b1d102404c87becdee72239af2af9589872761f850cc5737fd541a180f754f7080ae76f0736210bca93cf723451d7baae6c3e901087b37047f73700da49e257ace7ee5a9"))



                let startingText = "test message"
                let bytedText: [UInt8] = Array(startingText.utf8)
////
                let encryptedTextBytes = try! publicKey.encrypt(bytedText)
                let encryptedText = encryptedTextBytes.toHexString()

//                String(bytes: encryptedTextBytes, encoding: .utf8)

//
//                let decryptedData = try! privateKey.decrypt(Data(hex: encryptedText).bytes)
//
//                let decryptedText = String(data: Data(decryptedData), encoding: .utf8)





//                print("Im here")

//                let decryptedData = try? privateKey.decrypt(Data(hex: message.text).bytes),

                print(encryptedText)

//                print(" ")

//                print(decryptedText)

                

//                let rsaPrivate = try! RSA(keySize: 1024)
//
//                print(try! rsaPrivate.publicKeyExternalRepresentation().toHexString())
//                print(" ")
//                print(try! rsaPrivate.externalRepresentation().toHexString())

//                let pass = "password"
//                let uid = "x0zixfG95oVSypW6RzqN2K85Suq2"
////
//                let privateKey = try! RSA(rawRepresentation: Data(hex: "3082025a0201000281805654c4eef3b96105afba8d9f71e8b8ee7d6fc5d655af2cc774113f432fe2b96b8110049c6b216986364925c9abf77df0c9b7b3a0fa794b0bb1a3a7282ec8047edfedcfcfbe5bcf31b54d06ab204440c0a9220123dae0ede9fdcfa2cc1f62a587d6cd22fb6f2d447eab756568d6dc00b3c55faedb8d5b1e3b03836f3e7ba0695502030100010281801bce29af9ca8346b9471cd737148b76778d72b2d2163ce545f39beda70ede13292db09e1275017a0b69350ac67cacab16706d7c01d6c3b93849f6513381e0bf44119ead8e7c47fc7171edd79ac95df7060e27952e23a092496357aab34dd3bd162cb1a1c332812fcb15e894c1e7a8965caa09d1b0b38c55e8ce535bf554ca37102410087b56030a79ced1614adc6e3aae6b427620d83f620d291f8615ec3d8217765af452e3aaaba95b363dd8373c28c2d892d530fd87803401883701af0be27ed9ec7024100a2dacec4c053f7a7045701c6133af5a639fedfc9b31b8fead3c4bcfc704e4db05203d9d189fead9ee642585ddd8b7daea9bb7d5f69757da5e3cbd0c590d30b0302407c276651fcf6273d1d3c028a44cefda04e275943f2b15253ef18d88941cccedd73a8208a135b639c088afb7bcfecd4e3ff6aaebad5166d96ca180b899c53daff0240048ff4b2f66063d3bdff6201569094492fdec00e3a824f29d8fcedfe7476fd1e2f6e0430269987eba7afbc22050edf5a814ecb585ceff9b1280c91b0b739f259024036b37002c31d2f916420ce594dfca192b47ad66090e91011bef8a1e005b426d57643e636668ee8a13967bc921b24442e7522005dcf59a64258ecade3830afe0d"))
////
//                let password = String(pass.utf8).bytes
//                let salt = String(uid.utf8).bytes
//                let aesKey = try! PKCS5.PBKDF2(
//                    password: password,
//                    salt: salt,
//                    iterations: 4096,
//                    keyLength: 32,
//                    variant: .sha3(.sha256)
//                ).calculate()
//                let initVector = AES.randomIV(AES.blockSize)
////
//                let aes = try! AES(key: aesKey, blockMode: CBC(iv: initVector), padding: .pkcs7)
//                let encryptedKey = try! aes.encrypt(privateKey.externalRepresentation().bytes)
//                let encryptedKeyHex = encryptedKey.toHexString()
////
//                let serverKeyData = ServerKeyData(keyHex: encryptedKeyHex, initVector: initVector.toHexString())
////
//                print(serverKeyData.initVector)
//                print(" ")
//                print(serverKeyData.keyHex)

            }
    }
}

#Preview {
    TestingView()
}

// swiftlint:enable all
