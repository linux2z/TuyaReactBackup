#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(SDKValidationManager, NSObject)

RCT_EXTERN_METHOD(getStartupDiagnostics:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
