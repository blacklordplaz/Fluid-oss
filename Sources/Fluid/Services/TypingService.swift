import Foundation
import AppKit

final class TypingService
{
    private var isCurrentlyTyping = false
    
    func typeTextInstantly(_ text: String)
    {
        print("[TypingService] ENTRY: typeTextInstantly called with text length: \(text.count)")
        print("[TypingService] Text preview: \"\(String(text.prefix(100)))\"")
        
        guard text.isEmpty == false else { 
            print("[TypingService] ERROR: Empty text provided, aborting")
            return 
        }
        
        // Prevent concurrent typing operations
        guard !isCurrentlyTyping else {
            print("[TypingService] WARNING: Skipping text injection - already in progress")
            return
        }
        
        // Check accessibility permissions first
        guard AXIsProcessTrusted() else {
            print("[TypingService] ERROR: Accessibility permissions required for text injection")
            print("[TypingService] Current accessibility status: \(AXIsProcessTrusted())")
            return
        }

        print("[TypingService] Accessibility check passed, proceeding with text injection")
        isCurrentlyTyping = true
        
        DispatchQueue.global(qos: .userInitiated).async
        {
            defer { 
                self.isCurrentlyTyping = false 
                print("[TypingService] Typing operation completed, isCurrentlyTyping set to false")
            }
            
            print("[TypingService] Starting async text insertion process")
            // Longer delay to ensure target app is ready and focused
            usleep(200000) // 200ms delay - more reliable for app switching
            print("[TypingService] Delay completed, calling insertTextInstantly")
            self.insertTextInstantly(text)
        }
    }

    private func insertTextInstantly(_ text: String)
    {
        print("[TypingService] insertTextInstantly called with \(text.count) characters")
        print("[TypingService] Attempting to type text: \"\(text.prefix(50))\(text.count > 50 ? "..." : "")\"")
        
        // Get frontmost app info
        if let frontApp = NSWorkspace.shared.frontmostApplication {
            print("[TypingService] Target app: \(frontApp.localizedName ?? "Unknown") (\(frontApp.bundleIdentifier ?? "Unknown"))")
        } else {
            print("[TypingService] WARNING: Could not get frontmost application")
        }
        
        // Check if we have permission to create events
        print("[TypingService] Accessibility trusted: \(AXIsProcessTrusted())")
        
        // Try direct bulk CGEvent insertion (NO CLIPBOARD)
        print("[TypingService] Trying INSTANT bulk CGEvent insertion (no clipboard)")
        if insertTextBulkInstant(text) {
            print("[TypingService] SUCCESS: Instant bulk CGEvent completed")
        } else {
            print("[TypingService] FAILED: Bulk CGEvent, trying character-by-character")
            // Fallback to character-by-character if bulk fails
            for (index, char) in text.enumerated() {
                if index % 10 == 0 {  // Log every 10th character to avoid spam
                    print("[TypingService] Typing character \(index+1)/\(text.count): '\(char)'")
                }
                typeCharacter(char)
                usleep(1000) // Small delay between characters (1ms)
            }
            
            print("[TypingService] Character-by-character typing completed")
        }
    }
    
    private func insertTextBulkInstant(_ text: String) -> Bool {
        print("[TypingService] Starting INSTANT bulk CGEvent insertion (NO CLIPBOARD)")
        
        // Create single CGEvent with entire text - truly instant
        guard let event = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true) else {
            print("[TypingService] ERROR: Failed to create bulk CGEvent")
            return false
        }
        
        // Convert entire text to UTF16
        let utf16Array = Array(text.utf16)
        print("[TypingService] Converting \(text.count) characters to single CGEvent")
        
        // Set the entire text as unicode string
        event.keyboardSetUnicodeString(stringLength: utf16Array.count, unicodeString: utf16Array)
        
        // Post single event - INSTANT insertion
        event.post(tap: .cghidEventTap)
        print("[TypingService] Posted single CGEvent with entire text - INSTANT!")
        
