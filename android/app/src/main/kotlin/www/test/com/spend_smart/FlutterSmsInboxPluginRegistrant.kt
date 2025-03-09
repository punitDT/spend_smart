package www.test.com.spend_smart

import com.juliusgithaiga.flutter_sms_inbox.FlutterSmsInboxPlugin
import io.flutter.plugins.PluginRegistry

object FlutterSmsInboxPluginRegistrant {
    fun registerWith(registry: PluginRegistry) {
        if (!registry.hasPlugin("com.juliusgithaiga.flutter_sms_inbox.FlutterSmsInboxPlugin")) {
            FlutterSmsInboxPlugin.registerWith(registry)
        }
    }
}