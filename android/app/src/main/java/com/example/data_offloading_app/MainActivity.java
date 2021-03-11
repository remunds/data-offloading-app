package com.example.data_offloading_app;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

 private Intent forService;

 @Override
 protected void onCreate(Bundle savedInstanceState) {
  super.onCreate(savedInstanceState);
 GeneratedPluginRegistrant.registerWith(this);

  if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ){
   startForegroundService(forService);
  }
  else{
   startService(forService);
  }

 }
}