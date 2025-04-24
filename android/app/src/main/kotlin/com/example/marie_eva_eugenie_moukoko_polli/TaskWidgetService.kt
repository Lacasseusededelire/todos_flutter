package com.example.marie_eva_eugenie_moukoko_polli

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin

class TaskWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return TaskWidgetFactory(applicationContext, intent)
    }
}

class TaskWidgetFactory(
    private val context: Context,
    intent: Intent
) : RemoteViewsService.RemoteViewsFactory {
    private val tasks = mutableListOf<Map<String, String>>()

    override fun onCreate() {
        // Initialisation
    }

    override fun onDataSetChanged() {
        val widgetData = HomeWidgetPlugin.getData(context)
        val tasksJson = widgetData.getString("tasks", "[]") ?: "[]"
        println("Widget data received: $tasksJson") // Log pour déboguer
        tasks.clear()
        try {
            val taskList = tasksJson.split("||").filter { it.isNotEmpty() }
            tasks.addAll(taskList.map { task ->
                val parts = task.split("|")
                mapOf(
                    "title" to parts[0],
                    "description" to parts.getOrElse(1) { "" },
                    "isCompleted" to parts.getOrElse(2) { "false" }
                )
            })
        } catch (e: Exception) {
            println("Error parsing tasks: $e") // Log pour erreurs
        }
    }

    override fun onDestroy() {
        tasks.clear()
    }

    override fun getCount(): Int = tasks.size

    override fun getViewAt(position: Int): RemoteViews {
        val task = tasks[position]
        val views = RemoteViews(context.packageName, android.R.layout.simple_list_item_2)
        views.setTextViewText(android.R.id.text1, task["title"])
        views.setTextViewText(android.R.id.text2, task["description"])
        return views
    }

    override fun getLoadingView(): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.task_widget)
        views.setViewVisibility(R.id.widget_task_list, android.view.View.GONE)
        views.setViewVisibility(R.id.empty_view, android.view.View.VISIBLE)
        return views
    }

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true
}