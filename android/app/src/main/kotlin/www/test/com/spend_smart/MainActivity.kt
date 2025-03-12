package www.test.com.spend_smart

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.Telephony
import android.content.ContentResolver
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.spend_smart/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPlatformVersion" -> {
                    result.success("Android ${android.os.Build.VERSION.RELEASE}")
                }
                "readSmsTransactions" -> {
                    try {
                        val smsMessages = readSmsMessages()
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

    private fun readSmsMessages(): String {
        val jsonArray = JSONArray()
        val contentResolver: ContentResolver = context.contentResolver
        val cursor = contentResolver.query(
            Telephony.Sms.CONTENT_URI,
            arrayOf(
                Telephony.Sms.BODY,
                Telephony.Sms.ADDRESS,
                Telephony.Sms.DATE
            ),
            null,
            null,
            "date DESC"
        )

        cursor?.use {
            val bodyIndex = it.getColumnIndex(Telephony.Sms.BODY)
            val addressIndex = it.getColumnIndex(Telephony.Sms.ADDRESS)
            val dateIndex = it.getColumnIndex(Telephony.Sms.DATE)
            val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())

            while (it.moveToNext()) {
                val body = it.getString(bodyIndex)
                val address = it.getString(addressIndex)
                val date = it.getLong(dateIndex)

                // Parse transaction details from SMS body
                val transactionDetails = parseTransactionFromSms(body)
                if (transactionDetails != null) {
                    val smsJson = JSONObject().apply {
                        put("body", body)
                        put("sender", address)
                        put("date", dateFormat.format(Date(date)))
                        put("amount", transactionDetails.first)
                        put("type", transactionDetails.second)
                    }
                    jsonArray.put(smsJson)
                }
            }
        }

        return jsonArray.toString()
    }

    private fun parseTransactionFromSms(body: String): Pair<Double, String>? {
        // This is a basic implementation - you might want to enhance this based on your bank's SMS format
        val amountPattern = Regex("(?i)(?:RS|INR|₹).?\\s*(\\d+(?:[.,]\\d{2})?)")
        val debitKeywords = listOf("debited", "withdrawn", "spent", "paid", "debit")
        val creditKeywords = listOf("credited", "received", "credit")

        val amountMatch = amountPattern.find(body)
        if (amountMatch != null) {
            val amount = amountMatch.groupValues[1].replace(",", "").toDoubleOrNull()
            if (amount != null) {
                val type = when {
                    debitKeywords.any { body.lowercase().contains(it) } -> "debit"
                    creditKeywords.any { body.lowercase().contains(it) } -> "credit"
                    else -> return null
                }
                return Pair(amount, type)
            }
        }
        return null
    }
}
