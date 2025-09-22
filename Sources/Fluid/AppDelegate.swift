//
//  AppDelegate.swift
//  Fluid
//
//  Created by Barathwaj Anandan on 9/22/25.
//

import AppUpdater
import SwiftUI
import AppKit
import PromiseKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var updater: AppUpdater?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize AppUpdater for automatic updates
        // Repository: https://github.com/altic-dev/Fluid-oss
        updater = AppUpdater(owner: "altic-dev", repo: "Fluid-oss")

        // Request accessibility permissions for global hotkey monitoring
        requestAccessibilityPermissions()

        // Initialize app settings (dock visibility, etc.)
        SettingsStore.shared.initializeAppSettings()

        // Note: App UI is designed with dark color scheme in mind
        // All gradients and effects are optimized for dark mode
    }
    
    // MARK: - Manual Update Check
    @objc func checkForUpdatesManually() {
        guard let updater = updater else {
            DebugLogger.shared.error("AppUpdater not initialized", source: "AppDelegate")
            showUpdateAlert(title: "Update Error", message: "Update system not available")
            return
        }
        
        DebugLogger.shared.info("Manual update check requested", source: "AppDelegate")
        
        updater.check().catch(policy: .allErrors) { error in
            DispatchQueue.main.async {
                if error.isCancelled {
                    // User is already up-to-date
                    DebugLogger.shared.info("App is already up-to-date", source: "AppDelegate")
                    self.showUpdateAlert(title: "No Updates", message: "You're already running the latest version of Fluid!")
                } else {
                    // Handle update error
                    DebugLogger.shared.error("Update check failed: \(error)", source: "AppDelegate")
                    self.showUpdateAlert(title: "Update Check Failed", message: "Unable to check for updates. Please try again later.\n\nError: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showUpdateAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func requestAccessibilityPermissions() {
        // Never show if already trusted
        guard !AXIsProcessTrusted() else { return }

        // Per-session debounce
        if AXPromptState.hasPromptedThisSession { return }

        // Cooldown: avoid re-prompting too often across launches
        let cooldownKey = "AXLastPromptAt"
        let now = Date().timeIntervalSince1970
        let last = UserDefaults.standard.double(forKey: cooldownKey)
        let oneDay: Double = 24 * 60 * 60
        if last > 0 && (now - last) < oneDay {
            return
        }

        DebugLogger.shared.warning("Accessibility permissions required for global hotkeys.", source: "AppDelegate")
        DebugLogger.shared.info("Prompting for Accessibility permission…", source: "AppDelegate")

        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)

        AXPromptState.hasPromptedThisSession = true
        UserDefaults.standard.set(now, forKey: cooldownKey)

        // If still not trusted shortly after, deep-link to the Accessibility pane for convenience
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            guard !AXIsProcessTrusted(),
                  let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
            else { return }
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Session Debounce State
private enum AXPromptState {
    static var hasPromptedThisSession: Bool = false
}
