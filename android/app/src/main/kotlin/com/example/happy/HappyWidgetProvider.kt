package com.example.happy

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class HappyWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.happy_widget_layout).apply {
                // Get data from SharedPreferences (saved by HomeWidget.saveWidgetData in Flutter)
                val title = widgetData.getString("title", "Be Happy Everyday")
                val isPremium = widgetData.getBoolean("isPremium", false)
                val lockedMessage = widgetData.getString("lockedMessage", "Open app to unlock ✨")
                val actualMessage = widgetData.getString("message", lockedMessage)
                
                val displayMessage = if (isPremium) actualMessage else lockedMessage
                
                val bgColorStr = widgetData.getString("bgColor", "#F5FAF0")
                val textColorStr = widgetData.getString("textColor", "#6B8B5A")

                try {
                    val bgColor = android.graphics.Color.parseColor(bgColorStr)
                    val textColor = android.graphics.Color.parseColor(textColorStr)
                    
                    // Dynamiczne kolory
                    setInt(R.id.widget_container, "setBackgroundColor", bgColor)
                    setTextColor(R.id.widget_title, textColor)
                    setTextColor(R.id.widget_message, textColor)
                } catch (e: Exception) {
                    // Fallback z layoutu
                }
                
                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_message, displayMessage)

                // Launch App on Click
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
