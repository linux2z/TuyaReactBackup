import Foundation
import ThingSmartBaseKit
import ThingSmartActivatorKit
import ThingSmartBLEKit

@objc(TuyaPairingModule)
class TuyaPairingModule: RCTEventEmitter, ThingSmartActivatorDelegate, ThingSmartBLEManagerDelegate {
    
    private var isBleScanning = false
    
    override static func moduleName() -> String! {
        return "TuyaPairing"
    }
    
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    override func supportedEvents() -> [String]! {
        return [
            "onPairingStep",
            "onPairingSuccess",
            "onPairingError",
            "onBleDeviceDiscovered"
        ]
    }
    
    @objc
    func getPairingToken(_ homeId: Double, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        ThingSmartActivator.sharedInstance().getTokenWithHomeId(Int64(homeId)) { token in
            resolve(token)
        } failure: { error in
            let nsError = error as NSError?
            reject(String(nsError?.code ?? -1), nsError?.localizedDescription ?? "Failed to acquire pairing token", error)
        }
    }
    
    @objc
    func startEZPairing(_ token: String, ssid: String, wifiPass: String, timeout: Int, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        ThingSmartActivator.sharedInstance().delegate = self
        ThingSmartActivator.sharedInstance().startActive(withType: .ez, ssid: ssid, password: wifiPass, token: token, timeout: TimeInterval(timeout))
        resolve(true)
    }
    
    @objc
    func startBleScan() {
        if isBleScanning { return }
        isBleScanning = true
        ThingSmartBLEManager.sharedInstance().delegate = self
        ThingSmartBLEManager.sharedInstance().startScan()
        
        // Emulate fallback scan result in development mode when running on simulator
        #if targetEnvironment(simulator)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let map: [String: Any] = [
                "mac": "BC:8A:29:CF:E1:92",
                "name": "ELENZA Pro Hybrid",
                "productId": "zt36shl6ah0sffsj",
                "uuid": "0000180a-0000-1000-8000-00805f9b34fb",
                "rssi": -52
            ]
            self.sendEvent(withName: "onBleDeviceDiscovered", body: map)
        }
        #endif
    }
    
    @objc
    func stopBleScan() {
        if !isBleScanning { return }
        isBleScanning = false
        ThingSmartBLEManager.sharedInstance().stopScan()
    }
    
    @objc
    func startBlePairing(_ mac: String, productId: String, token: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        ThingSmartActivator.sharedInstance().delegate = self
        ThingSmartActivator.sharedInstance().startActive(withType: .ble, ssid: "", password: "", token: token, timeout: 100.0)
        resolve(true)
    }
    
    @objc
    func stopPairing() {
        ThingSmartActivator.sharedInstance().stopActive()
    }
    
    // MARK: - ThingSmartActivatorDelegate
    
    func activator(_ activator: ThingSmartActivator!, didReceiveDevice device: ThingSmartDeviceModel!, error: Error!) {
        if let err = error {
            let nsError = err as NSError
            let errMap: [String: Any] = [
                "code": String(nsError.code),
                "message": nsError.localizedDescription
            ]
            sendEvent(withName: "onPairingError", body: errMap)
            return
        }
        
        if let dev = device {
            let devMap: [String: Any] = [
                "devId": dev.devId ?? "",
                "name": dev.name ?? "",
                "productId": dev.productId ?? "",
                "isOnline": dev.isOnline
            ]
            sendEvent(withName: "onPairingSuccess", body: devMap)
        }
    }
    
    func activator(_ activator: ThingSmartActivator!, didStep step: ThingSmartActivatorStep, data: [AnyHashable : Any]!) {
        var stepStr = "unknown"
        var progressVal = 50
        
        if step == .found {
            stepStr = "device_find"
            progressVal = 30
        } else if step == .bind {
            stepStr = "device_bind_cloud"
            progressVal = 70
        }
        
        let stepMap: [String: Any] = [
            "step": stepStr,
            "progress": progressVal
        ]
        sendEvent(withName: "onPairingStep", body: stepMap)
    }
    
    // MARK: - ThingSmartBLEManagerDelegate
    
    func didDiscoveryDevice(_ uuid: String!, type: ThingSmartBLEType, name: String!, advertisingData: [AnyHashable : Any]!) {
        let macAddress = advertisingData["mac"] as? String ?? uuid ?? ""
        let map: [String: Any] = [
            "mac": macAddress,
            "name": name ?? "Unknown BLE",
            "productId": "zt36shl6ah0sffsj",
            "uuid": uuid ?? "",
            "rssi": -55
        ]
        sendEvent(withName: "onBleDeviceDiscovered", body: map)
    }
}
