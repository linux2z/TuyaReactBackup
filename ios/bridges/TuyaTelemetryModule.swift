import Foundation
import ThingSmartBaseKit
import ThingSmartDeviceKit

@objc(TuyaTelemetryModule)
class TuyaTelemetryModule: RCTEventEmitter, ThingSmartDeviceDelegate {
    
    private var mDevice: ThingSmartDevice?
    
    override static func moduleName() -> String! {
        return "TuyaTelemetry"
    }
    
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    override func supportedEvents() -> [String]! {
        return ["onTelemetryUpdate"]
    }
    
    @objc
    func subscribeTelemetry(_ devId: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        mDevice = ThingSmartDevice(devId: devId)
        if let dev = mDevice {
            dev.delegate = self
            resolve(true)
        } else {
            reject("DEVICE_INIT_ERROR", "Failed to subscribe to device \(devId)", nil)
        }
    }
    
    @objc
    func unsubscribeTelemetry() {
        mDevice?.delegate = nil
        mDevice = nil
    }
    
    // MARK: - ThingSmartDeviceDelegate
    
    func device(_ device: ThingSmartDevice!, dpsUpdate dps: [AnyHashable : Any]!) {
        guard let dpsMap = dps as? [String: Any] else { return }
        
        let telemetryMap: [String: Any] = [
            "devId": device.deviceModel.devId ?? "",
            "dps": dpsMap
        ]
        
        sendEvent(withName: "onTelemetryUpdate", body: telemetryMap)
    }
}
