import Foundation

// cannot call UIApplication openURL from inside an extension, so bounce the OAuth
// URLOpening through this


public protocol GithubURLOpener {
    func openURL(_ url: URL)
}
