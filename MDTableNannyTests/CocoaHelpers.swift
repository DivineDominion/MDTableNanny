import Cocoa

func forceLoadWindowController(controller: NSWindowController) {

    _ = controller.window
}

func forceLoadViewController(controller: NSViewController) {

    _ = controller.view
}

func button(button: NSButton?, isWiredToAction action: String, withTarget target: AnyObject?) -> Bool {

    return button?.action == Selector(action) && button?.target === target
}
