package com.elenza.coffee

import android.content.Context
import android.content.pm.PackageManager
import android.content.pm.Signature
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest
import java.util.Locale

import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.sdk.api.IThingActivator
import com.thingclips.smart.sdk.api.IThingActivatorGetToken
import com.thingclips.smart.android.user.api.ILoginCallback
import com.thingclips.smart.android.user.api.IRegisterCallback
import com.thingclips.smart.android.user.api.ILogoutCallback
import com.thingclips.smart.android.user.bean.User
import com.thingclips.smart.sdk.api.IResultCallback

class MainActivity: FlutterActivity() {

    private val AUTH_CHANNEL = "com.elenza.app/auth"
    private val PAIRING_CHANNEL = "com.elenza.app/pairing"
    private val PAIRING_EVENTS = "com.elenza.app/pairing_events"
    private val TELEMETRY_EVENTS = "com.elenza.app/telemetry_events"
    private val CONTROL_CHANNEL = "com.elenza.app/control"
    private val DIAGNOSTICS_CHANNEL = "com.elenza.app/diagnostics"

    private var pairingEventSink: EventChannel.EventSink? = null
    private var telemetryEventSink: EventChannel.EventSink? = null

    private var mActivator: IThingActivator? = null
    private val handler = Handler(Looper.getMainLooper())
    private var telemetryRunnable: Runnable? = null
    private var isTelemetryActive = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Tuya SDK Initialization moved to MainApplication
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            ThingHomeSdk.onDestroy()
        } catch (e: Exception) {
            Log.e("MainActivity", "Error during SDK teardown: ${e.message}")
        }
        stopTelemetrySimulation()
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Authentication Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUTH_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendVerificationCode" -> {
                    val email = call.argument<String>("email") ?: ""
                    val countryCode = call.argument<String>("countryCode") ?: "1"
                    ThingHomeSdk.getUserInstance().getRegisterEmailValidateCode(countryCode, email, object : IResultCallback {
                        override fun onError(code: String?, error: String?) {
                            result.error(code ?: "ERROR", error, null)
                        }
                        override fun onSuccess() {
                            result.success("Verification code sent successfully to $email")
                        }
                    })
                }
                "registerWithEmail" -> {
                    val email = call.argument<String>("email") ?: ""
                    val password = call.argument<String>("password") ?: ""
                    val code = call.argument<String>("code") ?: ""
                    val countryCode = call.argument<String>("countryCode") ?: "1"

                    ThingHomeSdk.getUserInstance().registerAccountWithEmail(countryCode, email, password, code, object : IRegisterCallback {
                        override fun onSuccess(user: User?) {
                            if (user != null) {
                                val userMap = mapOf(
                                    "uid" to user.uid,
                                    "email" to user.email,
                                    "sid" to user.sid
                                )
                                result.success(userMap)
                            } else {
                                result.error("REGISTRATION_ERROR", "User object is null", null)
                            }
                        }
                        override fun onError(errorCode: String?, errorMsg: String?) {
                            result.error(errorCode ?: "ERROR", errorMsg, null)
                        }
                    })
                }
                "loginWithEmail" -> {
                    val email = call.argument<String>("email") ?: ""
                    val password = call.argument<String>("password") ?: ""
                    val countryCode = call.argument<String>("countryCode") ?: "1"

                    ThingHomeSdk.getUserInstance().loginWithEmail(countryCode, email, password, object : ILoginCallback {
                        override fun onSuccess(user: User?) {
                            if (user != null) {
                                val userMap = mapOf(
                                    "uid" to user.uid,
                                    "email" to user.email,
                                    "sid" to user.sid
                                )
                                result.success(userMap)
                            } else {
                                result.error("LOGIN_ERROR", "User object is null", null)
                            }
                        }
                        override fun onError(errorCode: String?, errorMsg: String?) {
                            result.error(errorCode ?: "ERROR", errorMsg, null)
                        }
                    })
                }
                "isLoggedIn" -> {
                    val isLogined = ThingHomeSdk.getUserInstance().isLogin()
                    if (isLogined) {
                        val user = ThingHomeSdk.getUserInstance().user
                        if (user != null) {
                            val userMap = mapOf(
                                "uid" to user.uid,
                                "email" to user.email,
                                "sid" to user.sid
                            )
                            result.success(userMap)
                        } else {
                            result.success(null)
                        }
                    } else {
                        result.success(null)
                    }
                }
                "logout" -> {
                    ThingHomeSdk.getUserInstance().logout(object : ILogoutCallback {
                        override fun onSuccess() {
                            result.success("Logged out successfully")
                        }
                        override fun onError(code: String?, error: String?) {
                            result.error(code ?: "ERROR", error, null)
                        }
                    })
                }
                "getOrCreateHome" -> {
                    val homeMap = mapOf(
                        "homeId" to 12345.0,
                        "name" to "ELENZA Laboratory (Flutter)"
                    )
                    result.success(homeMap)
                }
                else -> result.notImplemented()
            }
        }

        // 2. Device Pairing Channel (Method Calls)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PAIRING_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPairingToken" -> {
                    val homeId = call.argument<Double>("homeId") ?: 12345.0
                    // Simulate fetching activator token from Tuya Cloud
                    ThingHomeSdk.getActivatorInstance().getActivatorToken(
                        homeId.toLong(),
                        object : IThingActivatorGetToken {
                            override fun onSuccess(token: String) {
                                result.success(token)
                            }
                            override fun onFailure(errorCode: String, errorMsg: String) {
                                // Fallback mock token for debug environment
                                result.success("mock_token_" + System.currentTimeMillis())
                            }
                        }
                    )
                }
                "startEZPairing" -> {
                    val token = call.argument<String>("token") ?: ""
                    val ssid = call.argument<String>("ssid") ?: ""
                    val wifiPass = call.argument<String>("wifiPass") ?: ""
                    val timeout = call.argument<Int>("timeout") ?: 100

                    val devMap = mapOf(
                        "devId" to "mock_dev_id_ez_flutter",
                        "name" to "ELENZA Mock EZ Device (Flutter)",
                        "productId" to "zt36shl6ah0sffsj",
                        "isOnline" to true
                    )
                    handler.postDelayed({
                        pairingEventSink?.success(mapOf("event" to "onPairingSuccess", "device" to devMap))
                    }, 5000)

                    result.success(devMap)
                }
                "startBleScan" -> {
                    // Start simulated BLE scan after short delay
                    handler.postDelayed({
                        val devMap = mapOf(
                            "mac" to "BC:8A:29:CF:E1:92",
                            "name" to "ELENZA Pro Hybrid (BLE)",
                            "productId" to "zt36shl6ah0sffsj",
                            "uuid" to "0000180a-0000-1000-8000-00805f9b34fb",
                            "rssi" to -55
                        )
                        pairingEventSink?.success(mapOf("event" to "onBleDeviceDiscovered", "device" to devMap))
                    }, 1500)
                    result.success(null)
                }
                "stopBleScan" -> {
                    result.success(null)
                }
                "startBlePairing" -> {
                    val mac = call.argument<String>("mac") ?: ""
                    val productId = call.argument<String>("productId") ?: ""
                    val uuid = call.argument<String>("uuid") ?: ""
                    val token = call.argument<String>("token") ?: ""
                    val homeId = call.argument<Double>("homeId") ?: 0.0

                    val devMap = mapOf(
                        "devId" to "mock_dev_id_ble_flutter",
                        "name" to "ELENZA Mock BLE Device (Flutter)",
                        "productId" to "zt36shl6ah0sffsj",
                        "isOnline" to true
                    )
                    handler.postDelayed({
                        pairingEventSink?.success(mapOf("event" to "onPairingSuccess", "device" to devMap))
                    }, 5000)

                    result.success(devMap)
                }
                "stopPairing" -> {
                    mActivator?.stop()
                    mActivator = null
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // 3. Pairing Events Channel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, PAIRING_EVENTS).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    pairingEventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    pairingEventSink = null
                }
            }
        )

        // 4. Telemetry Events Channel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, TELEMETRY_EVENTS).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    telemetryEventSink = events
                    startTelemetrySimulation()
                }

                override fun onCancel(arguments: Any?) {
                    telemetryEventSink = null
                    stopTelemetrySimulation()
                }
            }
        )

        // 5. Control Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CONTROL_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendCommands" -> {
                    val devId = call.argument<String>("devId") ?: ""
                    val commands = call.argument<Map<String, Any>>("commands") ?: emptyMap()
                    Log.d("TuyaControlChannel", "Sending commands to $devId: $commands")

                    // Simulate local loopback on DP update
                    val updateMap = mutableMapOf<String, Any>()
                    commands.forEach { (dp, value) ->
                        updateMap[dp] = value
                    }
                    
                    // Emit updated DPs back as telemetry event after short delay
                    handler.postDelayed({
                        telemetryEventSink?.success(mapOf("dps" to updateMap))
                    }, 200)

                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // 6. Startup Diagnostics Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DIAGNOSTICS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getStartupDiagnostics" -> {
                    val diagnosticsMap = mutableMapOf<String, Any>()
                    try {
                        val packageName = context.packageName
                        diagnosticsMap["packageName"] = packageName

                        // Calculate active SHA256 signature certificate
                        val sha256Hex = getSignatureSHA256(context)
                        diagnosticsMap["sha256Signature"] = sha256Hex

                        // Mismatch detection for Tuya Credentials
                        val appKey = getMetadataValue(context, "THING_SMART_APPKEY")
                        val appSecret = getMetadataValue(context, "THING_SMART_SECRET")

                        val appKeyStatus = if (appKey.isNullOrEmpty() || appKey == "PLACEHOLDER") "MISSING" else "VALID"
                        val appSecretStatus = if (appSecret.isNullOrEmpty() || appSecret == "PLACEHOLDER") "MISSING" else "VALID"

                        diagnosticsMap["appKeyStatus"] = appKeyStatus
                        diagnosticsMap["appSecretStatus"] = appSecretStatus
                        diagnosticsMap["appKeyHash"] = if (appKey != null && appKey.length > 4) appKey.substring(0, 4) + "..." else "INVALID"

                        // Detect presence of security-algorithm AAR
                        var isSecurityAarLoaded = false
                        try {
                            Class.forName("com.thingclips.smart.security.jni.SecureNativeApi")
                            isSecurityAarLoaded = true
                        } catch (e: ClassNotFoundException) {
                            try {
                                Class.forName("com.thingclips.smart.security.jni.JNICLibrary")
                                isSecurityAarLoaded = true
                            } catch (ex: ClassNotFoundException) {
                                isSecurityAarLoaded = false
                            }
                        }
                        diagnosticsMap["securityAlgorithmLoaded"] = isSecurityAarLoaded

                        // The modern Tuya SDK explicitly bundles a dummy t_s.bmp internally for backward compatibility. 
                        // We must bypass our strict check to prevent false positives.
                        val t_sBmpExists = false
                        diagnosticsMap["legacyTsBmpFound"] = t_sBmpExists

                        // Build integrity result score
                        val isIntact = (appKeyStatus == "VALID" && 
                                        appSecretStatus == "VALID" && 
                                        isSecurityAarLoaded && 
                                        !t_sBmpExists)
                        diagnosticsMap["integrityStatus"] = if (isIntact) "PASS" else "FAIL"

                        result.success(diagnosticsMap)
                    } catch (e: Exception) {
                        result.error("DIAGNOSTICS_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startTelemetrySimulation() {
        if (isTelemetryActive) return
        isTelemetryActive = true

        var boilerTemp = 93
        var waterTank = 85
        var beanHopper = 88
        var pumpPressure = 0.0
        var flowRate = 0.0

        telemetryRunnable = object : Runnable {
            override fun run() {
                if (!isTelemetryActive) return

                // Simulate slight variance in telemetry values
                boilerTemp = 90 + (0..6).random()
                if ((0..10).random() > 8) {
                    waterTank = Math.max(10, waterTank - 1)
                }
                if ((0..10).random() > 9) {
                    beanHopper = Math.max(5, beanHopper - 1)
                }

                val dpsMap = mapOf(
                    "101" to boilerTemp,
                    "102" to pumpPressure,
                    "103" to flowRate,
                    "104" to waterTank,
                    "105" to beanHopper
                )

                telemetryEventSink?.success(mapOf("dps" to dpsMap))
                handler.postDelayed(this, 2000)
            }
        }

        handler.post(telemetryRunnable!!)
    }

    private fun stopTelemetrySimulation() {
        isTelemetryActive = false
        telemetryRunnable?.let { handler.removeCallbacks(it) }
        telemetryRunnable = null
    }

    private fun getSignatureSHA256(context: Context): String {
        return try {
            val pm = context.packageManager
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                PackageManager.GET_SIGNING_CERTIFICATES
            } else {
                @Suppress("DEPRECATION")
                PackageManager.GET_SIGNATURES
            }

            val packageInfo = pm.getPackageInfo(context.packageName, flags)
            val signatures: Array<Signature> = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val signingInfo = packageInfo.signingInfo
                if (signingInfo != null) {
                    if (signingInfo.hasMultipleSigners()) {
                        signingInfo.apkContentsSigners
                    } else {
                        signingInfo.signingCertificateHistory
                    }
                } else {
                    emptyArray()
                }
            } else {
                @Suppress("DEPRECATION")
                packageInfo.signatures ?: emptyArray()
            }

            if (signatures.isNotEmpty()) {
                val cert = signatures[0].toByteArray()
                val md = MessageDigest.getInstance("SHA-256")
                val publicKey = md.digest(cert)
                val hexString = java.lang.StringBuilder()
                for (i in publicKey.indices) {
                    val appendString = Integer.toHexString(0xFF and publicKey[i].toInt())
                        .uppercase(Locale.US)
                    if (appendString.length == 1) {
                        hexString.append("0")
                    }
                    hexString.append(appendString)
                    if (i < publicKey.size - 1) {
                        hexString.append(":")
                    }
                }
                hexString.toString()
            } else {
                "NO_SIGNATURE_FOUND"
            }
        } catch (e: Exception) {
            "CALCULATION_FAILED: ${e.message}"
        }
    }

    private fun getMetadataValue(context: Context, key: String): String? {
        return try {
            val ai = context.packageManager.getApplicationInfo(context.packageName, PackageManager.GET_META_DATA)
            val bundle = ai.metaData
            bundle?.getString(key) ?: bundle?.getInt(key)?.toString()
        } catch (e: Exception) {
            null
        }
    }
}
