import CoreData

final class StatisticsDataProvider {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private func fetchStatistics() -> StatisticCoreData {
        let request = StatisticCoreData.fetchRequest()
        let results = try? context.fetch(request)
        
        if let stats = results?.first {
            return stats
        } else {
            let newStats = StatisticCoreData(context: context)
            newStats.bestPeriod = 0
            newStats.idealDays = 0
            newStats.totalCompleted = 0
            newStats.averageValue = 0
            return newStats
        }
    }
    
    func getStatisticsModels() -> [StatisticModel] {
        let stats = fetchStatistics()
        
        return [
            StatisticModel(
                title: "statistic_best_period_label".localized,
                value: "\(stats.bestPeriod)"
            ),
            StatisticModel(
                title: "statistic_ideal_days_label".localized,
                value: "\(stats.idealDays)"
            ),
            StatisticModel(
                title: "statistic_completed_trackers_label".localized,
                value: "\(stats.totalCompleted)"
            ),
            StatisticModel(
                title: "statistic_average_value_label".localized,
                value: "\(stats.averageValue)"
            )
        ]
    }
    
    func updateStatistics(with records: [TrackerRecordCoreData], allTrackers: [TrackerCoreData]) {
        let stats = fetchStatistics()
        let calendar = Calendar.current
        
        stats.totalCompleted = Int64(records.count)
        
        let uniqueDays = Set(records.compactMap { $0.date.map { calendar.startOfDay(for: $0) } })
        stats.averageValue = uniqueDays.count > 0 ? Int64(records.count / uniqueDays.count) : 0
        
        let idealDates = getIdealDates(records: records, trackers: allTrackers)
        stats.idealDays = Int64(idealDates.count)
        
        stats.bestPeriod = Int64(calculateBestPeriod(for: idealDates))
        
    }
    
    private func getIdealDates(records: [TrackerRecordCoreData], trackers: [TrackerCoreData]) -> [Date] {
        let calendar = Calendar.current
        let recordsByDate = Dictionary(grouping: records) { calendar.startOfDay(for: $0.date ?? Date()) }
        
        var idealDates: [Date] = []
        
        for (date, completedRecords) in recordsByDate {
            let weekday = calendar.component(.weekday, from: date)
            let plannedTrackersCount = trackers.filter { tracker in
                let schedule = getScheduleDays(from: tracker.days)
                return schedule.contains(weekday)
            }.count
            
            if plannedTrackersCount > 0 && completedRecords.count >= plannedTrackersCount {
                idealDates.append(date)
            }
        }
        return idealDates.sorted()
    }
    
    private func getScheduleDays(from scheduleString: String?) -> [Int] {
        guard let scheduleString = scheduleString, !scheduleString.isEmpty else { return [] }
        return scheduleString.components(separatedBy: ",").compactMap { Int($0) }
    }
    
    private func calculateBestPeriod(for dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var maxPeriod = 1
        var currentPeriod = 1
        
        for i in 1..<dates.count {
            let previousDate = dates[i-1]
            let currentDate = dates[i]
            
            let components = calendar.dateComponents([.day], from: previousDate, to: currentDate)
            
            if components.day == 1 {
                currentPeriod += 1
            } else {
                maxPeriod = max(maxPeriod, currentPeriod)
                currentPeriod = 1
            }
        }
        
        return max(maxPeriod, currentPeriod)
    }
    
}
