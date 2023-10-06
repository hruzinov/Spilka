//
//  Created by Evhen Gruzinov on 05.10.2023.
//

import Foundation

extension Date {
    func stringRel() -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: .now)

        if calendar.isDateInToday(self) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: self)
        } else if calendar.isDateInYesterday(self) {
            return("Yesterday")
        } else if self >= (sevenDaysAgo ?? Date.now) {
            dateFormatter.dateFormat = "EEE"
            return dateFormatter.string(from: self)
        } else if calendar.isDate(self, equalTo: Date.now, toGranularity: .year) {
            dateFormatter.dateFormat = "dd/MM"
            return dateFormatter.string(from: self)
        } else {
            dateFormatter.dateFormat = "DD/MM/YY"
            return dateFormatter.string(from: self)
        }
    }
}
