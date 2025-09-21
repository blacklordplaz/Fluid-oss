# Error Handling Guide

This document outlines the comprehensive error handling strategy used in Fluid, ensuring robust operation across various failure scenarios.

## Overview

Fluid implements a multi-layered error handling approach:

1. **Silent Failures**: Non-critical operations that fail gracefully
2. **User Notifications**: Important errors that require user attention
3. **Debug Logging**: Detailed error information for troubleshooting
4. **Recovery Mechanisms**: Automatic error recovery where possible

## Error Categories

### 1. Permission Errors

#### Microphone Access
```swift
func requestMicAccess() {
    AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
        Task { @MainActor in
            self?.micStatus = granted ? .authorized : .denied
            if !granted {
                // Show user notification about microphone access
                self?.showMicPermissionError()
            }
        }
    }
}
```

**Handling Strategy:**
- Request permission on first use
- Provide clear instructions for manual permission granting
- Gracefully disable features that require microphone access
- Show helpful error messages with links to System Settings

#### Accessibility Permissions
```swift
private func requestAccessibilityPermissions() {
    guard !AXIsProcessTrusted() else { return }

    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
    AXIsProcessTrustedWithOptions(options)

    // Deep link to Accessibility settings if still not trusted
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
        guard !AXIsProcessTrusted(),
              let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
        else { return }
        NSWorkspace.shared.open(url)
    }
}
```

**Handling Strategy:**
- Request permissions during app initialization
- Provide automatic deep-linking to System Settings
- Show clear error messages explaining why permissions are needed
- Disable hotkey functionality if permissions are denied

### 2. Audio Processing Errors

#### Audio Engine Failures
```swift
func startEngine() throws {
    var attempts = 0
    while attempts < 3 {
        do {
            try engine.start()
            return
        } catch {
            attempts += 1
            Thread.sleep(forTimeInterval: 0.1)
            engine.reset()
        }
    }
    throw NSError(domain: "ASRService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to start audio engine"])
}
```

**Handling Strategy:**
- Retry mechanism with exponential backoff
- Automatic engine reset on failures
- Clear error messages for user feedback
- Graceful degradation of functionality

#### Device Detection Errors
```swift
private func handleDefaultInputChanged() {
    if isRunning {
        removeEngineTap()
        engine.stop()
        do {
            try configureSession()
            try startEngine()
            setupEngineTap()
        } catch {
            // Log error but don't show to user - audio should continue working
            DebugLogger.shared.warning("Failed to restart audio engine after device change: \(error)", source: "ASRService")
        }
    }
}
```

**Handling Strategy:**
- Silent recovery attempts
- Detailed logging for debugging
- No user interruption during recovery

### 3. Model Management Errors

#### Download Failures
```swift
func ensureModelsPresent(at targetRoot: URL, onProgress: ((Double, String) -> Void)? = nil) async throws {
    try FileManager.default.createDirectory(at: targetRoot, withIntermediateDirectories: true)

    var pendingFiles: [String] = []
    for item in requiredItems() {
        // Check existing files and build download list
        // ... implementation details ...
    }

    // Download with progress tracking and error handling
    for (idx, rel) in pendingFiles.enumerated() {
        try await downloadFile(relativePath: rel, to: targetRoot.appendingPathComponent(rel)) { perFilePct in
            // Progress callback with error handling
        }
    }
}
```

**Handling Strategy:**
- Comprehensive progress tracking
- Detailed error reporting
- Automatic retry for network failures
- Clear user feedback about download status

#### Model Loading Errors
```swift
func ensureAsrReady() async throws {
    if isAsrReady == false {
        do {
            // Download models if needed
            let downloader = HuggingFaceModelDownloader()
            try await downloader.ensureModelsPresent(at: cacheDir) { progress, item in
                DispatchQueue.main.async {
                    self.isDownloadingModel = progress < 1.0
                    self.modelDownloadProgress = max(0.0, min(1.0, progress))
                }
            }

            // Load models with error handling
            let models = try await downloader.loadLocalAsrModels(from: cacheDir)

            if self.asrManager == nil {
                self.asrManager = AsrManager(config: ASRConfig(realtimeMode: false))
            }

            if let manager = self.asrManager {
                try await manager.initialize(models: models)
            }

            isAsrReady = true
        } catch {
            DebugLogger.shared.error("ASR initialization failed: \(error)", source: "ASRService")
            throw error
        }
    }
}
```

