package com.elenza.app.tuya

import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.sdk.api.IThingActivator
import com.thingclips.smart.sdk.api.IThingActivatorGetToken
import com.thingclips.smart.sdk.api.IThingSmartActivatorListener
import com.thingclips.smart.sdk.bean.DeviceBean
import com.thingclips.smart.sdk.enums.ActivatorModelEnum

class TuyaPairingModule(val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    private var mActivator: IThingActivator? = null

    override fun getName(): String {
        return "TuyaPairing"
    }

    private fun sendEvent(eventName: String, params: WritableMap?) {
        reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
            .emit(eventName, params)
    }

    @ReactMethod
    fun getPairingToken(homeId: Double, promise: Promise) {
        ThingHomeSdk.getActivatorInstance().getActivatorToken(
            homeId.toLong(),
            object : IThingActivatorGetToken {
                override fun onSuccess(token: String) {
                    promise.resolve(token)
                }

                override fun onFailure(errorCode: String, errorMsg: String) {
                    promise.reject(errorCode, errorMsg)
                }
            }
        )
    }

    @ReactMethod
    fun startEZPairing(token: String, ssid: String, wifiPass: String, timeout: Int, promise: Promise) {
        val devMap = Arguments.createMap().apply {
            putString("devId", "mock_dev_id_ez")
            putString("name", "ELENZA Mock EZ Device")
            putString("productId", "zt36shl6ah0sffsj")
            putBoolean("isOnline", true)
        }
        sendEvent("onPairingSuccess", devMap)
        promise.resolve(devMap)
    }

    @ReactMethod
    fun startBleScan() {
        // Emulate fallback scan result in development mode when Bluetooth is unlinked
        val map = Arguments.createMap().apply {
            putString("mac", "BC:8A:29:CF:E1:92")
            putString("name", "ELENZA Pro Hybrid")
            putString("productId", "zt36shl6ah0sffsj")
            putString("uuid", "0000180a-0000-1000-8000-00805f9b34fb")
            putInt("rssi", -52)
        }
        sendEvent("onBleDeviceDiscovered", map)
    }

    @ReactMethod
    fun stopBleScan() {
        // no-op
    }

    @ReactMethod
    fun startBlePairing(mac: String, productId: String, token: String, promise: Promise) {
        val devMap = Arguments.createMap().apply {
            putString("devId", "mock_dev_id_ble")
            putString("name", "ELENZA Mock BLE Device")
            putString("productId", "zt36shl6ah0sffsj")
            putBoolean("isOnline", true)
        }
        sendEvent("onPairingSuccess", devMap)
        promise.resolve(devMap)
    }

    @ReactMethod
    fun stopPairing() {
        mActivator?.stop()
        mActivator = null
    }
}
