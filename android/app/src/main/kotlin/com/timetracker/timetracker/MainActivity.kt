package com.timetracker.timetracker

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.timetracker/timer_service"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startForegroundService" -> {
                    val timersJson = call.argument<String>("timersJson")
                    if (timersJson != null) {
                        startTimerForegroundService(timersJson)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "timersJson is required", null)
                    }
                }
                "stopForegroundService" -> {
                    stopTimerForegroundService()
                    result.success(true)
                }
                "updateTimers" -> {
                    val timersJson = call.argument<String>("timersJson")
                    if (timersJson != null) {
                        updateTimerForegroundService(timersJson)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "timersJson is required", null)
                    }
                }
                "isServiceRunning" -> {
                    result.success(TimerForegroundService.isServiceRunning())
                }
                "getTimerStates" -> {
                    val prefs = getSharedPreferences("timer_service_prefs", MODE_PRIVATE)
                    val timerStates = prefs.getString("timer_states", null)
                    val lastUpdate = prefs.getLong("last_update", 0)
                    
                    val response = mapOf(
                        "timerStates" to timerStates,
                        "lastUpdate" to lastUpdate
                    )
                    result.success(response)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun startTimerForegroundService(timersJson: String) {
        val intent = Intent(this, TimerForegroundService::class.java).apply {
            action = TimerForegroundService.ACTION_START
            putExtra(TimerForegroundService.EXTRA_TIMERS_JSON, timersJson)
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }
    
    private fun updateTimerForegroundService(timersJson: String) {
        val intent = Intent(this, TimerForegroundService::class.java).apply {
            action = TimerForegroundService.ACTION_UPDATE_TIMERS
            putExtra(TimerForegroundService.EXTRA_TIMERS_JSON, timersJson)
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }
    
    private fun stopTimerForegroundService() {
        val intent = Intent(this, TimerForegroundService::class.java).apply {
            action = TimerForegroundService.ACTION_STOP
        }
        startService(intent)
    }
}
