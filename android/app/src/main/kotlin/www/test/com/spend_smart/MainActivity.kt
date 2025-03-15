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
                    result.success("Android ${android.os.Build.VERSION.RELEASE}")
                }
                "readSmsTransactions" -> {
                    try {
                        val startDate = call.argument<String>("startDate")
                        val endDate = call.argument<String>("endDate")
                        val smsMessages = readSmsMessages(startDate, endDate)
                        result.success(smsMessages)
                    } catch (e: Exception) {
                        result.error("SMS_READ_ERROR", e.message, null)
                    }
                }
                else -> {
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
        } ?: System.currentTimeMillis() // Default to current time if endDate is null

        // Construct selection query
        when {
            startTime != null && endTime != null -> {
                selection.append("${Telephony.Sms.DATE} BETWEEN ? AND ?")
                selectionArgs.add(startTime.toString())
                selectionArgs.add(endTime.toString())
            }
            startTime != null -> {
                selection.append("${Telephony.Sms.DATE} >= ?")
                selectionArgs.add(startTime.toString())
            }
            endTime != null -> {
                selection.append("${Telephony.Sms.DATE} <= ?")
                selectionArgs.add(endTime.toString())
            }
        }

        // Query SMS messages
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
            while (it.moveToNext()) {
                val body = it.getString(it.getColumnIndex(Telephony.Sms.BODY)) ?: ""
                val address = it.getString(it.getColumnIndex(Telephony.Sms.ADDRESS)) ?: ""
                val date = it.getLong(it.getColumnIndex(Telephony.Sms.DATE))

                val smsData = JSONObject().apply {
                    put("body", body)
                    put("sender", address)
                    put("date", date)
                }
                jsonArray.put(smsData)
            }
        }

        return jsonArray.toString()
    }


}
