import Flutter
import UIKit
import GoogleSignIn
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Work
    // GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "721583416673-da6ad404dc2neh83r68ldoqrsov5v4pm.apps.googleusercontent.com")
    GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "792758347753-85shfp2g1r283jn7t7e3qk7vbs3bkbr6.apps.googleusercontent.com")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }
}
