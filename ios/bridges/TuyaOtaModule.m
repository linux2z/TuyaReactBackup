#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(TuyaOtaModule, RCTEventEmitter)

RCT_EXTERN_METHOD(startOtaUpgrade:(NSString *)devId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
