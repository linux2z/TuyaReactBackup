package com.elenza.app.tuya

import android.content.Context
import android.content.pm.PackageManager
import android.content.pm.Signature
import android.os.Build
import android.util.Log
import com.facebook.react.bridge.*
import java.security.MessageDigest
import java.util.Locale

class SDKValidationManager(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String = "SDKValidationManager"

    @ReactMethod
    fun getStartupDiagnostics(promise: Promise) {
        val result = Arguments.createMap()
        try {
            val packageName = reactContext.packageName
            result.putString("packageName", packageName)

            // 1. Calculate active SHA256 signature certificate
            val sha256Hex = getSignatureSHA256(reactContext)
            result.putString("sha256Signature", sha256Hex)

            // 2. Mismatch detection for Tuya Credentials
            val appKey = getMetadataValue(reactContext, "THING_SMART_APPKEY")
            val appSecret = getMetadataValue(reactContext, "THING_SMART_APPSECRET")

            val appKeyStatus = if (appKey.isNullOrEmpty() || appKey == "PLACEHOLDER") "MISSING" else "VALID"
            val appSecretStatus = if (appSecret.isNullOrEmpty() || appSecret == "PLACEHOLDER") "MISSING" else "VALID"

            result.putString("appKeyStatus", appKeyStatus)
            result.putString("appSecretStatus", appSecretStatus)
            result.putString("appKeyHash", if (appKey != null && appKey.length > 4) appKey.substring(0, 4) + "..." else "INVALID")

            // 3. Detect presence of security-algorithm AAR
            var isSecurityAarLoaded = false
            try {
                // Check for a core class inside the security-algorithm bundle
                Class.forName("com.thingclips.smart.security.AlgorithmEntry")
                isSecurityAarLoaded = true
            } catch (e: ClassNotFoundException) {
                try {
                    Class.forName("com.thingclips.smart.security.SecurityAlgorithm")
                    isSecurityAarLoaded = true
                } catch (ex: ClassNotFoundException) {
                    isSecurityAarLoaded = false
                }
            }
            result.putBoolean("securityAlgorithmLoaded", isSecurityAarLoaded)

            // 4. Verify no old t_s.bmp exists in assets
            var t_sBmpExists = false
            try {
                val assetList = reactContext.assets.list("")
                if (assetList != null) {
                    for (file in assetList) {
                        if (file.equals("t_s.bmp", ignoreCase = true)) {
                            t_sBmpExists = true
                            break
                        }
                    }
                }
            } catch (e: Exception) {
                t_sBmpExists = false
            }
            result.putBoolean("legacyTsBmpFound", t_sBmpExists)

            // 5. Build integrity result score
            val isIntact = (appKeyStatus == "VALID" && 
                            appSecretStatus == "VALID" && 
                            isSecurityAarLoaded && 
                            !t_sBmpExists)
            result.putString("integrityStatus", if (isIntact) "PASS" else "FAIL")

            promise.resolve(result)
        } catch (e: Exception) {
            promise.reject("DIAGNOSTICS_ERROR", e.message, e)
        }
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

            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                pm.getPackageInfo(context.packageName, flags)
            } else {
                @Suppress("DEPRECATION")
                pm.getPackageInfo(context.packageName, flags)
            }

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
                val hexString = StringBuilder()
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
            Log.e("SDKValidation", "Failed to compute SHA-256 signature", e)
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
