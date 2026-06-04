package com.elenza.app.tuya

import com.facebook.react.bridge.*

class TuyaAuthModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return "TuyaAuth"
    }

    @ReactMethod
    fun sendVerificationCode(email: String, countryCode: String, promise: Promise) {
        promise.resolve("Verification code sent successfully")
    }

    @ReactMethod
    fun registerWithEmail(email: String, password: String, code: String, countryCode: String, promise: Promise) {
        val userMap = Arguments.createMap().apply {
            putString("uid", "mock_uid")
            putString("email", email)
            putString("sid", "mock_sid")
        }
        promise.resolve(userMap)
    }

    @ReactMethod
    fun loginWithEmail(email: String, password: String, countryCode: String, promise: Promise) {
        val userMap = Arguments.createMap().apply {
            putString("uid", "mock_uid")
            putString("email", email)
            putString("sid", "mock_sid")
        }
        promise.resolve(userMap)
    }

    @ReactMethod
    fun isLoggedIn(promise: Promise) {
        val userMap = Arguments.createMap().apply {
            putString("uid", "mock_uid")
            putString("email", "dev@elenza.coffee")
            putString("sid", "mock_sid")
        }
        promise.resolve(userMap)
    }

    @ReactMethod
    fun logout(promise: Promise) {
        promise.resolve("Logged out successfully")
    }

    @ReactMethod
    fun getOrCreateHome(promise: Promise) {
        val homeMap = Arguments.createMap().apply {
            putDouble("homeId", 12345.0)
            putString("name", "ELENZA Laboratory")
        }
        promise.resolve(homeMap)
    }
}
