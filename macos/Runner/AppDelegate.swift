import Carbon.HIToolbox
import Cocoa
import FlutterMacOS
import Foundation
import AVFoundation
import Quartz
// This is required for calling FlutterLocalNotificationsPlugin.setPluginRegistrantCallback method.
// import flutter_local_notifications

@main
class AppDelegate: FlutterAppDelegate {
  var overlayWindow: NSWindow?
  var methodChannel: FlutterMethodChannel?
  // let customTimer = CustomTimer()

  override func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
    return false
  }
  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
      if !flag {
          for window in NSApp.windows {
              if !window.isVisible {
                  window.setIsVisible(true)
              }
              window.makeKeyAndOrderFront(self)
              NSApp.activate(ignoringOtherApps: true)
          }
      }
      return true
  }
  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationWillTerminate(_: Notification) {
    // customTimer.stopTimer()
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    guard let controller = mainFlutterWindow?.contentViewController as? FlutterViewController else {
      fatalError("[Swift] Flutter view controller not found")
    }

    methodChannel = FlutterMethodChannel(name: "com.realk.fluent_gpt", binaryMessenger: controller.engine.binaryMessenger)
    
    // First check if accessibility is already granted without showing prompt
    if !checkAccessibilityPermissions() {
      print("[Swift] please allow accessibility API access to this app.")
      // Only show prompt if permissions are not granted
      requestAccessibilityPermissions()
      // open the accessibility settings in macos
      NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Security.prefPane"))
    }

    setupMethodCallHandler()
    setupEventMonitoring()

    // customTimer.startTimer(interval: 3.0) {
    // print("[Swift] Timer fired")
    // self.methodChannel?.invokeMethod("onTimerFired", arguments: nil)
    // }
    super.applicationDidFinishLaunching(notification)
  }

  func setupMethodCallHandler() {
    methodChannel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }

      switch call.method {
      case "testResultFromSwift":
        result(["Result from Swift": "Hello from Swift"])
      case "getSelectedText":
        getSelectedTextOverrideClipboard { selectedText in
          print("[Swift] Selected text from clipboard: \(selectedText ?? "No text selected")")
          result(selectedText)
        }
        result(nil)
      case "showOverlay":
        self.handleShowOverlay(call: call, result: result)
      case "requestNativePermissions":
        self.requestAccessibilityPermissions()
        result(nil)
      case "requestMicrophonePermissions":
        print("[Swift] requestMicrophonePermissions called")
        self.requestMicrophonePermissions { granted in
        print("[Swift] Permission granted: \(granted)")
        result(granted)
      }
      case "isAccessabilityGranted":
        result(self.checkAccessibilityPermissions())
      case "initAccessibility":
        print("[Swift] initAccessibility called")
        self.handleInitAccessibility(result: result)
      case "getScreenSize":
        self.handleGetScreenSize(result: result)
      case "getMousePosition":
        let cursorPosition = getCurrentCursorPosition()
        result(["positionX": cursorPosition.x, "positionY": cursorPosition.y])
      case "captureActiveScreen":
        if let image = self.captureActiveScreen(),
           let imageData = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: imageData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
          let base64String = pngData.base64EncodedString(options: [])
          result(base64String)
        } else {
          result(FlutterError(code: "UNAVAILABLE", message: "Image conversion failed", details: nil))
        }
      default:
        result("not implemented")
      }
    }
  }
  /// Request mic permission and return result(true) if granted
  func requestMicrophonePermissions(completion: @escaping (Bool) -> Void) {
    let mediaType = AVMediaType.audio
    AVCaptureDevice.requestAccess(for: mediaType) { granted in
        if granted {
            print("[Swift] Microphone permission granted")
        } else {
            print("[Swift] Microphone permission denied")
        }
        completion(granted)
    }
}
  

  func handleShowOverlay(call _: FlutterMethodCall, result: @escaping FlutterResult) {
    // Implementation of showOverlay
    print("[Swift] showOverlay called")
    result(nil)
  }

  /// Handles the initialization of accessibility features.
  /// Checks for accessibility permissions and sets up event monitoring if permissions are granted.
  /// - Parameter result: A closure that returns a dictionary indicating whether accessibility is enabled.
  func handleInitAccessibility(result: @escaping FlutterResult) {
    if checkAccessibilityPermissions() {
      setupEventMonitoring()
      result(["isAccessible": true])
    } else {
      informUserAboutPermissions()
      result(["isAccessible": false])
    }
  }

  func handleGetScreenSize(result: @escaping FlutterResult) {
    let screenFrame = NSScreen.main?.visibleFrame ?? NSRect.zero
    result(["width": screenFrame.width, "height": screenFrame.height])
  }

  func requestAccessibilityPermissions() {
    let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
    AXIsProcessTrustedWithOptions(options)
  }

  func setupEventMonitoring() {
    NSEvent.addGlobalMonitorForEvents(matching: .leftMouseUp) { [weak self] event in
      print("[Swift] leftMouseUp")
      self?.handleMouseUp(event: event)
    }
  }

  func checkAccessibilityPermissions() -> Bool {
    return AXIsProcessTrusted()
  }

  func informUserAboutPermissions() {
    print("[Swift] Accessibility permissions are restricted. Please enable them in System Preferences.")
  }

  func getSelectedTextFromReader() -> String? {
    let focusedElement = AXUIElement.focusedElement
    return focusedElement?.selectedText
  }

  // Function to get current mouse cursor position on screen
  func getCurrentCursorPosition() -> NSPoint {
    let mouseLocation = NSEvent.mouseLocation
    return mouseLocation
  }

  // I should find a better way to get the selected text
  // This method is causing too many unnecessary clipboard changes for each mouse click event
  func getSelectedTextOverrideClipboard(completion: @escaping (String?) -> Void) {
    // Get initial clipboard text
    let initialClipboardText = NSPasteboard.general.readObjects(forClasses: [NSString.self], options: nil)?.first as? String ?? ""

    // Perform the global copy shortcut
    performGlobalCopyShortcut()

    // Define the delay
    let delay = DispatchTime.now() + 0.05

    // Schedule the task with asyncAfter
    DispatchQueue.main.asyncAfter(deadline: delay) {
      // Get the clipboard text after the delay
      let clipboardText = NSPasteboard.general.readObjects(forClasses: [NSString.self], options: nil)?.first as? String ?? ""

      // Restore the original clipboard text if it is not empty or nil
      if !clipboardText.isEmpty {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(initialClipboardText, forType: .string)
      }

      // Call the completion handler with the selected text
      completion(clipboardText)
    }
  }

  func handleMouseUp(event: NSEvent) {
    let cursorPosition = event.locationInWindow
    let nameApp = AXUIElement.focusedElement?.applicationName
    print("[Swift] Cursor position: \(cursorPosition)")
    let focusedElement = AXUIElement.focusedElement
    let selectedText = focusedElement?.selectedText
    print("[Swift] Selected text: \(selectedText ?? "No text selected")")
    // if selectedText is not nil then send it to flutter
    if let selectedText = selectedText {
      methodChannel?.invokeMethod("onTextSelected", arguments: [
        "selectedText": selectedText,
        "positionX": cursorPosition.x,
        "positionY": cursorPosition.y,
        "focusedApp": nameApp ?? "",
      ])
    } else {
      // print("[Swift] No text finded via reader. Trying to get text from clipboard.")
      // getSelectedTextOverrideClipboard { selectedText in
      //   print("[Swift] Selected text from clipboard: \(selectedText ?? "No text selected")")
      //   // if selected text in clipboard is the same as previous

      //   // if selectedText is not nil then send it to flutter
      //   if let selectedText = selectedText {
      //     self.methodChannel?.invokeMethod("onTextSelected", arguments: [
      //       "selectedText": selectedText,
      //       "positionX": cursorPosition.x,
      //       "positionY": cursorPosition.y,
      //       "focusedApp": nameApp ?? "",
      //     ])
      //   }
      // }
    }

    // old code
    // methodChannel?.invokeMethod("onMouseUp", arguments: [
    //   "positionX": cursorPosition.x,
    //   "positionY": cursorPosition.y,
    // ])
  }

  func captureActiveScreen() -> NSImage? {
    // Get the active application
    guard let activeApp = NSWorkspace.shared.frontmostApplication else {
        return nil
    }

    // Get all on-screen windows
    guard let windowListInfo = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as NSArray? as? [[String: Any]] else {
        return nil
    }

    // Find the active window of the active application
    let activeWindows = windowListInfo.filter { windowInfo in
        if let ownerPID = windowInfo[kCGWindowOwnerPID as String] as? pid_t,
           let isOnscreen = windowInfo[kCGWindowIsOnscreen as String] as? Bool,
           isOnscreen,
           ownerPID == activeApp.processIdentifier {
            return true
        }
        return false
    }

    guard let activeWindow = activeWindows.first,
          let boundsDict = activeWindow[kCGWindowBounds as String] as? [String: Any],
          let bounds = CGRect(dictionaryRepresentation: boundsDict as CFDictionary) else {
        return nil
    }

    // Get displays that intersect with the active window's bounds
    let maxDisplays: UInt32 = 16
    var displayCount: UInt32 = 0
    var displays = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))

    let error = CGGetDisplaysWithRect(bounds, maxDisplays, &displays, &displayCount)
    if error == .success, displayCount > 0 {
        // Use the first display that matches
        let displayID = displays[0]

        // Capture the screenshot of the display
        guard let cgImage = CGDisplayCreateImage(displayID) else {
            return nil
        }

        let screenSize = CGSize(width: CGFloat(CGDisplayPixelsWide(displayID)), height: CGFloat(CGDisplayPixelsHigh(displayID)))
        return NSImage(cgImage: cgImage, size: screenSize)
    } else {
        print("No displays found for the active window.")
        return nil
    }
}
}

