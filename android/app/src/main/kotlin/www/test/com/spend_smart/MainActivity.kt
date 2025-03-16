package www.test.com.spend_smart

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.Telephony
import android.content.ContentResolver
import android.util.Log
import android.annotation.SuppressLint
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.spend_smart/native"
    companion object {
        private const val TAG = "MainActivity"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPlatformVersion" -> {
                    Log.i(TAG, "Getting platform version")
                    result.success("Android ${android.os.Build.VERSION.RELEASE}")
                }
                "readSmsTransactions" -> {
                    try {
                        Log.i(TAG, "Starting SMS transaction read operation")
                        val startDate = call.argument<String>("startDate")
                        val endDate = call.argument<String>("endDate")
                        Log.d(TAG, "Date range - Start: $startDate, End: $endDate")
                        val smsMessages = readSmsMessages(startDate, endDate)
                        Log.i(TAG, "Successfully read SMS messages")
                        result.success(smsMessages)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error reading SMS messages", e)
                        result.error("SMS_READ_ERROR", e.message, e.stackTraceToString())
                    }
                }
                else -> {
                    Log.w(TAG, "Method not implemented: ${call.method}")
                    result.notImplemented()
                }
            }
        }
    }

    @SuppressLint("Range")
    private fun readSmsMessages(startDate: String?, endDate: String?): String {
        Log.d(TAG, "Starting SMS read operation")
        Log.d(TAG, "Start date: $startDate")
        Log.d(TAG, "End date: $endDate")

        val jsonArray = JSONArray()
        val contentResolver: ContentResolver = context.contentResolver

        val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS", Locale.getDefault())
        val selection = StringBuilder()
        val selectionArgs = mutableListOf<String>()

        try {
            // Convert startDate and endDate to timestamps (milliseconds)
            val startTime: Long? = startDate?.let {
                try {
                    dateFormat.parse(it)?.time
                } catch (e: Exception) {
                    Log.e(TAG, "Error parsing start date: ${e.message}", e)
                    null
                }
            }

            val endTime: Long? = endDate?.let {
                try {
                    dateFormat.parse(it)?.time
                } catch (e: Exception) {
                    Log.e(TAG, "Error parsing end date: ${e.message}", e)
                    null
                }
            } ?: System.currentTimeMillis()

            // Construct selection query
            when {
                startTime != null && endTime != null -> {
                    selection.append("${Telephony.Sms.DATE} BETWEEN ? AND ?")
                    selectionArgs.add(startTime.toString())
                    selectionArgs.add(endTime.toString())
                    Log.d(TAG, "Query with date range: $startTime to $endTime")
                }
                startTime != null -> {
                    selection.append("${Telephony.Sms.DATE} >= ?")
                    selectionArgs.add(startTime.toString())
                    Log.d(TAG, "Query with start date only: $startTime")
                }
                endTime != null -> {
                    selection.append("${Telephony.Sms.DATE} <= ?")
                    selectionArgs.add(endTime.toString())
                    Log.d(TAG, "Query with end date only: $endTime")
                }
            }

            // Query SMS messages
            Log.d(TAG, "Executing SMS query with selection: ${selection.toString()}")
            val cursor = contentResolver.query(
                Telephony.Sms.CONTENT_URI,
                arrayOf(
                    Telephony.Sms.BODY,
                    Telephony.Sms.ADDRESS,
                    Telephony.Sms.DATE
                ),
                if (selection.isNotEmpty()) selection.toString() else null,
                if (selectionArgs.isNotEmpty()) selectionArgs.toTypedArray() else null,
                "${Telephony.Sms.DATE} DESC"
            )

            cursor?.use {
                Log.i(TAG, "Found ${cursor.count} SMS messages")
                while (it.moveToNext()) {
                    try {
                        val body = it.getString(it.getColumnIndex(Telephony.Sms.BODY)) ?: ""
                        val address = it.getString(it.getColumnIndex(Telephony.Sms.ADDRESS)) ?: ""
                        val date = it.getLong(it.getColumnIndex(Telephony.Sms.DATE))

                        val smsData = JSONObject().apply {
                            put("body", body)
                            put("sender", address)
                            put("date", date)
                        }
                        jsonArray.put(smsData)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error processing SMS message", e)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error reading SMS messages", e)
            throw e
        }

        Log.i(TAG, "Successfully processed ${jsonArray.length()} SMS messages")
        return jsonArray.toString()
    }
}
