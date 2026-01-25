import UIKit

// Модель для удобного доступа к цвету и его имени
struct TrackerColorSelection {
    let name: String
    let uiColor: UIColor
}

let availableColors: [TrackerColorSelection] = [
    TrackerColorSelection(name: "Color selection 1", uiColor: UIColor(named: "Color selection 1") ?? .gray),
    TrackerColorSelection(name: "Color selection 2", uiColor: UIColor(named: "Color selection 2") ?? .gray),
    TrackerColorSelection(name: "Color selection 3", uiColor: UIColor(named: "Color selection 3") ?? .gray),
    TrackerColorSelection(name: "Color selection 4", uiColor: UIColor(named: "Color selection 4") ?? .gray),
    TrackerColorSelection(name: "Color selection 5", uiColor: UIColor(named: "Color selection 5") ?? .gray),
    TrackerColorSelection(name: "Color selection 6", uiColor: UIColor(named: "Color selection 6") ?? .gray),
    TrackerColorSelection(name: "Color selection 7", uiColor: UIColor(named: "Color selection 7") ?? .gray),
    TrackerColorSelection(name: "Color selection 8", uiColor: UIColor(named: "Color selection 8") ?? .gray),
    TrackerColorSelection(name: "Color selection 9", uiColor: UIColor(named: "Color selection 9") ?? .gray),
    TrackerColorSelection(name: "Color selection 10", uiColor: UIColor(named: "Color selection 10") ?? .gray),
    TrackerColorSelection(name: "Color selection 11", uiColor: UIColor(named: "Color selection 11") ?? .gray),
    TrackerColorSelection(name: "Color selection 12", uiColor: UIColor(named: "Color selection 12") ?? .gray),
    TrackerColorSelection(name: "Color selection 13", uiColor: UIColor(named: "Color selection 13") ?? .gray),
    TrackerColorSelection(name: "Color selection 14", uiColor: UIColor(named: "Color selection 14") ?? .gray),
    TrackerColorSelection(name: "Color selection 15", uiColor: UIColor(named: "Color selection 15") ?? .gray),
    TrackerColorSelection(name: "Color selection 16", uiColor: UIColor(named: "Color selection 16") ?? .gray),
    TrackerColorSelection(name: "Color selection 17", uiColor: UIColor(named: "Color selection 17") ?? .gray),
    TrackerColorSelection(name: "Color selection 18", uiColor: UIColor(named: "Color selection 18") ?? .gray)
]

