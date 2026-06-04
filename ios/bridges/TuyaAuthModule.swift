import Foundation
import ThingSmartBaseKit
import ThingSmartFamilyKit

@objc(TuyaAuthModule)
class TuyaAuthModule: NSObject, RCTBridgeModule {
    
    static func moduleName() -> String! {
        return "TuyaAuth"
    }
    
    static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    @objc
    func isLoggedIn(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        if ThingSmartUser.sharedInstance().isLogin {
            let user = ThingSmartUser.sharedInstance()
            let userMap: [String: Any] = [
                "uid": user.uid ?? "",
                "email": user.email ?? "",
                "sid": user.sid ?? ""
            ]
            resolve(userMap)
        } else {
            resolve(nil)
        }
    }
    
    @objc
    func loginWithEmail(_ email: String, pass: String, regionCode: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        ThingSmartUser.sharedInstance().login(byEmail: regionCode, email: email, password: pass) {
            let user = ThingSmartUser.sharedInstance()
            let userMap: [String: Any] = [
                "uid": user.uid ?? "",
                "email": user.email ?? "",
                "sid": user.sid ?? ""
            ]
            resolve(userMap)
        } failure: { error in
            let nsError = error as NSError?
            reject(String(nsError?.code ?? -1), nsError?.localizedDescription ?? "Authentication failed", error)
        }
    }
    
    @objc
    func registerWithEmail(_ email: String, pass: String, code: String, regionCode: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        ThingSmartUser.sharedInstance().register(byEmail: regionCode, email: email, password: pass, code: code) {
            let user = ThingSmartUser.sharedInstance()
            let userMap: [String: Any] = [
                "uid": user.uid ?? "",
                "email": user.email ?? "",
                "sid": user.sid ?? ""
            ]
            resolve(userMap)
        } failure: { error in
            let nsError = error as NSError?
            reject(String(nsError?.code ?? -1), nsError?.localizedDescription ?? "Registration failed", error)
        }
    }
    
    @objc
    func sendVerificationCode(_ email: String, regionCode: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        ThingSmartUser.sharedInstance().sendVerifyCode(byRegister: regionCode, email: email) {
            resolve(true)
        } failure: { error in
            let nsError = error as NSError?
            reject(String(nsError?.code ?? -1), nsError?.localizedDescription ?? "Failed to send code", error)
        }
    }
    
    @objc
    func logout(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        ThingSmartUser.sharedInstance().loginOut {
            resolve(true)
        } failure: { error in
            let nsError = error as NSError?
            reject(String(nsError?.code ?? -1), nsError?.localizedDescription ?? "Failed to log out", error)
        }
    }
    
    @objc
    func getOrCreateHome(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let homeManager = ThingSmartHomeManager()
        homeManager.getHomeList { homes in
            if let firstHome = homes?.first {
                let homeMap: [String: Any] = [
                    "homeId": firstHome.homeId,
                    "name": firstHome.name ?? ""
                ]
                resolve(homeMap)
            } else {
                homeManager.addHome(withName: "Elenza HQ Room", geoName: "", latitude: 0.0, longitude: 0.0, rooms: ["Barista Suite"]) { homeId in
                    let homeMap: [String: Any] = [
                        "homeId": homeId,
                        "name": "Elenza HQ Room"
                    ]
                    resolve(homeMap)
                } failure: { error in
                    let nsError = error as NSError?
                    reject(String(nsError?.code ?? -1), nsError?.localizedDescription ?? "Home context generation failed", error)
                }
            }
        } failure: { error in
            let nsError = error as NSError?
            reject(String(nsError?.code ?? -1), nsError?.localizedDescription ?? "Failed to retrieve home list", error)
        }
    }
}
