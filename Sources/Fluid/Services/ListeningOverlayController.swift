import AppKit

final class ListeningOverlayController
{
    private var panel: NSPanel?
    private var asrService: ASRService

    init(asrService: ASRService)
    {
        self.asrService = asrService
    }

    func show(with view: NSView)
    {
        if panel == nil
        {
            let style: NSWindow.StyleMask = [.borderless, .nonactivatingPanel]
            let p = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 280, height: 80),
                            styleMask: style,
                            backing: .buffered,
                            defer: false)
            p.level = .statusBar
            p.isOpaque = false
            p.hasShadow = true
            p.hidesOnDeactivate = false
            p.ignoresMouseEvents = true
            p.collectionBehavior = [.canJoinAllSpaces, .transient, .fullScreenAuxiliary]
            p.backgroundColor = .clear
            p.titleVisibility = .hidden
            p.titlebarAppearsTransparent = true
            panel = p
        }
        panel?.contentView = view
        positionCenteredLower()
        panel?.orderFrontRegardless()
    }

    func hide()
    {
        panel?.orderOut(nil)
    }

    private func activeScreen() -> NSScreen?
    {
        if let key = NSApp.keyWindow?.screen { return key }
        if let mouse = NSScreen.screens.first(where: { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) }) { return mouse }
        return NSScreen.main
    }

    private func positionCenteredLower()
    {
        guard let screen = activeScreen(), let panel else { return }
        let visible = screen.visibleFrame
        panel.layoutIfNeeded()
        let size = panel.frame.size
        let centerX = visible.midX - size.width / 2
        let bottomPadding: CGFloat = 140
        let yPosition = visible.minY + bottomPadding
        panel.setFrameOrigin(NSPoint(x: centerX.rounded(), y: yPosition.rounded()))
    }
}