**Handling Strategy:**
- Detailed error logging with context
- Proper error propagation
- User-friendly error messages
- Graceful fallback when models can't be loaded

### 4. Text Injection Errors

#### Accessibility API Failures
```swift
private func tryAllTextInsertionMethods(_ element: AXUIElement, _ text: String) -> Bool {
    // Try multiple approaches for text insertion
    if setTextViaValue(element, text) {
        return true
    }

    if setTextViaSelection(element, text) {
        return true
    }

    if insertTextAtInsertionPoint(element, text) {
        return true
    }

    return false
}
```

**Handling Strategy:**
- Multiple fallback strategies
- Detailed logging for each attempt
- Graceful degradation when insertion fails
- User notification for repeated failures

#### CGEvent Failures
```swift
private func insertTextBulkInstant(_ text: String) -> Bool {
    guard let event = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true) else {
        DebugLogger.shared.error("Failed to create bulk CGEvent", source: "TypingService")
        return false
    }

    let utf16Array = Array(text.utf16)
    event.keyboardSetUnicodeString(stringLength: utf16Array.count, unicodeString: utf16Array)
    event.post(tap: .cghidEventTap)

    return true
}
```

**Handling Strategy:**
- Fallback to character-by-character typing
- Detailed error logging
- No user interruption for failed attempts

## Error Recovery Mechanisms

### Automatic Recovery
- **Audio Device Changes**: Automatic restart of audio engine
- **Network Failures**: Retry mechanism for model downloads
- **Permission Changes**: Automatic reinitialization when permissions granted

### User-Initiated Recovery
- **Retry Buttons**: For failed operations
- **Manual Configuration**: Settings for troubleshooting
- **Diagnostic Tools**: Debug mode with detailed logging

## User Feedback Strategy

### Error Messages
```swift
// Example error message format
"Unable to access microphone. Please grant microphone permission in System Settings → Privacy & Security → Microphone, then restart Fluid."
```

### Visual Indicators
- **Progress Bars**: For long-running operations
- **Status Icons**: Color-coded status indicators
- **Toast Notifications**: Non-intrusive error messages
- **Loading States**: Clear indication of operation status

### Debug Information
- **Console Logs**: Detailed technical information
- **Debug Settings**: Enable/disable debug features
- **Export Logs**: Ability to export logs for support

## Best Practices

### 1. Fail Gracefully
```swift
do {
    try riskyOperation()
} catch {
    // Log detailed error information
    DebugLogger.shared.error("Operation failed: \(error)", source: "Component")

    // Show user-friendly message
    showUserFriendlyError()

    // Attempt recovery if possible
    attemptRecovery()
}
```

### 2. Provide Context
```swift
DebugLogger.shared.error("ASR transcription failed during model initialization", source: "ASRService")
```

### 3. Use Appropriate Error Levels
- **Debug**: Detailed technical information
- **Info**: General operational information
- **Warning**: Non-critical issues that should be addressed
- **Error**: Critical failures requiring attention

### 4. Recovery Mechanisms
```swift
func attemptRecovery() {
    // Retry with backoff
    // Fallback to alternative approach
    // Disable problematic features gracefully
}
```

## Testing Error Scenarios

### Unit Tests
- Test error handling for all major components
- Verify recovery mechanisms work correctly
- Test with mocked dependencies

### Integration Tests
- Test with real hardware (microphones, displays)
- Verify accessibility API behavior
- Test network failure scenarios

### Manual Testing
- Test with denied permissions
- Simulate network failures
- Test with various audio environments
- Verify error messages are helpful

## Conclusion

Fluid's error handling strategy ensures a robust, user-friendly experience by:

1. **Graceful Degradation**: Features fail gracefully without crashing
2. **Clear Communication**: Users understand what went wrong and how to fix it
3. **Automatic Recovery**: Many issues resolve themselves automatically
4. **Detailed Debugging**: Developers have comprehensive information for troubleshooting
5. **User Control**: Advanced users can access diagnostic tools and detailed logs

This approach balances technical robustness with user experience, making Fluid reliable for both casual and professional users.
