package com.example.pay_pass

import android.os.Build
import android.app.NotificationChannel
import android.app.NotificationManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(){
     private val CHANNEL = "com.app.channel"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "createNotificationChannel") {
                val arguments = call.arguments as Map<*, *>
                val id = arguments["id"] as String
                val name = arguments["name"] as String
                val description = arguments["description"] as String
                val importance = arguments["importance"] as Int
                createNotificationChannel(id, name, description, importance)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
    private fun createNotificationChannel(id: String, name: String, description: String, importance: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(id, name, importance)
            channel.description = description
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}
