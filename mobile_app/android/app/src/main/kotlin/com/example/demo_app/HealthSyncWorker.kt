package com.example.demo_app

import android.content.Context
import android.util.Log
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.aggregate.AggregationResult
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.records.metadata.DataOrigin
import androidx.health.connect.client.request.AggregateRequest
import androidx.health.connect.client.time.TimeRangeFilter
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.time.LocalDateTime

/**
 * Worker chạy nền định kỳ: đọc dữ liệu từ Health Connect và cache vào SharedPreferences.
 * Dùng để sync/update khi user không mở app.
 */
class HealthSyncWorker(
    private val appContext: Context,
    params: WorkerParameters,
) : CoroutineWorker(appContext, params) {

    companion object {
        private const val TAG = "HealthSyncWorker"
        const val WORK_NAME = "HealthSyncWork"
        const val PREF_STEPS = "health_sync_steps"
        const val PREF_TS = "health_sync_ts"
    }

    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        try {
            if (HealthConnectClient.getSdkStatus(appContext) != HealthConnectClient.SDK_AVAILABLE) {
                Log.w(TAG, "Health Connect not available")
                return@withContext Result.failure()
            }

            val client = HealthConnectClient.getOrCreate(appContext)
            val granted = client.permissionController.getGrantedPermissions()
            val stepsPermission = HealthPermission.getReadPermission(StepsRecord::class)

            if (!granted.contains(stepsPermission)) {
                Log.d(TAG, "No steps permission granted")
                return@withContext Result.success()
            }

            val localNow = LocalDateTime.now()
            val startOfToday = localNow.toLocalDate().atStartOfDay()
            val startOfTomorrow = startOfToday.plusDays(1)
            val timeRange = TimeRangeFilter.between(startOfToday, startOfTomorrow)

            val metrics = setOf(StepsRecord.COUNT_TOTAL)
            var totalSteps = 0L

            try {
                val request = AggregateRequest(metrics, timeRange, emptySet())
                val agg = client.aggregate(request) as AggregationResult
                totalSteps = agg.get(StepsRecord.COUNT_TOTAL) ?: 0L
            } catch (_: Exception) {}

            if (totalSteps == 0L) {
                for (pkg in listOf("com.google.android.apps.fitness", "com.google.android.apps.fit")) {
                    try {
                        val request = AggregateRequest(metrics, timeRange, setOf(DataOrigin(pkg)))
                        val agg = client.aggregate(request) as AggregationResult
                        val v = agg.get(StepsRecord.COUNT_TOTAL) ?: 0L
                        if (v > totalSteps) totalSteps = v
                    } catch (_: Exception) {}
                }
            }

            appContext.getSharedPreferences("health_sync", Context.MODE_PRIVATE)
                .edit()
                .putInt(PREF_STEPS, totalSteps.toInt())
                .putLong(PREF_TS, System.currentTimeMillis())
                .apply()

            Log.d(TAG, "Synced steps=$totalSteps")
            Result.success()
        } catch (e: Exception) {
            Log.e(TAG, "HealthSyncWorker error", e)
            Result.failure()
        }
    }
}