// Will be removed in the future
func performGlobalCopyShortcut() {
  func keyEvents(forPressAndReleaseVirtualKey virtualKey: Int) -> [CGEvent] {
    let eventSource = CGEventSource(stateID: .hidSystemState)
    return [
      CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: true)!,
      CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: false)!,
    ]
  }

  let tapLocation = CGEventTapLocation.cghidEventTap
  let events = keyEvents(forPressAndReleaseVirtualKey: kVK_ANSI_C)

  for event in events {
    event.flags = .maskCommand
    event.post(tap: tapLocation)
  }
}

class CustomTimer {
  private var timer: Timer?
  private var customFunction: (() -> Void)?

  func startTimer(interval: TimeInterval, customFunction: @escaping () -> Void) {
    self.customFunction = customFunction

    timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
      self?.executeCustomFunction()
    }
  }

  private func executeCustomFunction() {
    customFunction?()
  }

  func stopTimer() {
    timer?.invalidate()
    timer = nil
    customFunction = nil
  }
}

extension AXUIElement {
  // Get the focused element
  static var focusedElement: AXUIElement? {
    systemWide.element(for: kAXFocusedUIElementAttribute)
  }

  // Get the selected text from the focused element
  var selectedText: String? {
    rawValue(for: kAXSelectedTextAttribute) as? String
  }

  // Get the name of the application
  var applicationName: String? {
    element(for: kAXParentAttribute)?.rawValue(for: kAXTitleAttribute) as? String
  }

  private static var systemWide = AXUIElementCreateSystemWide()

  private func element(for attribute: String) -> AXUIElement? {
    guard let rawValue = rawValue(for: attribute), CFGetTypeID(rawValue) == AXUIElementGetTypeID() else { return nil }
    return (rawValue as! AXUIElement)
  }

  private func rawValue(for attribute: String) -> AnyObject? {
    var rawValue: AnyObject?
    let error = AXUIElementCopyAttributeValue(self, attribute as CFString, &rawValue)
    return error == .success ? rawValue : nil
  }
}
