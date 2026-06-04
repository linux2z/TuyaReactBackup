import Foundation
import ThingSmartBaseKit
import ThingSmartDeviceKit

@objc(TuyaOtaModule)
class TuyaOtaModule: RCTEventEmitter, ThingSmartOTADelegate {
    
    private var mOta: ThingSmartOTA?
    
    override static func moduleName() -> String! {
        return "TuyaOta"
    }
    
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    override func supportedEvents() -> [String]! {
        return [
            "onOtaProgress",
            "onOtaSuccess",
            "onOtaError"
        ]
    }
    
    @objc
    func startOtaUpgrade(_ devId: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        mOta = ThingSmartOTA(devId: devId)
        if let ota = mOta {
            ota.delegate = self
            ota.startUpgrade()
            resolve(true)
        } else {
            reject("OTA_INIT_FAILED", "Failed to initialize OTA engine", nil)
        }
    }
    
    // MARK: - ThingSmartOTADelegate
    
    func ota(_ ota: ThingSmartOTA!, didProgress progress: Int, type: Int) {
        let map: [String: Any] = [
            "progress": progress,
            "type": type
        ]
        sendEvent(withName: "onOtaProgress", body: map)
    }
    
    func otaDidSuccess(_ ota: ThingSmartOTA!, type: Int) {
        sendEvent(withName: "onOtaSuccess", body: ["type": type])
    }
    
    func ota(_ ota: ThingSmartOTA!, didFail error: Error!, type: Int) {
        let nsError = error as NSError?
        let errMap: [String: Any] = [
            "code": String(nsError?.code ?? -1),
            "message": nsError?.localizedDescription ?? "OTA update failed"
        ]
        sendEvent(withName: "onOtaError", body: errMap)
    }
}
