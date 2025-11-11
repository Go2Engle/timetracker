package com.timetracker.timetracker

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

class TimerForegroundService : Service() {
    companion object {
        const val CHANNEL_ID = "timer_foreground_service"
        const val NOTIFICATION_ID = 1001
        const val ACTION_START = "ACTION_START"
        const val ACTION_STOP = "ACTION_STOP"
        const val ACTION_UPDATE_TIMERS = "ACTION_UPDATE_TIMERS"
        const val EXTRA_TIMERS_JSON = "EXTRA_TIMERS_JSON"
        
        private var isRunning = false
        
        fun isServiceRunning(): Boolean = isRunning
    }
    
    private val handler = Handler(Looper.getMainLooper())
    private var timersData: MutableList<TimerData> = mutableListOf()
    private val updateRunnable = object : Runnable {
        override fun run() {
            updateTimers()
            handler.postDelayed(this, 1000) // Update every second
        }
    }
    
    data class TimerData(
        val taskId: Int,
        val taskName: String,
        var elapsedSeconds: Int,
        val isRunning: Boolean,
        val isPaused: Boolean,
        val sessionStartTime: Long
    )
    
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        isRunning = true
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                // Extract timer data from intent
                val timersJson = intent.getStringExtra(EXTRA_TIMERS_JSON)
                if (timersJson != null) {
                    parseTimersJson(timersJson)
                }
                
                // Start foreground service with notification
                val notification = createNotification()
                startForeground(NOTIFICATION_ID, notification)
                
                // Start the timer update loop
                handler.post(updateRunnable)
            }
            ACTION_UPDATE_TIMERS -> {
                // Update timer data without restarting the loop
                val timersJson = intent.getStringExtra(EXTRA_TIMERS_JSON)
                if (timersJson != null) {
                    parseTimersJson(timersJson)
                }
            }
            ACTION_STOP -> {
                stopSelf()
            }
        }
        
        return START_STICKY // Service will be restarted if killed by system
    }
    
    private fun parseTimersJson(json: String) {
        try {
            val jsonArray = JSONArray(json)
            timersData.clear()
            
            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                timersData.add(
                    TimerData(
                        taskId = obj.getInt("taskId"),
                        taskName = obj.getString("taskName"),
                        elapsedSeconds = obj.getInt("elapsedSeconds"),
                        isRunning = obj.getBoolean("isRunning"),
                        isPaused = obj.getBoolean("isPaused"),
                        sessionStartTime = obj.getLong("sessionStartTime")
                    )
                )
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    private fun updateTimers() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        // Update elapsed time for running timers
        for (timer in timersData) {
            if (timer.isRunning && !timer.isPaused) {
                timer.elapsedSeconds++
                
                // Update individual timer notification
                updateTimerNotification(timer, notificationManager)
            }
        }
        
        // Update foreground service notification
        val notification = createNotification()
        notificationManager.notify(NOTIFICATION_ID, notification)
        
        // Save updated timer states to shared preferences for Flutter to read
        saveTimerStates()
    }
    
    private fun updateTimerNotification(timer: TimerData, notificationManager: NotificationManager) {
        val timeText = formatElapsedTime(timer.elapsedSeconds)
        val statusText = when {
            timer.isRunning && !timer.isPaused -> "Running"
            timer.isPaused -> "Paused"
            else -> "Stopped"
        }
        
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this,
            timer.taskId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(this, "task_timers")
            .setContentTitle(timer.taskName)
            .setContentText("$statusText • $timeText")
            .setSmallIcon(android.R.drawable.ic_menu_recent_history)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(timer.isRunning)
            .setAutoCancel(false)
            .setContentIntent(pendingIntent)
            .build()
        
        notificationManager.notify(timer.taskId, notification)
    }
    
    private fun saveTimerStates() {
        try {
            val prefs = getSharedPreferences("timer_service_prefs", Context.MODE_PRIVATE)
            val jsonArray = JSONArray()
            
            for (timer in timersData) {
                val obj = JSONObject()
                obj.put("taskId", timer.taskId)
                obj.put("taskName", timer.taskName)
                obj.put("elapsedSeconds", timer.elapsedSeconds)
                obj.put("isRunning", timer.isRunning)
                obj.put("isPaused", timer.isPaused)
                obj.put("sessionStartTime", timer.sessionStartTime)
                jsonArray.put(obj)
            }
            
            prefs.edit()
                .putString("timer_states", jsonArray.toString())
                .putLong("last_update", System.currentTimeMillis())
                .apply()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    private fun createNotification(): Notification {
        val runningCount = timersData.count { it.isRunning && !it.isPaused }
        val pausedCount = timersData.count { it.isPaused }
        
        val contentText = when {
            runningCount > 0 && pausedCount > 0 -> "$runningCount running, $pausedCount paused"
            runningCount > 0 -> "$runningCount timer${if (runningCount > 1) "s" else ""} running"
            pausedCount > 0 -> "$pausedCount timer${if (pausedCount > 1) "s" else ""} paused"
            else -> "No active timers"
        }
        
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("TimeTracker")
            .setContentText(contentText)
            .setSmallIcon(android.R.drawable.ic_menu_recent_history)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setContentIntent(pendingIntent)
            .build()
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Timer Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps timers running in the background"
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun formatElapsedTime(seconds: Int): String {
        val hours = seconds / 3600
        val minutes = (seconds % 3600) / 60
        val secs = seconds % 60
        return String.format("%d:%02d:%02d", hours, minutes, secs)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(updateRunnable)
        isRunning = false
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
}
