package com.elenza.coffee

import android.app.Application
import com.thingclips.smart.home.sdk.ThingHomeSdk

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        
        try {
            // Official Tuya SDK Initialization MUST be in Application class
            ThingHomeSdk.init(this)
            ThingHomeSdk.setDebugMode(true)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
