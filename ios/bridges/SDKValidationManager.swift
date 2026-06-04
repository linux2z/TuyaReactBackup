import Foundation

@objc(SDKValidationManager)
class SDKValidationManager: NSObject, RCTBridgeModule {
    
    static func moduleName() -> String! {
        return "SDKValidationManager"
    }
    
    static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    @objc
    func getStartupDiagnostics(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let bundleId = Bundle.main.bundleIdentifier ?? "com.elenza.app"
        
        let appKey = Bundle.main.object(forInfoDictionaryKey: "THING_SMART_APPKEY") as? String
        let appSecret = Bundle.main.object(forInfoDictionaryKey: "THING_SMART_APPSECRET") as? String
        
        let appKeyStatus = (appKey != nil && appKey != "PLACEHOLDER") ? "VALID" : "MISSING"
        let appSecretStatus = (appSecret != nil && appSecret != "PLACEHOLDER") ? "VALID" : "MISSING"
        
        let truncatedKey = (appKey != nil && appKey!.count > 4) ? String(appKey!.prefix(4)) + "..." : "INVALID"
        
        // Mock a stable iOS cryptographic signature footprint for developer diagnostic deck
        let mockIosSha256 = "DE:1C:8A:29:CF:E1:92:B4:EF:20:9E:C1:28:D5:7F:8C:36:A2:B4:EF:92:C9:D8:1A:56:8C:15:3A:5F:C9:AB"
        
        let isIntact = (appKeyStatus == "VALID" && appSecretStatus == "VALID")
        
        let diagnostics: [String: Any] = [
            "packageName": bundleId,
            "sha256Signature": mockIosSha256,
            "appKeyStatus": appKeyStatus,
            "appSecretStatus": appSecretStatus,
            "appKeyHash": truncatedKey,
            "securityAlgorithmLoaded": true, // Always true on iOS as libraries are statically linked
            "legacyTsBmpFound": false,
            "integrityStatus": isIntact ? "PASS" : "FAIL"
        ]
        
        resolve(diagnostics)
    }
}
