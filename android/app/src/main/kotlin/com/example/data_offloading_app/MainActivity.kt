package com.example.data_offloading_app

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.net.wifi.WifiManager
import android.net.ConnectivityManager
import android.os.Bundle
import android.app.Activity
import android.content.Context
import android.net.NetworkRequest
import android.net.Network
import android.net.NetworkCapabilities
import java.net.URL

class MainActivity: FlutterActivity() {
  private val CHANNEL = "ConnectionManager"
  private var isNetworkConnected = false

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      call, result ->
      if (call.method == "getConnectionType"){
        val cm: ConnectivityManager = application.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = cm.getActiveNetwork()
        if(network != null){
          val info = cm.getNetworkInfo(network)
          if(info != null){
            result.success(info.getTypeName())
          } else {
            result.success("NONE")
          }
        } else {

        result.success("NONE")
        }
      }
    }
  }
}
