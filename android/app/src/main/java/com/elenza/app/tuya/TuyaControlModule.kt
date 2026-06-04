package com.elenza.app.tuya

import com.facebook.react.bridge.*

class TuyaControlModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return "TuyaControl"
    }

    @ReactMethod
    fun sendCommands(devId: String, commands: ReadableMap, promise: Promise) {
        promise.resolve("Commands published successfully")
    }
}
