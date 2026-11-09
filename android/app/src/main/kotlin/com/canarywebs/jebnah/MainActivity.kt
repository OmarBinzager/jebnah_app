package com.canarywebs.jebnah

import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "high_importance_channel"
            val channelName = "Jebnah Notifications"
            val channelDescription = "Notifications for orders and updates"
            val importance = NotificationManager.IMPORTANCE_HIGH

            val soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            val audioAttributes = AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .build()

            val notificationManager = getSystemService(NotificationManager::class.java)
            if (notificationManager != null) {
                val existingChannel = notificationManager.getNotificationChannel(channelId)
                if (existingChannel != null && existingChannel.sound == null) {
                    notificationManager.deleteNotificationChannel(channelId)
                }

                val channel = NotificationChannel(channelId, channelName, importance).apply {
                    description = channelDescription
                    enableVibration(true)
                    enableLights(true)
                    setSound(soundUri, audioAttributes)
                }
                notificationManager.createNotificationChannel(channel)
            }
        }
    }
}
