//
//  Created by Evhen Gruzinov on 20.09.2023.
//

import Foundation

struct UserAccount: Codable {
    let uid: String
    var name: String
    var countryCode: String?
    var phoneNumber: String?
    var profileImageID: String?
    var username: String
    var description: String?
    var publicKey: String

    static var testUser = UserAccount(
        uid: "testUserAccount",
        name: "Test Account",
        countryCode: "UA",
        phoneNumber: "123456789",
        profileImageID: nil,
        username: "test",
        description: "This is test user. Don't write me, please 🥸",
        publicKey:
            "MIIBCgKCAQEAsTrh+92egoGYKMVxoYMWZlqZ9/Xdwv7Ql8EfNBhKeGh6skbsDMo3qc/XwT2iSXH45+hNhXqlIPdKqwK5clUZPgPranEXSggfSe0zxThgK/MGtZPCHhhbPOl5a8LGEXW+fn0wgvgPYodKP+6H4QVelSm6v1zf2pMs7DYu9KvtGkE1TWnuIxuW+vAq+pS1keu5gc4Ds9aN456gVrwmw+/ZRMm1zSCf9w/HjHRDQB/ONYE++pbs3cdBNNAJTWZLuJ/XrL+cd+9RSavFMDTtg1K4ywQZvYxMr6HebknyIDaTjQjSCHLV+kYXjgjDt9/Pwjh2/L0y8CR+jCsV4DWNFMeJYQIDAQAB" // swiftlint:disable:this line_length
    )
    static var testUserPrivateKey = "MIIEpAIBAAKCAQEAsTrh+92egoGYKMVxoYMWZlqZ9/Xdwv7Ql8EfNBhKeGh6skbsDMo3qc/XwT2iSXH45+hNhXqlIPdKqwK5clUZPgPranEXSggfSe0zxThgK/MGtZPCHhhbPOl5a8LGEXW+fn0wgvgPYodKP+6H4QVelSm6v1zf2pMs7DYu9KvtGkE1TWnuIxuW+vAq+pS1keu5gc4Ds9aN456gVrwmw+/ZRMm1zSCf9w/HjHRDQB/ONYE++pbs3cdBNNAJTWZLuJ/XrL+cd+9RSavFMDTtg1K4ywQZvYxMr6HebknyIDaTjQjSCHLV+kYXjgjDt9/Pwjh2/L0y8CR+jCsV4DWNFMeJYQIDAQABAoIBABg5OZkAvgENcHwmHHVcYuvjd0buanyT8nPDeB3ZMhiKAzcpvWq0Gu6RU2Z8o5lRRBmCZVIYpMhANIryKOGpIvWYeI1IXswGFyy2CIzsuyxWn7SiuPX/Ez1clfV2HjdVtg840jAccpHfdvUNB7JoVvihRv6P1aLc2deBQmK7uwEK7VHUQYqbXGtqb/7831sIc8PmrxPJvM2CGwUVbxnzx9UE7FSbYqUwEA6ADg0GJ1McUNbxdx/gVWZkeb53oKGO1wl/WLUxGfu1xjUeyJWGfhAFPX5Q5Y/SCEfRrgFWLoySf7rUzHNWf8fGJobBi8ftJ/1v1s8Xl2Q/+WKt/KIvVRcCgYEA3v5v2hAoavJ2/vN3VW+lIZTro6obxC6jNZRV80zX00YO2bI4BnRJOaAYjg1BtsgzickQsBv4OIgS2f1WYXQPF/TMy00gZKsJQdIRDGXkubdY8EaD44H3urbz69oeDzaL4hIFHGbUuatpr0xxnQAIRQ/E1koYny5dg8/BTGZOJR8CgYEAy3ZivWkw5xsgHv9qllZhqfaPUvMOoyV1fj6/4L7RNbbNdHmvnpE7GB3/Wh0n2FDrkUpSlAAOTQBsTRvAUZO7L8TMW4wvC84gXWrUZOoR/y0ubUDzEMatEOafLbLZbmGwlgOIDYJ/JyXbPr+YQHaRpzZ+3STBibfulxcAoDBiAX8CgYEAkC8GFYJTD+uco3a610QsCo2m2xkXgP8CypcSCBHMjzACVCJW9V1lJ1xr5BWQQuYp5NJb9vLuyWa6gba7jqGjTMMdU+qXol+wyZ1RJqoPfUGewSVnC8iybEj1aK+Mtht30QIDyfx3WWILIKyV3YTy0+zBQimAyBQLpTnE62hO6NMCgYEAgljr1TEI9WY5Y+J6ZKoek4a0N44juH2NEj4dK1zUJzdf1NkIm+urEj5Vk2POXRUqdcBJuyt1/frhZ1z6Dsk4SNgpnBTpJwT9UxvXynby5KoLbk8H6Z1+zq8RF3PXPJI1UUYd6ZnK4EeueDrCzbmogpm1GPQtUY+WuRExg267uv0CgYBFgHk5vjnmq3mU3+pk/PqPIAjzNZlgMw4Lj1tjCgmNfU1tOF17JcHTyJ8CEezyr7QPG8gmdxsraK4DcAb6NpEMKKD6xb5k/zixuvcrWN3dC2hStWyKBS3iAZlgGO4JN/eWjKlZ03rVeeg+ymQ/gUWHCs94DMSQKEcXlms54GM7fg==" // swiftlint:disable:this line_length
}
