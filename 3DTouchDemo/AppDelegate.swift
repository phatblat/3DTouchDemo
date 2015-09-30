//
//  AppDelegate.swift
//  3DTouchDemo
//
//  Created by Ben Chatelain on 9/26/15.
//  Copyright © 2015 Ben Chatelain. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    enum ShortcutIdentifier: String {
        case Static
        case Hyperdrive
        case Third
        case Fourth

        // MARK: Initializers

        init?(fullType: String) {
            guard let last = fullType.componentsSeparatedByString(".").last else { return nil }

            self.init(rawValue: last)
        }

        // MARK: Properties

        var type: String {
            return NSBundle.mainBundle().bundleIdentifier! + ".\(rawValue)"
        }
    }

    // MARK: Static Properties

    static let applicationShortcutUserInfoIconKey = "applicationShortcutUserInfoIconKey"

    // MARK: Properties

    var window: UIWindow?

    /// Saved shortcut item used as a result of an app launch, used later when app is activated.
    //    @available(iOS 9, *)
//    var launchedShortcutItem: UIApplicationShortcutItem?
    var launchedShortcutItem: AnyObject?

    // MARK: - App Lifecycle

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Split view expand button
        let splitViewController = window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self

        // Override point for customization after application launch.
        var shouldPerformAdditionalDelegateHandling = true

        if #available(iOS 9, *) {
            // If a shortcut was launched, display its information and take the appropriate action
            if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {

                launchedShortcutItem = shortcutItem

                // This will block "performActionForShortcutItem:completionHandler" from being called.
                shouldPerformAdditionalDelegateHandling = false
            }

            // Install initial versions of our two extra dynamic shortcuts.
            if let shortcutItems = application.shortcutItems where shortcutItems.isEmpty {
                // Construct the items.
                let shortcut3 = UIMutableApplicationShortcutItem(type: ShortcutIdentifier.Third.type, localizedTitle: "Play", localizedSubtitle: "Will Play an item", icon: UIApplicationShortcutIcon(type: .Play), userInfo: [
                    AppDelegate.applicationShortcutUserInfoIconKey: UIApplicationShortcutIconType.Play.rawValue
                    ]
                )

                let shortcut4 = UIMutableApplicationShortcutItem(type: ShortcutIdentifier.Fourth.type, localizedTitle: "Pause", localizedSubtitle: "Will Pause an item", icon: UIApplicationShortcutIcon(type: .Pause), userInfo: [
                    AppDelegate.applicationShortcutUserInfoIconKey: UIApplicationShortcutIconType.Pause.rawValue
                    ]
                )

                // Update the application providing the initial 'dynamic' shortcut items.
                application.shortcutItems = [shortcut3, shortcut4]
            }
        }

        return shouldPerformAdditionalDelegateHandling
    }

    func applicationDidBecomeActive(application: UIApplication) {
        guard let shortcut = launchedShortcutItem else { return }

        if #available(iOS 9, *) {
            guard let shortcut = shortcut as? UIApplicationShortcutItem else { return }
            handleShortCutItem(shortcut)
        }

        launchedShortcutItem = nil
    }

    /// Called when the user activates your application by selecting a shortcut on the home screen, except when
    /// application(_:,willFinishLaunchingWithOptions:) or application(_:didFinishLaunchingWithOptions) returns `false`.
    /// You should handle the shortcut in those callbacks and return `false` if possible. In that case, this
    /// callback is used if your application is already launched in the background.
    @available(iOS 9, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: Bool -> Void) {
        let handledShortCutItem = handleShortCutItem(shortcutItem)

        completionHandler(handledShortCutItem)
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

    // MARK: - Private

    @available(iOS 9, *)
    private func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var handled = false

        // Verify that the provided `shortcutItem`'s `type` is one handled by the application.
        guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }

        guard let shortCutType = shortcutItem.type as String? else { return false }

        switch (shortCutType) {
        case ShortcutIdentifier.Static.type:
            // Handle shortcut 1 (static).
            handled = true
            break
        case ShortcutIdentifier.Hyperdrive.type:
            // Handle shortcut 2 (static).
            handled = true
            break
        case ShortcutIdentifier.Third.type:
            // Handle shortcut 3 (dynamic).
            handled = true
            break
        case ShortcutIdentifier.Fourth.type:
            // Handle shortcut 4 (dynamic).
            handled = true
            break
        default:
            break
        }

        // Construct an alert using the details of the shortcut used to open the application.
        let alertController = UIAlertController(title: "Shortcut Handled", message: "\"\(shortcutItem.localizedTitle)\"", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)

        // Display an alert indicating the shortcut selected from the home screen.
        window!.rootViewController?.presentViewController(alertController, animated: true, completion: nil)

        return handled
    }

}

