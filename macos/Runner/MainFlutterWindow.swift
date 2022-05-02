import Cocoa
import FlutterMacOS
import flutter_acrylic
import window_manager

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let windowFrame = self.frame
    let blurryContainerViewController = BlurryContainerViewController()
    self.contentViewController = blurryContainerViewController
    self.setFrame(windowFrame, display: true)

    /* Initialize the flutter_acrylic plugin */
    MainFlutterWindowManipulator.start(mainFlutterWindow: self)

    RegisterGeneratedPlugins(registry: blurryContainerViewController.flutterViewController)

    super.awakeFromNib()
  }

  override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
    super.order(place, relativeTo: otherWin)
    hiddenWindowAtLaunch()
  }
}
