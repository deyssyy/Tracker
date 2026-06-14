import SnapshotTesting
import XCTest
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testTrackerViewController() throws {
        let vc = TrackerViewController()
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)), named: "light")
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)), named: "dark")
    }
}
