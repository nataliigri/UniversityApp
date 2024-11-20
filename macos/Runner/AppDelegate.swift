import Cocoa
import FlutterMacOS
import Contacts

@main
class AppDelegate: FlutterAppDelegate {
  private var contactStore = CNContactStore()

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ application: NSApplication) -> Bool {
    return true
  }

  // Використовуємо правильний метод для macOS
  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)

    // Отримуємо FlutterViewController
    if let controller = mainFlutterWindow?.contentViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "com.example.contacts", binaryMessenger: controller.engine.binaryMessenger)

      // Вказуємо типи параметрів для замикання
      channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "requestContactsPermission" {
          self?.requestContactsPermission(result: result)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
  }

  // Запит на доступ до контактів
  private func requestContactsPermission(result: @escaping FlutterResult) {
    let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    
    if authorizationStatus == .notDetermined {
      contactStore.requestAccess(for: .contacts) { (granted, error) in
        if granted {
          result(true)
        } else {
          result(false) // Можливо, потрібно надати додаткову інформацію або обробку помилки
        }
      }
    } else if authorizationStatus == .authorized {
      result(true)
    } else {
      result(false) // Якщо відмовлено в доступі, також повертається false
    }
  }
}
