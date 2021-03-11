package com.example.data_offloading_app;

import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

public class DownloadUploadService extends Service {

    public void onCreate(){
        super.onCreate();
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ){
            NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "messages")
                    .setContentText("Download/Upload läuft im Hintergrund")
                    .setContentTitle("Data Offloading App");
            startForeground(101, builder.build());
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
