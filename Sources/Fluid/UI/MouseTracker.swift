import SwiftUI
import Combine

@MainActor
class MousePositionTracker: ObservableObject {
    @Published var mousePosition: CGPoint = .zero
    @Published var windowFrame: CGRect = .zero
    
    private var lastUpdateTime: TimeInterval = 0
    private let updateInterval: TimeInterval = 1.0/30.0 // 30fps
    
    var relativePosition: CGPoint {
        guard windowFrame.width > 0 && windowFrame.height > 0 else { return .zero }
        return CGPoint(
            x: (mousePosition.x - windowFrame.minX) / windowFrame.width,
            y: (mousePosition.y - windowFrame.minY) / windowFrame.height
        )
    }
    
    func updateMousePosition(_ position: CGPoint) {
        let now = CACurrentMediaTime()
        guard now - lastUpdateTime >= updateInterval else { return }
        
        mousePosition = position
        lastUpdateTime = now
    }
    
    func updateWindowFrame(_ frame: CGRect) {
        windowFrame = frame
    }
}

struct MouseTrackingModifier: ViewModifier {
    let tracker: MousePositionTracker
    
    func body(content: Content) -> some View {
        content
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    // Convert to global coordinates for consistent tracking
                    let globalLocation = CGPoint(
                        x: location.x + (tracker.windowFrame.minX),
                        y: location.y + (tracker.windowFrame.minY)
                    )
                    tracker.updateMousePosition(globalLocation)
                case .ended:
                    break
                }
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            let globalFrame = geometry.frame(in: .global)
                            tracker.updateWindowFrame(globalFrame)
                        }
                        .onChange(of: geometry.frame(in: .global)) { _, newFrame in
                            tracker.updateWindowFrame(newFrame)
                        }
                }
            )
    }
}

extension View {
    func withMouseTracking(_ tracker: MousePositionTracker) -> some View {
        self.modifier(MouseTrackingModifier(tracker: tracker))
    }
}