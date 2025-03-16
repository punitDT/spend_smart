import UIKit
import Flutter
import os.log

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let logger = OSLog(subsystem: "com.spend_smart", category: "AppDelegate")
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let platformChannel = FlutterMethodChannel(
      name: "com.spend_smart/native",
      binaryMessenger: controller.binaryMessenger)
    
    platformChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard let self = self else { return }
      
      switch call.method {
      case "getPlatformVersion":
        os_log("Getting platform version", log: self.logger, type: .info)
        result("iOS " + UIDevice.current.systemVersion)
        
      default:
        os_log("Method not implemented: %{public}@", log: self.logger, type: .error, call.method)
        result(FlutterMethodNotImplemented)
      }
    })
    
    os_log("Application finished launching", log: logger, type: .info)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