        return true
    }
    
    private func insertTextViaAccessibility(_ text: String) -> Bool {
        print("[TypingService] Starting Accessibility API insertion")
        
        // Try multiple strategies to find text input element
        
        // Strategy 1: Get focused element directly
        print("[TypingService] Strategy 1: Getting focused UI element...")
        if let textElement = getFocusedTextElement() {
            print("[TypingService] Found focused text element")
            if tryAllTextInsertionMethods(textElement, text) {
                return true
            }
        }
        
        // Strategy 2: Traverse frontmost app UI hierarchy to find text elements
        print("[TypingService] Strategy 2: Traversing app UI hierarchy...")
        if let textElement = findTextElementInFrontmostApp() {
            print("[TypingService] Found text element in app hierarchy")
            if tryAllTextInsertionMethods(textElement, text) {
                return true
            }
        }
        
        // Strategy 3: Find element with keyboard focus
        print("[TypingService] Strategy 3: Looking for keyboard focus...")
        if let textElement = findKeyboardFocusedElement() {
            print("[TypingService] Found keyboard focused element")
            if tryAllTextInsertionMethods(textElement, text) {
                return true
            }
        }
        
        print("[TypingService] All Accessibility API strategies failed")
        return false
    }
    
    private func getFocusedTextElement() -> AXUIElement? {
        let systemWideElement = AXUIElementCreateSystemWide()
        var focusedElement: CFTypeRef?
        
        let result = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        
        if result == .success, let element = focusedElement {
            let axElement = element as! AXUIElement
            if let role = getElementAttribute(axElement, kAXRoleAttribute as CFString) {
                print("[TypingService] Found focused element with role: \(role)")
                return axElement
            }
        } else {
            print("[TypingService] Could not get focused UI element - result: \(result.rawValue)")
        }
        
        return nil
    }
    
    private func findTextElementInFrontmostApp() -> AXUIElement? {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            print("[TypingService] Could not get frontmost app")
            return nil
        }
        
        let appElement = AXUIElementCreateApplication(frontmostApp.processIdentifier)
        return findTextElementRecursively(appElement, depth: 0, maxDepth: 8)
    }
    
    private func findTextElementRecursively(_ element: AXUIElement, depth: Int, maxDepth: Int) -> AXUIElement? {
        if depth > maxDepth { return nil }
        
        // Check if this element is a text input element
        if let role = getElementAttribute(element, kAXRoleAttribute as CFString) {
            let textRoles = ["AXTextField", "AXTextArea", "AXComboBox", "AXSearchField", "AXStaticText"]
            if textRoles.contains(role) {
                print("[TypingService] Found text element at depth \(depth) with role: \(role)")
                return element
            }
        }
        
        // Get children and search recursively
        var children: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &children)
        
        if result == .success, let childrenArray = children as? [AXUIElement] {
            for child in childrenArray.prefix(10) { // Limit to first 10 children per level
                if let found = findTextElementRecursively(child, depth: depth + 1, maxDepth: maxDepth) {
                    return found
                }
            }
        }
        
        return nil
    }
    
    private func findKeyboardFocusedElement() -> AXUIElement? {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else { return nil }
        
        let appElement = AXUIElementCreateApplication(frontmostApp.processIdentifier)
        var focusedElement: CFTypeRef?
        
        let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        
        if result == .success, let element = focusedElement {
            let axElement = element as! AXUIElement
            if let role = getElementAttribute(axElement, kAXRoleAttribute as CFString) {
                print("[TypingService] Found app-level focused element with role: \(role)")
                return axElement
            }
        }
        
        return nil
    }
    
    private func tryAllTextInsertionMethods(_ element: AXUIElement, _ text: String) -> Bool {
        // Get element info for debugging
        if let role = getElementAttribute(element, kAXRoleAttribute as CFString) {
            print("[TypingService] Trying insertion on element with role: \(role)")
            
            if let title = getElementAttribute(element, kAXTitleAttribute as CFString) {
                print("[TypingService] Element title: \(title)")
            }
        }
        
        // Try multiple approaches for text insertion
        print("[TypingService] Trying approach 1: Direct kAXValueAttribute")
        if setTextViaValue(element, text) {
            return true
        }
        
        print("[TypingService] Trying approach 2: kAXSelectedTextAttribute (replace selection)")
        if setTextViaSelection(element, text) {
            return true
        }
        
        print("[TypingService] Trying approach 3: Insert text at insertion point")
        if insertTextAtInsertionPoint(element, text) {
            return true
        }
        
        return false
    }
    
    private func getElementAttribute(_ element: AXUIElement, _ attribute: CFString) -> String? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute, &value)
        if result == .success, let stringValue = value as? String {
            return stringValue
        }
        return nil
    }
    //Why is it working now? And why is it not working now?
    private func setTextViaValue(_ element: AXUIElement, _ text: String) -> Bool {
        let cfText = text as CFString
        let result = AXUIElementSetAttributeValue(element, kAXValueAttribute as CFString, cfText)
        
        if result == .success {
            print("[TypingService] SUCCESS: Set text via kAXValueAttribute")
            return true
        } else {
            print("[TypingService] FAILED: kAXValueAttribute - error: \(result.rawValue)")
            return false
        }
    }
    
    private func setTextViaSelection(_ element: AXUIElement, _ text: String) -> Bool {
        // First, select all existing text
        let selectAllResult = AXUIElementSetAttributeValue(element, kAXSelectedTextAttribute as CFString, "" as CFString)
        print("[TypingService] Select all result: \(selectAllResult.rawValue)")
        
        // Then replace the selection with our text
        let cfText = text as CFString
        let result = AXUIElementSetAttributeValue(element, kAXSelectedTextAttribute as CFString, cfText)
        
        if result == .success {
            print("[TypingService] SUCCESS: Set text via kAXSelectedTextAttribute")
            return true
        } else {
            print("[TypingService] FAILED: kAXSelectedTextAttribute - error: \(result.rawValue)")
            return false
        }
    }
    
    private func insertTextAtInsertionPoint(_ element: AXUIElement, _ text: String) -> Bool {
        // Try to get the insertion point
        var insertionPoint: CFTypeRef?
        let getResult = AXUIElementCopyAttributeValue(element, kAXInsertionPointLineNumberAttribute as CFString, &insertionPoint)
        print("[TypingService] Get insertion point result: \(getResult.rawValue)")
        
        // Try to insert text using parameterized attribute
        let cfText = text as CFString
        let result = AXUIElementSetAttributeValue(element, kAXValueAttribute as CFString, cfText)
        
        if result == .success {
            print("[TypingService] SUCCESS: Inserted text at insertion point")
            return true
        } else {
            print("[TypingService] FAILED: Insertion point method - error: \(result.rawValue)")
            return false
        }
    }
    
    private func insertTextBulk(_ text: String) -> Bool {
        print("[TypingService] Starting bulk CGEvent insertion")
        
        // Get the frontmost application's PID for targeted event posting
        guard let frontApp = NSWorkspace.shared.frontmostApplication else {
            print("[TypingService] ERROR: Could not get frontmost application for bulk insertion")
            return false
        }
        
        let targetPID = frontApp.processIdentifier
        print("[TypingService] Targeting PID \(targetPID) for bulk insertion")
        
        // Try word-by-word insertion instead of entire text at once (faster than char-by-char but more reliable than bulk)
        let words = text.components(separatedBy: " ")
        print("[TypingService] Splitting text into \(words.count) words for bulk insertion")
        
        for (index, word) in words.enumerated() {
            let wordToType = word + (index < words.count - 1 ? " " : "") // Add space except for last word
            
            if !insertWordViaCGEvent(wordToType, targetPID: targetPID) {
                print("[TypingService] Failed to insert word \(index + 1): '\(word)', falling back to character method")
                return false
            }
            
            if index % 5 == 0 && index > 0 {
                print("[TypingService] Bulk insertion progress: \(index + 1)/\(words.count) words")
            }
        }
        
        print("[TypingService] Successfully completed bulk word-by-word insertion")
        return true
    }
    
    private func insertWordViaCGEvent(_ word: String, targetPID: pid_t) -> Bool {
        // Convert word to UTF16 for CGEvent
        let utf16Array = Array(word.utf16)
        
        // Create keyboard event for this word
        guard let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true),
              let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: false) else {
            print("[TypingService] ERROR: Failed to create CGEvents for word: '\(word)'")
            return false
        }
        
        // Set the unicode string for both events
        keyDownEvent.keyboardSetUnicodeString(stringLength: utf16Array.count, unicodeString: utf16Array)
        keyUpEvent.keyboardSetUnicodeString(stringLength: utf16Array.count, unicodeString: utf16Array)
        
        // Post events to specific PID
        keyDownEvent.postToPid(targetPID)
        usleep(2000) // 2ms delay between keyDown and keyUp
        keyUpEvent.postToPid(targetPID)
        
        return true
    }
    
    private func typeCharacter(_ char: Character) {
        let charString = String(char)
        let utf16Array = Array(charString.utf16)
        
        // Create keyboard events for this character
        guard let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true),
              let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: false) else {
            if UserDefaults.standard.bool(forKey: "enableDebugLogs") {
                print("[TypingService] ERROR: Failed to create CGEvents for character: \(char)")
            }
            return
        }
        
        // Set the unicode string for both events
        keyDownEvent.keyboardSetUnicodeString(stringLength: utf16Array.count, unicodeString: utf16Array)
        keyUpEvent.keyboardSetUnicodeString(stringLength: utf16Array.count, unicodeString: utf16Array)
        
        // Post the events
        keyDownEvent.post(tap: .cghidEventTap)
        usleep(2000) // Short delay between key down and up (2ms)
        keyUpEvent.post(tap: .cghidEventTap)
    }
}


