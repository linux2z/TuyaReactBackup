#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(TuyaPairingModule, RCTEventEmitter)

RCT_EXTERN_METHOD(getPairingToken:(double)homeId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(startEZPairing:(NSString *)token
                  ssid:(NSString *)ssid
                  wifiPass:(NSString *)wifiPass
                  timeout:(NSInteger)timeout
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(startBleScan)

RCT_EXTERN_METHOD(stopBleScan)

RCT_EXTERN_METHOD(startBlePairing:(NSString *)mac
                  productId:(NSString *)productId
                  token:(NSString *)token
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(stopPairing)

@end
