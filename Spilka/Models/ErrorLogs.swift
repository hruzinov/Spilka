//
//  Created by Evhen Gruzinov on 06.10.2023.
//

import Foundation

struct ErrorLog: Codable {
    let errorDescription: String
    let errorCode: Int?
    let date: Date

    static func getLogs() -> [ErrorLog] {
        if let encodedLogs = UserDefaults.standard.object(forKey: "ErrorsLogs") as? Data {
            let decoder = JSONDecoder()
            if let decodedLogs = try? decoder.decode([ErrorLog].self, from: encodedLogs) {
                return decodedLogs
            } else { return [] }
        } else { return [] }
    }

    static func save(_ error: Error?) {
        print(error as Any)
        guard let error else { return }

        let encoder = JSONEncoder()
        let nsError = error as NSError
        var existingLogs = getLogs()

        existingLogs.append(ErrorLog(errorDescription: nsError.description, errorCode: nsError.code, date: Date.now))

        if let encoded = try? encoder.encode(existingLogs) {
            UserDefaults.standard.set(encoded, forKey: "ErrorsLogs")
        }
    }

    static func save(_ error: String) {
        let encoder = JSONEncoder()
        var existingLogs = getLogs()

        existingLogs.append(ErrorLog(errorDescription: error, errorCode: nil, date: Date.now))

        if let encoded = try? encoder.encode(existingLogs) {
            UserDefaults.standard.set(encoded, forKey: "ErrorsLogs")
        }
        print(error)
    }
}
