import Foundation
import IOKit.pwr_mgt

public final class SleepInhibitorService: @unchecked Sendable {
    public static let shared = SleepInhibitorService()
    
    private var assertionID: IOPMAssertionID = 0
    private var isAsserted: Bool = false
    private let lock = NSLock()
    
    public init() {}
    
    public func disableSleep(reason: String = "Streaming video playback in Macnotix") {
        lock.lock()
        defer { lock.unlock() }
        
        guard !isAsserted else { return }
        let success = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason as CFString,
            &assertionID
        )
        if success == kIOReturnSuccess {
            isAsserted = true
        }
    }
    
    public func enableSleep() {
        lock.lock()
        defer { lock.unlock() }
        
        guard isAsserted else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = 0
        isAsserted = false
    }
    
    deinit {
        enableSleep()
    }
}
