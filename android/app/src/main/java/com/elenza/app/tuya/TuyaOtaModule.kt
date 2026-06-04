package com.elenza.app.tuya

import com.facebook.react.bridge.*

class TuyaOtaModule(val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return "TuyaOta"
    }

    @ReactMethod
    fun checkFirmwareUpdate(devId: String, promise: Promise) {
        val infoList = Arguments.createArray()
        promise.resolve(infoList)
    }

    @ReactMethod
    fun startFirmwareUpgrade(devId: String, promise: Promise) {
        promise.resolve("Firmware upgrade complete")
    }
}
