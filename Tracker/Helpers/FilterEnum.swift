enum FilterType: Int, CaseIterable {
    case all = 0
    case today = 1
    case completed = 2
    case uncompleted = 3
    
    var title: String {
        switch self {
        case .all: return "all_tracker_filter".localized
        case .today: return "today_tracker_filter".localized
        case .completed: return "completed_tracker_filter".localized
        case .uncompleted: return "uncompleted_tracker_filter".localized
        }
    }
}
