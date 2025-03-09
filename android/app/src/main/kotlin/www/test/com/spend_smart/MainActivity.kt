package www.test.com.spend_smart

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.test.com.spend_smart.FlutterSmsInboxPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterSmsInboxPluginRegistrant.registerWith(flutterEngine.plugins)
    }
}