package com.example.notey_task

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin

class MainActivity: FlutterActivity(){
    override fun configureFlutterEngine(flutterEngine: flutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterFirebaseMessagingPlugin.registerWith(flutterEngine)
    }
}
