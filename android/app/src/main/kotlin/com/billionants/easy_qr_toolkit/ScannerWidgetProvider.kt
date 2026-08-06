package com.billionants.easy_qr_toolkit

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import android.net.Uri
import com.billionants.easy_qr_toolkit.R

/**
 * [ScannerWidgetProvider] extends [HomeWidgetProvider] to handle Android Home Screen Widget lifecycle.
 *
 * NOTE ON IDE WARNINGS & @Suppress("NewApi"):
 * 1. API Level Warning: In `build.gradle.kts`, `minSdk` is dynamically set to `flutter.minSdkVersion` (API 21+).
 *    Because Android Studio's static linter in single-window mode doesn't evaluate Gradle variables,
 *    it defaults to `minSdk = 1` and flags API level 16 (`getAppWidgetOptions`) and API level 3 (`updateAppWidget`).
 *    `@Suppress("NewApi")` informs the compiler/IDE that runtime minSdk is >= 21, resolving all API warnings.
 *
 * 2. Flutter Plugins Link:
 *    The `home_widget` package library path in `.idea/libraries/Flutter_Plugins.xml` and
 *    `android/easy_qr_toolkit_android.iml` has been linked to resolve `es.antonborri` references.
 */
@Suppress("NewApi")
class ScannerWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        // Iterate through all active instances of the widget on the home screen
        appWidgetIds.forEach { widgetId ->
            val options = appWidgetManager.getAppWidgetOptions(widgetId)
            updateWidget(context, appWidgetManager, widgetId, options)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        // Re-render widget layout when resized by the user on home screen
        updateWidget(context, appWidgetManager, appWidgetId, newOptions)
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        options: Bundle
    ) {
        // Get current widget width in dp to adjust responsive layout
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)

        val views = RemoteViews(context.packageName, R.layout.widget_scanner).apply {
            // Create intent to launch Flutter app directly into QR Scanner screen via deep link (esqr://scan)
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("esqr://scan")
            )
            
            // Attach tap listener to all click targets in the widget layout
            setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            setOnClickPendingIntent(R.id.widget_icon, pendingIntent)
            setOnClickPendingIntent(R.id.widget_text, pendingIntent)

            // Responsive UI: Hide text label if widget is resized narrower than 80dp
            if (minWidth < 80) {
                setViewVisibility(R.id.widget_text, View.GONE)
            } else {
                setViewVisibility(R.id.widget_text, View.VISIBLE)
            }
        }

        // Push the updated RemoteViews layout to AppWidgetManager
        appWidgetManager.updateAppWidget(widgetId, views)
    }
}
