package com.example.demo_app

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.content.pm.PackageManager
import android.util.Base64
import android.util.Log
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.aggregate.AggregationResult
import androidx.health.connect.client.request.AggregateRequest
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.records.BloodPressureRecord
import androidx.health.connect.client.records.BodyTemperatureRecord
import androidx.health.connect.client.records.DistanceRecord
import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.records.HeightRecord
import androidx.health.connect.client.records.HydrationRecord
import androidx.health.connect.client.records.OxygenSaturationRecord
import androidx.health.connect.client.records.Record
import androidx.health.connect.client.records.RespiratoryRateRecord
import androidx.health.connect.client.records.SleepSessionRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.records.TotalCaloriesBurnedRecord
import androidx.health.connect.client.records.WeightRecord
import androidx.health.connect.client.records.metadata.DataOrigin
import androidx.health.connect.client.response.ReadRecordsResponse
import androidx.health.connect.client.time.TimeRangeFilter
import androidx.core.app.ActivityCompat
import androidx.lifecycle.lifecycleScope
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch
import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.ZoneId
import java.io.ByteArrayOutputStream
import java.time.temporal.ChronoUnit
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    private val TAG = "HealthConnectBridge"

    private val CHANNEL = "health_connect"

    private var pendingPermissionResult: MethodChannel.Result? = null
    private lateinit var requestedPermissions: Set<String>
    private lateinit var stepsPermission: String

    private val HEALTH_PERMISSION_REQUEST_CODE = 10042

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        requestedPermissions = setOf(
            HealthPermission.getReadPermission(StepsRecord::class),
            HealthPermission.getReadPermission(DistanceRecord::class),
            HealthPermission.getReadPermission(TotalCaloriesBurnedRecord::class),
            HealthPermission.getReadPermission(HeartRateRecord::class),
            HealthPermission.getReadPermission(BloodPressureRecord::class),
            HealthPermission.getReadPermission(OxygenSaturationRecord::class),
            HealthPermission.getReadPermission(RespiratoryRateRecord::class),
            HealthPermission.getReadPermission(BodyTemperatureRecord::class),
            HealthPermission.getReadPermission(SleepSessionRecord::class),
            HealthPermission.getReadPermission(WeightRecord::class),
            HealthPermission.getReadPermission(HeightRecord::class),
            HealthPermission.getReadPermission(HydrationRecord::class)
        )
        stepsPermission = HealthPermission.getReadPermission(StepsRecord::class)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                when (call.method) {
                    "requestHealthPermission" -> openHealthConnect(result)
                    "checkPermission" -> checkPermission(result)
                    "getSteps" -> getSteps(result)
                    "getStepsDebug" -> getStepsDebug(result)
                    "getHealthSummary" -> getHealthSummary(result)
                    "getInstalledHealthApps" -> getInstalledHealthApps(result)
                    "scheduleHealthSyncWork" -> scheduleHealthSyncWork(result)
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Chỉ số theo từng lần đo: ưu tiên bản ghi mới nhất trong hôm nay, không có thì lấy mới nhất trong lịch sử.
     * (Phải là hàm cấp class — Kotlin không hỗ trợ local inline/reified.)
     */
    @Suppress("UNCHECKED_CAST")
    private suspend fun <T : Record> readLatestTodayThenHistory(
        client: HealthConnectClient,
        recordClass: kotlin.reflect.KClass<T>,
        todayRange: TimeRangeFilter,
        allTimeRange: TimeRangeFilter,
        originFilters: List<Set<DataOrigin>>,
        extract: (T) -> Double?,
    ): Double? {
        for (origins in originFilters) {
            val todayReq = ReadRecordsRequest(
                recordClass,
                todayRange,
                origins,
                false,
                1,
                null,
            )
            val todayResp = client.readRecords(todayReq) as ReadRecordsResponse<T>
            val rToday = todayResp.records.firstOrNull() ?: continue
            val v = extract(rToday)
            if (v != null) return v
        }
        for (origins in originFilters) {
            val allReq = ReadRecordsRequest(
                recordClass,
                allTimeRange,
                origins,
                false,
                1,
                null,
            )
            val allResp = client.readRecords(allReq) as ReadRecordsResponse<T>
            val rAll = allResp.records.firstOrNull() ?: continue
            val v = extract(rAll)
            if (v != null) return v
        }
        return null
    }

    private fun getHealthSummary(result: MethodChannel.Result) {
        lifecycleScope.launch {
            try {
                val client = HealthConnectClient.getOrCreate(this@MainActivity)
                val granted = client.permissionController.getGrantedPermissions()
                val zone = ZoneId.systemDefault()
                val startOfDay = LocalDate.now(zone).atStartOfDay(zone).toInstant()
                val now = Instant.now()
                val todayRange = TimeRangeFilter.between(startOfDay, now)
                val allTimeRange = TimeRangeFilter.between(Instant.EPOCH, now)
                val originFilters: List<Set<DataOrigin>> = listOf(
                    emptySet(),
                    setOf(DataOrigin("com.google.android.apps.fitness")),
                    setOf(DataOrigin("com.google.android.apps.fit")),
                    setOf(DataOrigin("com.huawei.health"))
                )

                suspend fun readLatestHeartRate(): Double? {
                    if (!granted.contains(HealthPermission.getReadPermission(HeartRateRecord::class))) return null
                    return readLatestTodayThenHistory(
                        client,
                        HeartRateRecord::class,
                        todayRange,
                        allTimeRange,
                        originFilters,
                    ) { rec ->
                        val sample = rec.samples.lastOrNull()
                        sample?.beatsPerMinute?.toDouble()
                    }
                }

                suspend fun readLatestSpo2(): Double? {
                    if (!granted.contains(HealthPermission.getReadPermission(OxygenSaturationRecord::class))) return null
                    return readLatestTodayThenHistory(
                        client,
                        OxygenSaturationRecord::class,
                        todayRange,
                        allTimeRange,
                        originFilters,
                    ) { rec ->
                        val v = rec.percentage.value
                        if (v > 1 && v <= 100) v else v * 100.0
                    }
                }

                suspend fun readTodayDistanceKm(): Double? {
                    if (!granted.contains(HealthPermission.getReadPermission(DistanceRecord::class))) return null
                    var best: Double? = null
                    for (origins in originFilters) {
                        val request = ReadRecordsRequest(
                            DistanceRecord::class,
                            todayRange,
                            origins,
                            /* ascendingOrder = */ true,
                            /* pageSize = */ 500,
                            /* pageToken = */ null
                        )
                        @Suppress("UNCHECKED_CAST")
                        val response = client.readRecords(request) as ReadRecordsResponse<DistanceRecord>
                        if (response.records.isNotEmpty()) {
                            val total = response.records.sumOf { it.distance.inKilometers }
                            if (best == null || total > best) best = total
                        }
                    }
                    return best
                }

                suspend fun readTodayCalories(): Double? {
                    if (!granted.contains(HealthPermission.getReadPermission(TotalCaloriesBurnedRecord::class))) return null
                    var best: Double? = null
                    for (origins in originFilters) {
                        val request = ReadRecordsRequest(
                            TotalCaloriesBurnedRecord::class,
                            todayRange,
                            origins,
                            /* ascendingOrder = */ true,
                            /* pageSize = */ 500,
                            /* pageToken = */ null
                        )
                        @Suppress("UNCHECKED_CAST")
                        val response = client.readRecords(request) as ReadRecordsResponse<TotalCaloriesBurnedRecord>
                        if (response.records.isNotEmpty()) {
                            val total = response.records.sumOf { it.energy.inKilocalories }
                            if (best == null || total > best) best = total
                        }
                    }
                    return best
                }

                suspend fun readLatestRespiratoryRate(): Double? {
                    if (!granted.contains(HealthPermission.getReadPermission(RespiratoryRateRecord::class))) return null
                    return readLatestTodayThenHistory(
                        client,
                        RespiratoryRateRecord::class,
                        todayRange,
                        allTimeRange,
                        originFilters,
                    ) { it.rate }
                }

                suspend fun readLatestBodyTemp(): Double? {
                    if (!granted.contains(HealthPermission.getReadPermission(BodyTemperatureRecord::class))) return null
                    return readLatestTodayThenHistory(
                        client,
                        BodyTemperatureRecord::class,
                        todayRange,
                        allTimeRange,
                        originFilters,
                    ) { it.temperature.inCelsius }
                }

                suspend fun readLatestBloodPressure(): String? {
                    if (!granted.contains(HealthPermission.getReadPermission(BloodPressureRecord::class))) return null
                    for (origins in originFilters) {
                        val request = ReadRecordsRequest(
                            BloodPressureRecord::class,
                            todayRange,
                            origins,
                            false,
                            1,
                            null,
                        )
                        @Suppress("UNCHECKED_CAST")
                        val response = client.readRecords(request) as ReadRecordsResponse<BloodPressureRecord>
                        val record = response.records.firstOrNull()
                        if (record != null) {
                            val sys = record.systolic.inMillimetersOfMercury.toInt()
                            val dia = record.diastolic.inMillimetersOfMercury.toInt()
                            return "$sys/$dia"
                        }
                    }
                    for (origins in originFilters) {
                        val request = ReadRecordsRequest(
                            BloodPressureRecord::class,
                            allTimeRange,
                            origins,
                            false,
                            1,
                            null,
                        )
                        @Suppress("UNCHECKED_CAST")
                        val response = client.readRecords(request) as ReadRecordsResponse<BloodPressureRecord>
                        val record = response.records.firstOrNull()
                        if (record != null) {
                            val sys = record.systolic.inMillimetersOfMercury.toInt()
                            val dia = record.diastolic.inMillimetersOfMercury.toInt()
                            return "$sys/$dia"
                        }
                    }
                    return null
                }

                suspend fun readTodaySleepMinutes(): Double? {
                    if (!granted.contains(HealthPermission.getReadPermission(SleepSessionRecord::class))) return null
                    var best: Double? = null
                    for (origins in originFilters) {
                        val request = ReadRecordsRequest(
                            SleepSessionRecord::class,
                            todayRange,
                            origins,
                            /* ascendingOrder = */ true,
                            /* pageSize = */ 300,
                            /* pageToken = */ null
                        )
                        @Suppress("UNCHECKED_CAST")
                        val response = client.readRecords(request) as ReadRecordsResponse<SleepSessionRecord>
                        if (response.records.isNotEmpty()) {
                            val totalMinutes = response.records.sumOf { rec ->
                                ChronoUnit.MINUTES.between(rec.startTime, rec.endTime).coerceAtLeast(0)
                            }.toDouble()
                            if (best == null || totalMinutes > best) best = totalMinutes
                        }
                    }
                    return best
                }

                suspend fun readLatestHeightCm(): Double? {
                    if (!granted.contains(HealthPermission.getReadPermission(HeightRecord::class))) return null
                    return readLatestTodayThenHistory(
                        client,
                        HeightRecord::class,
                        todayRange,
                        allTimeRange,
                        originFilters,
                    ) { it.height.inMeters * 100.0 }
                }

                suspend fun readLatestWeightKg(): Double? {
                    if (!granted.contains(HealthPermission.getReadPermission(WeightRecord::class))) return null
                    return readLatestTodayThenHistory(
                        client,
                        WeightRecord::class,
                        todayRange,
                        allTimeRange,
                        originFilters,
                    ) { it.weight.inKilograms }
                }

                suspend fun readTodayHydrationMl(): Double? {
                    if (!granted.contains(HealthPermission.getReadPermission(HydrationRecord::class))) return null
                    var best: Double? = null
                    for (origins in originFilters) {
                        val request = ReadRecordsRequest(
                            HydrationRecord::class,
                            todayRange,
                            origins,
                            /* ascendingOrder = */ true,
                            /* pageSize = */ 500,
                            /* pageToken = */ null
                        )
                        @Suppress("UNCHECKED_CAST")
                        val response = client.readRecords(request) as ReadRecordsResponse<HydrationRecord>
                        if (response.records.isNotEmpty()) {
                            val total = response.records.sumOf { it.volume.inMilliliters }
                            if (best == null || total > best) best = total
                        }
                    }
                    return best
                }

                suspend fun <T> safeRead(key: String, block: suspend () -> T?): T? {
                    return try {
                        block()
                    } catch (e: Exception) {
                        Log.w(TAG, "getHealthSummary failed at $key: ${e.message}")
                        null
                    }
                }

                val summary = mapOf(
                    "steps" to null,
                    "distanceKm" to safeRead("distanceKm") { readTodayDistanceKm() },
                    "caloriesKcal" to safeRead("caloriesKcal") { readTodayCalories() },
                    "heartRateBpm" to safeRead("heartRateBpm") { readLatestHeartRate() },
                    "bloodPressure" to safeRead("bloodPressure") { readLatestBloodPressure() },
                    "spo2Percent" to safeRead("spo2Percent") { readLatestSpo2() },
                    "respiratoryRate" to safeRead("respiratoryRate") { readLatestRespiratoryRate() },
                    "bodyTempC" to safeRead("bodyTempC") { readLatestBodyTemp() },
                    "sleepMinutes" to safeRead("sleepMinutes") { readTodaySleepMinutes() },
                    "heightCm" to safeRead("heightCm") { readLatestHeightCm() },
                    "weightKg" to safeRead("weightKg") { readLatestWeightKg() },
                    "hydrationMl" to safeRead("hydrationMl") { readTodayHydrationMl() }
                )

                result.success(summary)
            } catch (e: Exception) {
                Log.e(TAG, "getHealthSummary error", e)
                result.error("ERROR", e.message, null)
            }
        }
    }

    private fun drawableToBase64(drawable: Drawable, sizePx: Int = 96): String? {
        return try {
            val bitmap = if (drawable is BitmapDrawable) {
                drawable.bitmap
            } else {
                val w = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else sizePx
                val h = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else sizePx
                val bmp = Bitmap.createBitmap(w.coerceAtLeast(sizePx), h.coerceAtLeast(sizePx), Bitmap.Config.ARGB_8888)
                val canvas = Canvas(bmp)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
                bmp
            }
            val scaled = Bitmap.createScaledBitmap(bitmap, sizePx, sizePx, true)
            val stream = ByteArrayOutputStream()
            scaled.compress(Bitmap.CompressFormat.PNG, 90, stream)
            Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
        } catch (e: Exception) {
            Log.w(TAG, "drawableToBase64: ${e.message}")
            null
        }
    }

    private fun getInstalledHealthApps(result: MethodChannel.Result) {
        try {
            val knownHealthPackages = listOf(
                "com.huawei.health" to "Huawei Health",
                "com.sec.android.app.shealth" to "Samsung Health",
                "com.google.android.apps.fitness" to "Google Fit",
                "com.google.android.apps.fit" to "Google Fit",
                "com.xiaomi.hm.health" to "Mi Fit",
                "com.fitbit.FitbitMobile" to "Fitbit",
                "com.garmin.connect.mobile" to "Garmin Connect",
                "com.polar.polarflow" to "Polar Flow",
                "com.strava" to "Strava",
                "com.endomondo.android" to "Endomondo",
                "com.runkeeper.RunKeeper" to "Runkeeper",
                "com.withings.wiscale2" to "Withings",
                "com.omron.health" to "Omron Connect",
                "com.whoop.android" to "WHOOP",
                "com.ouraring.oura" to "Oura",
                "com.samsung.android.app.health" to "Samsung Health",
                "com.nike.plusgps" to "Nike Run Club",
                "com.myfitnesspal.android" to "MyFitnessPal",
                "com.amazfit.zepp" to "Zepp",
                "com.huami.watch.hmwatchmanager" to "Zepp",
                "com.oppo.health" to "Oppo Health",
                "com.oneplus.health" to "OnePlus Health",
                "com.vivo.health" to "vivo Health",
                "com.honor.health" to "Honor Health"
            )

            val huaweiPkg = "com.huawei.health"
            val seen = mutableSetOf<String>()
            val results = mutableListOf<Map<String, Any>>()

            for ((pkg, displayName) in knownHealthPackages) {
                if (pkg in seen) continue
                try {
                    val appInfo = packageManager.getApplicationInfo(pkg, 0)
                    seen.add(pkg)
                    val iconDrawable = packageManager.getApplicationIcon(appInfo)
                    val iconBase64 = drawableToBase64(iconDrawable)
                    val map = mutableMapOf<String, Any>(
                        "name" to displayName,
                        "packageName" to pkg,
                        "supported" to (pkg == huaweiPkg)
                    )
                    if (iconBase64 != null) map["iconBase64"] = iconBase64
                    results.add(map)
                } catch (_: PackageManager.NameNotFoundException) {
                    /* not installed */
                }
            }

            results.sortBy { (it["supported"] as Boolean).not().toString() + (it["name"] as String) }
            result.success(results)
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }

    private fun scheduleHealthSyncWork(result: MethodChannel.Result) {
        try {
            val workRequest = PeriodicWorkRequestBuilder<HealthSyncWorker>(15, TimeUnit.MINUTES)
                .build()
            WorkManager.getInstance(this).enqueueUniquePeriodicWork(
                HealthSyncWorker.WORK_NAME,
                ExistingPeriodicWorkPolicy.KEEP,
                workRequest
            )
            Log.d(TAG, "HealthSyncWork scheduled every 15 min")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "scheduleHealthSyncWork error", e)
            result.error("ERROR", e.message, null)
        }
    }

    // 🔥 REQUEST QUYỀN HEALTH CONNECT (để app được ghi nhận trong màn hình quyền)
    private fun openHealthConnect(result: MethodChannel.Result) {
        Log.d(TAG, "requestHealthPermission called")

        val status = HealthConnectClient.getSdkStatus(this)
        Log.d(TAG, "sdkStatus=$status")

        if (status != HealthConnectClient.SDK_AVAILABLE) {
            Log.e(TAG, "Health Connect not available")
            result.error("NOT_AVAILABLE", "Health Connect chưa sẵn sàng", null)
            return
        }

        pendingPermissionResult = result
        // Trên Android 14+ (SDK 34+), HealthPermissionsRequestContract của thư viện dùng runtime permission.
        // Nên ta request trực tiếp toàn bộ permission Health Connect cần đọc dữ liệu.
        val allPermissions = requestedPermissions.toTypedArray()
        val allGranted = requestedPermissions.all {
            checkSelfPermission(it) == PackageManager.PERMISSION_GRANTED
        }
        Log.d(TAG, "allGrantedBeforeRequest=$allGranted")
        Log.d(TAG, "requestedPermissions=${requestedPermissions.joinToString()}")

        if (allGranted) {
            Log.d(TAG, "All permissions already granted")
            pendingPermissionResult?.success(true)
            pendingPermissionResult = null
            return
        }

        ActivityCompat.requestPermissions(
            this,
            allPermissions,
            HEALTH_PERMISSION_REQUEST_CODE
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode != HEALTH_PERMISSION_REQUEST_CODE) return
        Log.d(TAG, "onRequestPermissionsResult called code=$requestCode")
        Log.d(TAG, "permissions=${permissions.joinToString()}")
        Log.d(TAG, "grantResults=${grantResults.joinToString()}")

        val grantedFromResult = grantResults.isNotEmpty() &&
            grantResults.any { it == PackageManager.PERMISSION_GRANTED }

        val grantedFromCurrentState = requestedPermissions.any { permission ->
            checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
        }

        val granted = grantedFromResult || grantedFromCurrentState
        Log.d(
            TAG,
            "grantedFromResult=$grantedFromResult grantedFromCurrentState=$grantedFromCurrentState finalGranted=$granted"
        )

        pendingPermissionResult?.success(granted)
        pendingPermissionResult = null
    }

    // 🔥 CHECK PERMISSION
    private fun checkPermission(result: MethodChannel.Result) {
        Log.d(TAG, "checkPermission called")
        lifecycleScope.launch {
            try {
                val client = HealthConnectClient.getOrCreate(this@MainActivity)

                val granted = client.permissionController.getGrantedPermissions()
                Log.d(TAG, "grantedPermissionsCount=${granted.size}")
                Log.d(TAG, "grantedPermissions=${granted.joinToString()}")

                val ok = granted.isNotEmpty()
                Log.d(TAG, "checkPermission result=$ok")

                result.success(ok)

            } catch (e: Exception) {
                Log.e(TAG, "checkPermission error", e)
                result.error("ERROR", e.message, null)
            }
        }
    }

    // 🔥 READ STEPS FROM HEALTH CONNECT
    private fun getSteps(result: MethodChannel.Result) {
        lifecycleScope.launch {
            try {
                val client = HealthConnectClient.getOrCreate(this@MainActivity)

                val granted = client.permissionController.getGrantedPermissions()
                val ok = granted.contains(stepsPermission)

                if (!ok) {
                    result.success(0)
                    return@launch
                }

                // Health Connect steps thường được xem theo "ngày local".
                // Đọc từ 00:00 hôm nay đến 00:00 ngày mai để khớp dữ liệu của Fit.
                val localNow = LocalDateTime.now()
                val startOfToday = localNow.toLocalDate().atStartOfDay()
                val startOfTomorrow = startOfToday.plusDays(1)
                val timeRange = TimeRangeFilter.between(startOfToday, startOfTomorrow)

                suspend fun aggregateStepsCount(origins: Set<DataOrigin>): Long {
                    val metrics = setOf(StepsRecord.COUNT_TOTAL)
                    val request = androidx.health.connect.client.request.AggregateRequest(
                        metrics,
                        timeRange,
                        origins
                    )

                    val agg =
                        client.aggregate(request) as AggregationResult

                    val v: Long? =
                        agg.get(StepsRecord.COUNT_TOTAL)
                    return v ?: 0L
                }

                // Lấy theo aggregate (COUNT_TOTAL) thay vì cộng từ readRecords để tránh double count.
                var totalSteps = aggregateStepsCount(emptySet())

                // Nếu empty filter chưa trả gì (tùy máy/device), thử theo từng origin và lấy max.
                if (totalSteps == 0L) {
                    val candidateFitOrigins = listOf(
                        "com.google.android.apps.fitness",
                        "com.google.android.apps.fit"
                    )
                    for (pkg in candidateFitOrigins) {
                        val v = aggregateStepsCount(setOf(DataOrigin(pkg)))
                        if (v > totalSteps) totalSteps = v
                    }
                }

                result.success(totalSteps.toInt())
            } catch (e: Exception) {
                result.error("ERROR", e.message, null)
            }
        }
    }

    // 🔥 READ STEPS + DEBUG (để biết vì sao trả 0)
    private fun getStepsDebug(result: MethodChannel.Result) {
        lifecycleScope.launch {
            try {
                val client = HealthConnectClient.getOrCreate(this@MainActivity)

                val granted = client.permissionController.getGrantedPermissions()
                val permissionOk = granted.contains(stepsPermission)

                if (!permissionOk) {
                    result.success(
                        mapOf(
                            "steps" to 0,
                            "debug" to "permissionOk=false (missing $stepsPermission)"
                        )
                    )
                    return@launch
                }

                val localNow = LocalDateTime.now()
                val startOfToday = localNow.toLocalDate().atStartOfDay()
                val startOfTomorrow = startOfToday.plusDays(1)

                val nowInstant = Instant.now()
                val last7dStart = nowInstant.minus(7, ChronoUnit.DAYS)

                val candidateFitOrigins = listOf(
                    "com.google.android.apps.fitness",
                    "com.google.android.apps.fit"
                )

                val timeRanges: List<Pair<String, TimeRangeFilter>> = listOf(
                    "todayLocal" to TimeRangeFilter.between(startOfToday, startOfTomorrow),
                    "last7DaysUTC" to TimeRangeFilter.between(last7dStart, nowInstant)
                )

                val originFilters: List<Pair<String, Set<DataOrigin>>> = listOf(
                    "emptyFilter" to emptySet(),
                    *candidateFitOrigins.map { pkg ->
                        "origin($pkg)" to setOf(DataOrigin(pkg))
                    }.toTypedArray()
                )

                suspend fun readStepsAndCount(
                    timeRange: TimeRangeFilter,
                    origins: Set<DataOrigin>
                ): Pair<Long, Int> {
                    val request = ReadRecordsRequest(
                        StepsRecord::class,
                        timeRange,
                        origins,
                        /* ascendingOrder = */ true,
                        /* pageSize = */ 100,
                        /* pageToken = */ null
                    )

                    @Suppress("UNCHECKED_CAST")
                    val response = client.readRecords(request) as ReadRecordsResponse<StepsRecord>
                    val sum = response.records.sumOf { it.count }
                    return Pair(sum, response.records.size)
                }

                suspend fun aggregateStepsCount(
                    timeRange: TimeRangeFilter,
                    origins: Set<DataOrigin>
                ): Long {
                    val metrics = setOf(StepsRecord.COUNT_TOTAL)
                    val request = AggregateRequest(
                        metrics,
                        timeRange,
                        origins
                    )

                    val agg =
                        client.aggregate(request) as AggregationResult

                    return if (agg.contains(StepsRecord.COUNT_TOTAL)) {
                        val v: Long? = agg.get(StepsRecord.COUNT_TOTAL)
                        v ?: 0L
                    } else {
                        0L
                    }
                }

                var bestSteps = 0L
                val debugParts = mutableListOf<String>()
                debugParts.add("permissionOk=true")

                for ((rangeName, range) in timeRanges) {
                    for ((originName, origins) in originFilters) {
                        try {
                            val (sum, count) = readStepsAndCount(range, origins)
                            debugParts.add("range=$rangeName origins=$originName records=$count sum=$sum")
                        } catch (e: Exception) {
                            debugParts.add(
                                "range=$rangeName origins=$originName EX=${e.javaClass.simpleName}:${e.message}"
                            )
                        }

                        try {
                            val aggCount = aggregateStepsCount(range, origins)
                            debugParts.add("range=$rangeName origins=$originName AGG_COUNT=$aggCount")
                            // UI đang hiển thị "Số bước hôm nay" => chỉ lấy kết quả của range todayLocal.
                            if (rangeName == "todayLocal" && aggCount > bestSteps) {
                                bestSteps = aggCount
                            }
                        } catch (e: Exception) {
                            debugParts.add(
                                "range=$rangeName origins=$originName AGG_EX=${e.javaClass.simpleName}:${e.message}"
                            )
                        }
                    }
                }

                result.success(
                    mapOf(
                        "steps" to bestSteps.toInt(),
                        "debug" to debugParts.joinToString("\n")
                    )
                )
            } catch (e: Exception) {
                result.error("ERROR", e.toString(), null)
            }
        }
    }
}