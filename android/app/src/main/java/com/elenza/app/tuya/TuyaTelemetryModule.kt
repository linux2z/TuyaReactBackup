package com.elenza.app.tuya

import com.alibaba.fastjson.JSON
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.sdk.api.IThingDevice

class TuyaTelemetryModule(val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return "TuyaTelemetry"
    }

    private fun sendEvent(eventName: String, params: WritableMap?) {
        reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
            .emit(eventName, params)
    }

    @ReactMethod
    fun startTelemetryListener(devId: String, promise: Promise) {
        val currentDps = Arguments.createMap()
        currentDps.putBoolean("1", true)
        promise.resolve(currentDps)
    }

    @ReactMethod
    fun stopTelemetryListener(devId: String) {
        // no-op
    }
}
