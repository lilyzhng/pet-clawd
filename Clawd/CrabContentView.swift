import AppKit

class CrabContentView: NSView {
    weak var character: CrabCharacter?
    private var isDragging = false
    private var dragOffset = NSPoint.zero

    override var isFlipped: Bool { false }

    override func hitTest(_ point: NSPoint) -> NSView? {
        if character?.svgRenderer != nil {
            return bounds.contains(point) ? self : nil
        }
        guard let renderer = character?.spriteRenderer else { return nil }
        return renderer.isOpaqueAt(point: point) ? self : nil
    }

    override func mouseDown(with event: NSEvent) {
        if event.modifierFlags.contains(.control) { return }
        isDragging = false
        guard let win = window else { return }
        let screenLoc = NSEvent.mouseLocation
        dragOffset = NSPoint(
            x: screenLoc.x - win.frame.origin.x,
            y: screenLoc.y - win.frame.origin.y
        )
    }

    override func mouseDragged(with event: NSEvent) {
        guard let win = window else { return }
        if !isDragging {
            isDragging = true
            character?.stopForDrag()
        }
        let screenLoc = NSEvent.mouseLocation
        let newOrigin = NSPoint(
            x: screenLoc.x - dragOffset.x,
            y: screenLoc.y - dragOffset.y
        )
        win.setFrameOrigin(newOrigin)
    }

    override func mouseUp(with event: NSEvent) {
        if isDragging {
            isDragging = false
            character?.startFalling()
        } else {
            character?.handleClick()
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        guard let character = character else { return }
        let menu = NSMenu()

        let animMenu = NSMenu()
        for anim in SVGRenderer.allAnimations {
            let item = NSMenuItem(title: anim.label, action: #selector(playSVGAnimation(_:)), keyEquivalent: "")
            item.representedObject = anim.svg
            item.target = self
            animMenu.addItem(item)
        }
        let animItem = NSMenuItem(title: "Animations", action: nil, keyEquivalent: "")
        animItem.submenu = animMenu
        menu.addItem(animItem)

        menu.addItem(NSMenuItem.separator())

        let chatItem = NSMenuItem(title: "Chat", action: #selector(openChat), keyEquivalent: "")
        chatItem.target = self
        menu.addItem(chatItem)

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "")
        quitItem.target = self
        menu.addItem(quitItem)

        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }

    @objc private func playSVGAnimation(_ sender: NSMenuItem) {
        guard let svgName = sender.representedObject as? String else { return }
        character?.svgPinned = true
        character?.svgRenderer?.loadSVG(named: svgName)
    }

    @objc private func openChat() {
        character?.openPopover()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
