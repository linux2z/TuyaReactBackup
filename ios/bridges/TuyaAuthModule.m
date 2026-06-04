#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(TuyaAuthModule, NSObject)

RCT_EXTERN_METHOD(isLoggedIn:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(loginWithEmail:(NSString *)email
                  pass:(NSString *)pass
                  regionCode:(NSString *)regionCode
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(registerWithEmail:(NSString *)email
                  pass:(NSString *)pass
                  code:(NSString *)code
                  regionCode:(NSString *)regionCode
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(sendVerificationCode:(NSString *)email
                  regionCode:(NSString *)regionCode
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(logout:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getOrCreateHome:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
