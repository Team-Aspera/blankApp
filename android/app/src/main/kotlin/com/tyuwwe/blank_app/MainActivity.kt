package com.tyuwwe.blank_app

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Bundle
import android.os.PowerManager
import android.view.View
import android.view.WindowManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(), SensorEventListener {
    private val channelName = "blank_app/device"
    private var sensorManager: SensorManager? = null
    private var proximitySensor: Sensor? = null
    private var proximityWakeLock: PowerManager.WakeLock? = null
    private var proximityEnabled = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enterFullscreen()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableProximityScreenOff" -> {
                        val enabled = enableProximityScreenOff()
                        result.success(enabled)
                    }
                    "disableProximityScreenOff" -> {
                        disableProximityScreenOff()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            enterFullscreen()
        }
    }

    override fun onResume() {
        super.onResume()
        enterFullscreen()
        if (proximityEnabled) {
            registerProximitySensor()
            acquireProximityWakeLock()
        }
    }

    override fun onPause() {
        releaseProximityWakeLock()
        sensorManager?.unregisterListener(this)
        super.onPause()
    }

    override fun onDestroy() {
        disableProximityScreenOff()
        super.onDestroy()
    }

    override fun onSensorChanged(event: SensorEvent) {
        acquireProximityWakeLock()
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit

    private fun enterFullscreen() {
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        @Suppress("DEPRECATION")
        window.decorView.systemUiVisibility =
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
                View.SYSTEM_UI_FLAG_FULLSCREEN or
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
    }

    private fun enableProximityScreenOff(): Boolean {
        proximityEnabled = true
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        proximitySensor = sensorManager?.getDefaultSensor(Sensor.TYPE_PROXIMITY)
        val sensorRegistered = registerProximitySensor()
        acquireProximityWakeLock()
        return proximityWakeLock?.isHeld == true || sensorRegistered
    }

    private fun registerProximitySensor(): Boolean {
        val manager = sensorManager ?: return false
        val sensor = proximitySensor ?: return false
        manager.unregisterListener(this, sensor)
        return manager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_NORMAL)
    }

    private fun disableProximityScreenOff() {
        proximityEnabled = false
        releaseProximityWakeLock()
        sensorManager?.unregisterListener(this)
    }

    private fun acquireProximityWakeLock() {
        val lock = proximityWakeLock ?: createProximityWakeLock() ?: return
        if (!lock.isHeld) {
            lock.acquire()
        }
    }

    private fun releaseProximityWakeLock() {
        val lock = proximityWakeLock ?: return
        if (lock.isHeld) {
            lock.release()
        }
    }

    @Suppress("DEPRECATION")
    private fun createProximityWakeLock(): PowerManager.WakeLock? {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        if (!powerManager.isWakeLockLevelSupported(PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK)) {
            return null
        }
        return powerManager
            .newWakeLock(PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK, "$packageName:proximity")
            .also { proximityWakeLock = it }
    }
}
