import AppKit
import Combine

@MainActor
final class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private var menu: NSMenu?
    
    // References to app state
    private weak var asrService: ASRService?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isRecording: Bool = false
    @Published var aiProcessingEnabled: Bool = false
    
    init() {
        setupMenuBar()
        // Initialize from persisted setting
        aiProcessingEnabled = SettingsStore.shared.enableAIProcessing
        // Reflect changes to menu when toggled from elsewhere (e.g., General tab)
        $aiProcessingEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateMenu()
            }
            .store(in: &cancellables)
    }
    
    deinit {
        statusItem = nil
    }
    
    func configure(asrService: ASRService) {
        self.asrService = asrService
        
        // Subscribe to recording state changes
        asrService.$isRunning
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRunning in
                self?.isRecording = isRunning
                self?.updateMenuBarIcon()
                self?.updateMenu()
            }
            .store(in: &cancellables)
        
        // Subscribe to AI processing state
        aiProcessingEnabled = SettingsStore.shared.enableAIProcessing
    }
    
    private func setupMenuBar() {
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        guard let statusItem = statusItem else { return }
        
        // Set initial icon
        updateMenuBarIcon()
        
        // Create menu
        menu = NSMenu()
        statusItem.menu = menu
        
        updateMenu()
    }
    
    private func updateMenuBarIcon() {
        guard let statusItem = statusItem else { return }
        
        // Use custom F icon instead of microphone
        let image = createFluidIcon(isRecording: isRecording)
        
        statusItem.button?.image = image
        statusItem.button?.imagePosition = .imageOnly
    }
    
    private func createFluidIcon(isRecording: Bool) -> NSImage {
        let size = NSSize(width: 16, height: 16)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Create F shape path
        let path = NSBezierPath()
        let lineWidth: CGFloat = 2.0
        
        // F shape coordinates (scaled to 16x16)
        let leftX: CGFloat = 2
        let rightX: CGFloat = 12
        let topY: CGFloat = 14
        let bottomY: CGFloat = 2
        let middleY: CGFloat = 8.5
        
        // Vertical line (left side of F)
        path.move(to: NSPoint(x: leftX, y: bottomY))
        path.line(to: NSPoint(x: leftX, y: topY))
        
        // Top horizontal line (full width)
        path.line(to: NSPoint(x: rightX, y: topY))
        
        // Middle horizontal line
        path.move(to: NSPoint(x: leftX, y: middleY))
        path.line(to: NSPoint(x: rightX - 2, y: middleY))
        
        // Set color based on recording state
        let color = isRecording ? NSColor.systemRed : NSColor.controlAccentColor
        color.set()
        
        path.lineWidth = lineWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.stroke()
        
        image.unlockFocus()
        image.isTemplate = true
        
        return image
    }
    
    private func updateMenu() {
        guard let menu = menu else { return }
        
        menu.removeAllItems()
        
        // Status indicator
        let statusTitle = isRecording ? "Recording..." : "Ready to Record"
        let statusItem = NSMenuItem(title: statusTitle, action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        menu.addItem(statusItem)
        
        menu.addItem(.separator())
        
        // Start/Stop Recording
        let recordingAction = isRecording ? "Stop Recording" : "Start Recording"
        let recordingItem = NSMenuItem(title: recordingAction, action: #selector(toggleRecording), keyEquivalent: "")
        recordingItem.target = self
        
        // Show hotkey if available
        let hotkeyShortcut = SettingsStore.shared.hotkeyShortcut
        recordingItem.keyEquivalent = "" // We'll show it in the title instead
        if !hotkeyShortcut.displayString.isEmpty {
            recordingItem.title = "\(recordingAction) (\(hotkeyShortcut.displayString))"
        }
        
        menu.addItem(recordingItem)
        
        // AI Processing Toggle
        let aiTitle = aiProcessingEnabled ? "Disable AI Processing" : "Enable AI Processing"
        let aiItem = NSMenuItem(title: aiTitle, action: #selector(toggleAIProcessing), keyEquivalent: "")
        aiItem.target = self
        menu.addItem(aiItem)
        
        menu.addItem(.separator())
        
        // Open Main Window
        let openItem = NSMenuItem(title: "Open Fluid", action: #selector(openMainWindow), keyEquivalent: "")
        openItem.target = self
        menu.addItem(openItem)
        
        // Check for Updates
        let updateItem = NSMenuItem(title: "Check for Updates...", action: #selector(checkForUpdates), keyEquivalent: "")
        updateItem.target = self
        menu.addItem(updateItem)
        
        menu.addItem(.separator())
        
        // Quit
        let quitItem = NSMenuItem(title: "Quit Fluid", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.target = NSApp
        menu.addItem(quitItem)
    }
    
    @objc private func toggleRecording() {
        guard let asrService = asrService else { return }
        
        if isRecording {
            Task {
                _ = await asrService.stop()
            }
        } else {
            asrService.start()
        }
    }
    
    @objc private func toggleAIProcessing() {
        aiProcessingEnabled.toggle()
        // Persist and broadcast change
        SettingsStore.shared.enableAIProcessing = aiProcessingEnabled
        // If a ContentView has bound to MenuBarManager, its onChange sync will mirror this
        updateMenu()
    }
    
    @objc private func checkForUpdates() {
        // Call the AppDelegate's manual update check method
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.checkForUpdatesManually()
        }
    }
    
    @objc private func openMainWindow() {
        // First, unhide the app if it's hidden
        if NSApp.isHidden {
            NSApp.unhide(nil)
        }
        
        // Activate the app and bring it to the front
        NSApp.activate(ignoringOtherApps: true)
        
        // Find and restore the main window
        var foundWindow = false
        for window in NSApp.windows {
            if window.title.contains("Fluid") || window.isMainWindow || window.contentView != nil {
                // Handle minimized windows
                if window.isMiniaturized {
                    window.deminiaturize(nil)
                }
                
                // Bring to current space and make key
                window.makeKeyAndOrderFront(nil)
                window.orderFrontRegardless()
                foundWindow = true
                break
            }
        }
        
        // If no window found, try to activate any available window
        if !foundWindow && !NSApp.windows.isEmpty {
            if let firstWindow = NSApp.windows.first {
                if firstWindow.isMiniaturized {
                    firstWindow.deminiaturize(nil)
                }
                firstWindow.makeKeyAndOrderFront(nil)
                firstWindow.orderFrontRegardless()
                foundWindow = true
            }
        }
        
        // Final attempt: ensure app is active and visible
        if foundWindow {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
