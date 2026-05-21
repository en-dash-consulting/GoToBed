import Foundation

/// App version + distribution URLs, read from the bundle Info.plist (populated
/// from the git tag at package time by build-app.sh). Falls back to "dev" when
/// run as a bare `swift run` executable with no bundle.
enum AppInfo {
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "dev"
    }

    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
    }

    /// GitHub releases (latest) — where the downloadable builds live. Opened by
    /// "Check for Updates…".
    static let releasesURL = URL(string: "https://github.com/en-dash-consulting/GoToBed/releases/latest")!

    /// Public download/landing site.
    static let websiteURL = URL(string: "https://gotobed.endash.us")!
}
