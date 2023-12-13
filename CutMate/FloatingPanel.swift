import Foundation
import AppKit
import Cocoa

class FloatingPanel: NSPanel {
    init(contentRect: NSRect, backing: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: [.nonactivatingPanel, .titled, .resizable, .closable, .fullSizeContentView], backing: backing, defer: flag)

        self.isFloatingPanel = true
        self.level = .floating

        self.collectionBehavior.insert(.fullScreenAuxiliary)

        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true

        self.isMovableByWindowBackground = true

        self.isReleasedWhenClosed = false

        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true

        self.contentMinSize = NSSize(width: 400, height: 500)
        self.minSize = NSSize(width: 400, height: 500)
    }

    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }
}
