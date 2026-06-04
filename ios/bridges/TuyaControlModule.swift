import Foundation
import ThingSmartBaseKit
import ThingSmartDeviceKit

@objc(TuyaControlModule)
class TuyaControlModule: NSObject, RCTBridgeModule {
    
    static func moduleName() -> String! {
        return "TuyaControl"
    }
    
    static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    @objc
    func publishDps(_ devId: String, command: [String: Any], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        guard let device = ThingSmartDevice(devId: devId) else {
            reject("DEVICE_INIT_FAILED", "Failed to connect to device context", nil)
            return
        }
        
        device.publishDps(command) {
            resolve(true)
        } failure: { error in
            let nsError = error as NSError?
            reject(String(nsError?.code ?? -1), nsError?.localizedDescription ?? "Failed to publish DPs", error)
        }
    }
}
