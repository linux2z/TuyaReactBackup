#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(TuyaControlModule, NSObject)

RCT_EXTERN_METHOD(publishDps:(NSString *)devId
                  command:(NSDictionary *)command
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
