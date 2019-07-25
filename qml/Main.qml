import Felgo 3.0
import QtQuick 2.0

App {
  // You get free licenseKeys from https://felgo.com/licenseKey
  // With a licenseKey you can:
  //  * Publish your games & apps for the app stores
  //  * Remove the Felgo Splash Screen or set a custom one (available with the Pro Licenses)
  //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)
  //licenseKey: "<generate one from https://felgo.com/licenseKey>"

  onInitTheme: {
//    Theme.colors.tintColor = "#a4c639"
//    Theme.navigationBar.titleTextSize = sp(20)
  }

  NavigationStack {

    ScannerPage {
      title: "Qr Scan"
    }
  }
}
