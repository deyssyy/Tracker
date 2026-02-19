import UIKit

struct Tracker{
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let days: [DayOfWeek]
    let isPinned: Bool
    
    init(id: UUID = UUID(), title: String, color: UIColor, emoji: String, days: [DayOfWeek], isPinned: Bool = false) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.days = days
        self.isPinned = isPinned
    }
}
