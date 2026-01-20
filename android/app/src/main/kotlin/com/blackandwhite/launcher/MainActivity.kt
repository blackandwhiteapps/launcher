package com.blackandwhite.launcher

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.hardware.camera2.CameraManager
import android.net.Uri
import android.os.BatteryManager
import android.os.Build
import android.provider.MediaStore
import android.provider.Telephony
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.blackandwhite.launcher/battery"
    private val APP_CHANNEL = "com.blackandwhite.launcher/app"
    private val LAUNCHER_CHANNEL = "com.blackandwhite.launcher/launcher"
    private var isFlashlightOn = false

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        // Handle HOME intent - ensure the launcher stays visible
        if (Intent.ACTION_MAIN == intent.action && intent.hasCategory(Intent.CATEGORY_HOME)) {
            // With singleTask launch mode, this should bring us to front
            // Make sure we're visible
            if (!isFinishing && !isDestroyed) {
                // Activity should remain visible
            }
        }
    }

    override fun onResume() {
        super.onResume()
        // Ensure the launcher is visible when resumed
        // This is especially important when set as default launcher
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()
                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "launchPhone" -> {
                    launchPhone()
                    result.success(null)
                }
                "launchMessages" -> {
                    launchMessages()
                    result.success(null)
                }
                "launchCamera" -> {
                    launchCamera()
                    result.success(null)
                }
                "openNotificationPanel" -> {
                    openNotificationPanel()
                    result.success(null)
                }
                "launchClock" -> {
                    launchClock()
                    result.success(null)
                }
                "launchCalendar" -> {
                    launchCalendar()
                    result.success(null)
                }
                "toggleFlashlight" -> {
                    toggleFlashlight()
                    result.success(isFlashlightOn)
                }
                "isFlashlightOn" -> {
                    result.success(isFlashlightOn)
                }
                else -> result.notImplemented()
            }
        }
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LAUNCHER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isDefaultLauncher" -> {
                    val isDefault = isDefaultLauncher()
                    result.success(isDefault)
                }
                "openDefaultLauncherSettings" -> {
                    openDefaultLauncherSettings()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }
        return batteryLevel
    }
    
    private fun launchPhone() {
        val intent = Intent(Intent.ACTION_DIAL)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }
    
    private fun launchMessages() {
        // Try to get the default SMS app first (Android 4.4+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            val defaultSmsPackage = Telephony.Sms.getDefaultSmsPackage(this)
            if (defaultSmsPackage != null) {
                val intent = packageManager.getLaunchIntentForPackage(defaultSmsPackage)
                if (intent != null) {
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                    return
                }
            }
        }
        
        // Fallback: try to find any messaging app
        val intent = Intent(Intent.ACTION_MAIN)
        intent.addCategory(Intent.CATEGORY_APP_MESSAGING)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        
        val resolveInfos: List<ResolveInfo> = packageManager.queryIntentActivities(intent, 0)
        if (resolveInfos.isNotEmpty()) {
            val resolveInfo = resolveInfos[0]
            val packageName = resolveInfo.activityInfo.packageName
            val className = resolveInfo.activityInfo.name
            val launchIntent = Intent(Intent.ACTION_MAIN)
            launchIntent.addCategory(Intent.CATEGORY_LAUNCHER)
            launchIntent.setClassName(packageName, className)
            launchIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(launchIntent)
        } else {
            // Last resort: open new message composer
            val fallbackIntent = Intent(Intent.ACTION_SENDTO)
            fallbackIntent.data = Uri.parse("smsto:")
            fallbackIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(fallbackIntent)
        }
    }
    
    private fun launchCamera() {
        // Try to find camera app by package name first
        val cameraPackages = listOf(
            "com.android.camera2",
            "com.google.android.GoogleCamera",
            "com.samsung.android.camera",
            "com.oneplus.camera",
            "com.huawei.camera",
            "com.miui.camera",
            "com.oppo.camera",
            "com.vivo.camera"
        )
        
        for (packageName in cameraPackages) {
            try {
                val intent = packageManager.getLaunchIntentForPackage(packageName)
                if (intent != null) {
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                    return
                }
            } catch (e: Exception) {
                // Continue to next package
            }
        }
        
        // Fallback: Try to find camera apps by querying for apps that handle camera intents
        val cameraIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        val resolveInfos: List<ResolveInfo> = packageManager.queryIntentActivities(cameraIntent, 0)
        if (resolveInfos.isNotEmpty()) {
            // Find the first camera app (not the system camera chooser)
            for (resolveInfo in resolveInfos) {
                val packageName = resolveInfo.activityInfo.packageName
                // Skip system packages that are just choosers
                if (!packageName.contains("com.android.documentsui") && 
                    !packageName.contains("com.google.android.apps.photos")) {
                    val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
                    if (launchIntent != null) {
                        launchIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(launchIntent)
                        return
                    }
                }
            }
        }
        
        // Last resort: open camera to take photo
        cameraIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        if (cameraIntent.resolveActivity(packageManager) != null) {
            startActivity(cameraIntent)
        }
    }
    
    private fun isDefaultLauncher(): Boolean {
        val intent = Intent(Intent.ACTION_MAIN)
        intent.addCategory(Intent.CATEGORY_HOME)
        val resolveInfo = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
        val currentHomePackage = resolveInfo?.activityInfo?.packageName
        val appPackageName = packageName
        return currentHomePackage == appPackageName
    }
    
    private fun openDefaultLauncherSettings() {
        val intent = Intent(Intent.ACTION_MAIN)
        intent.addCategory(Intent.CATEGORY_HOME)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }
    
    private fun openNotificationPanel() {
        // Use reflection to call the hidden expandNotificationsPanel method
        try {
            val service = getSystemService(Context.STATUS_BAR_SERVICE)
            val statusBarManager = Class.forName("android.app.StatusBarManager")
            val expand = statusBarManager.getMethod("expandNotificationsPanel")
            expand.invoke(service)
        } catch (e: Exception) {
            // Fallback: Try using broadcast intent
            try {
                val intent = Intent("android.intent.action.STATUS_BAR")
                sendBroadcast(intent)
            } catch (e2: Exception) {
                // If all else fails, do nothing
            }
        }
    }
    
    private fun launchClock() {
        // Try common clock package names first
        val packages = listOf(
            "com.google.android.deskclock",
            "com.android.deskclock",
            "com.samsung.android.clock"
        )
        for (packageName in packages) {
            try {
                val pkgIntent = packageManager.getLaunchIntentForPackage(packageName)
                if (pkgIntent != null) {
                    pkgIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(pkgIntent)
                    return
                }
            } catch (e: Exception) {
                // Continue to next package
            }
        }
        // Fallback: Try to find any app that handles clock intents
        val intent = Intent(Intent.ACTION_VIEW)
        intent.data = android.net.Uri.parse("clock:")
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        if (intent.resolveActivity(packageManager) != null) {
            startActivity(intent)
        }
    }
    
    private fun launchCalendar() {
        // Try to open calendar app
        val intent = Intent(Intent.ACTION_VIEW)
        intent.type = "time/epoch"
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        if (intent.resolveActivity(packageManager) != null) {
            startActivity(intent)
        } else {
            // Fallback: Try to find calendar app by category
            val calendarIntent = Intent(Intent.ACTION_MAIN)
            calendarIntent.addCategory(Intent.CATEGORY_APP_CALENDAR)
            calendarIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            if (calendarIntent.resolveActivity(packageManager) != null) {
                startActivity(calendarIntent)
            } else {
                // Last resort: Try common calendar package names
                val packages = listOf(
                    "com.google.android.calendar",
                    "com.android.calendar",
                    "com.samsung.android.calendar"
                )
                for (packageName in packages) {
                    try {
                        val pkgIntent = packageManager.getLaunchIntentForPackage(packageName)
                        if (pkgIntent != null) {
                            pkgIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            startActivity(pkgIntent)
                            return
                        }
                    } catch (e: Exception) {
                        // Continue to next package
                    }
                }
            }
        }
    }
    
    private fun toggleFlashlight() {
        try {
            val cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
            val cameraId = cameraManager.cameraIdList[0]
            isFlashlightOn = !isFlashlightOn
            cameraManager.setTorchMode(cameraId, isFlashlightOn)
        } catch (e: Exception) {
            isFlashlightOn = false
        }
    }
}
