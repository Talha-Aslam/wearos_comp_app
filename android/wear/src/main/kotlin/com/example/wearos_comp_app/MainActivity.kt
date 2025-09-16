package com.example.wearos_comp_app

import android.app.Activity
import android.os.Bundle

class MainActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // This is a placeholder for the bundled wear activity
        // In a production app, this would launch the Flutter engine
        // configured for Wear OS with the wear-specific dart code
        finish()
    }
}