import Foundation
import AppMetricaCore

final class AnalyticsService {
    
    enum Item: String {
        case addTrack = "add_track"
        case track = "track"
        case filter = "filter"
        case edit = "edit"
        case delete = "delete"
    }
    
    
    private static func report(event: String, item: Item? = nil) {
        var params: [AnyHashable: Any] = [
            "event": event,
            "screen": "Main"
        ]
        
        if let item = item {
            params["item"] = item.rawValue
        }
        
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: \(error.localizedDescription)")
        })
        
        print("[Analytics] event: \(event), screen: Main, item: \(item?.rawValue ?? "none")")
    }
    
    // MARK: - Публичные методы для вызова из контроллера
    
    static func reportOpen() {
        report(event: "open")
    }
    
    static func reportClose() {
        report(event: "close")
    }
    
    static func reportClick(_ item: Item) {
        report(event: "click", item: item)
    }
    
    static func activateAnalyze(){
        if let configuration = AppMetricaConfiguration(apiKey: "c890f530-e659-4ad9-ba7c-8913b38c2426"){
            configuration.areLogsEnabled = true
            AppMetrica.activate(with: configuration)
        }
    }
}
