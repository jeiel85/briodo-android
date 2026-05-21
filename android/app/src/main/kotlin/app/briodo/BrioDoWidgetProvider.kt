package app.briodo

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider

/// 1x2 또는 2x2 홈 위젯. 오늘의 활성 할 일 N개 + 헤더 카운트.
/// 데이터 갱신은 Flutter 측 services/home_widget_service.dart에서 push.
class BrioDoWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.briodo_widget_layout)

            val activeCount = widgetData.getInt("widget.activeCount", 0)
            val firstLine = widgetData.getString("widget.firstLine", "") ?: ""

            views.setTextViewText(
                R.id.widget_count,
                if (activeCount > 0) activeCount.toString() else "0"
            )
            views.setTextViewText(
                R.id.widget_first_line,
                if (firstLine.isEmpty()) "오늘 할 일 없음" else firstLine
            )

            // 위젯 본체 클릭 → 앱 열기
            val openIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("briodo://open")
            )
            views.setOnClickPendingIntent(R.id.widget_root, openIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
