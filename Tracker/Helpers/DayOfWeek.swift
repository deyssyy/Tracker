import Foundation
enum DayOfWeek: Int, CaseIterable, Codable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    var fullName: String {
        return Calendar.current.standaloneWeekdaySymbols[self.rawValue - 1].capitalized
    }
    
    var shortName: String {
        return Calendar.current.shortStandaloneWeekdaySymbols[self.rawValue - 1].capitalized
    }
}

