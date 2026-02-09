import UIKit

struct Tracker{
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let days: [DayOfWeek]
    
    init(id: UUID = UUID(), title: String, color: UIColor, emoji: String, days: [DayOfWeek]) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.days = days
    }
}
