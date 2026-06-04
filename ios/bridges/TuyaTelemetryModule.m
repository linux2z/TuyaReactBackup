#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(TuyaTelemetryModule, RCTEventEmitter)

RCT_EXTERN_METHOD(subscribeTelemetry:(NSString *)devId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(unsubscribeTelemetry)

@end
