//
//  fluidApp.swift
//  fluid
//
//  Created by Barathwaj Anandan on 7/30/25.
//

import SwiftUI
import AppKit
import ApplicationServices

@main
struct fluidApp: App {
    @StateObject private var menuBarManager = MenuBarManager()
    
    init() {
        // Request accessibility permissions for global hotkey monitoring
        requestAccessibilityPermissions()

        // Initialize app settings (dock visibility, etc.)
        SettingsStore.shared.initializeAppSettings()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(menuBarManager)
        }
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

        DebugLogger.shared.warning("Accessibility permissions required for global hotkeys.", source: "fluidApp")
        DebugLogger.shared.info("Prompting for Accessibility permission…", source: "fluidApp")

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
