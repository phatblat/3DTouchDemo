//
//  MasterViewController.swift
//  3DTouchDemo
//
//  Created by Ben Chatelain on 9/26/15.
//  Copyright © 2015 Ben Chatelain. All rights reserved.
//

import UIKit
import SafariServices

class MasterViewController: UITableViewController {

    // MARK: - Types

    /// A simple data structure to populate the table view.
    struct PreviewDetail {
        let title: String
        let preferredHeight: Double
        let color: UIColor?
    }

    // MARK: - Properties

    /// An alert controller used to notify the user if 3D touch is not available.
    var alertController: UIAlertController?

    var detailViewController: DetailViewController?
    var objects = [AnyObject]()

    let sampleData = [
        PreviewDetail(title: "Small", preferredHeight: 160.0, color: UIColor.yellowColor()),
        PreviewDetail(title: "Medium", preferredHeight: 320.0, color: UIColor.greenColor()),
        PreviewDetail(title: "Large", preferredHeight: 0.0, color: UIColor.blueColor()), // 0.0 to get the default height.
        PreviewDetail(title: "TouchCanvas", preferredHeight: 0.0, color: nil),
        PreviewDetail(title: "ForceProgress", preferredHeight: 0.0, color: nil),
    ]

    let touchCanvasRow = 3

}

// MARK: - UIViewController

extension MasterViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }

        if #available(iOS 9, *) {
            // Check for force touch feature, and add force touch/previewing capability.
            if traitCollection.forceTouchCapability == .Available {
                // Register for `UIViewControllerPreviewingDelegate` to enable "Peek" and "Pop".
                // (see: MasterViewController+UIViewControllerPreviewing.swift)
                //
                // The view controller will be automatically unregistered when it is deallocated.
                registerForPreviewingWithDelegate(self, sourceView: view)
            }
            else {
                // Create an alert to display to the user.
                alertController = UIAlertController(title: "3D Touch Not Available", message: "Unsupported device.", preferredStyle: .Alert)
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Present the alert if necessary.
        if let alertController = alertController {
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)

            // Clear the `alertController` to ensure it's not presented multiple times.
            self.alertController = nil
        }
    }

    // MARK: UIStoryboardSegue Handling

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail", let indexPath = tableView.indexPathForSelectedRow {
            let previewDetail = sampleData[indexPath.row]

            let detailViewController = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController

            // Pass the `title` to the `detailViewController`.
            detailViewController.detailItemTitle = previewDetail.title

            if let color = previewDetail.color {
                detailViewController.view.backgroundColor = color
            }
        }
    }

}

// MARK: - UITableViewDataSource

extension MasterViewController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleData.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let previewDetail = sampleData[indexPath.row]
        cell.textLabel!.text = previewDetail.title

        return cell
    }

}

// MARK: - UITableViewDelegate

extension MasterViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0..<touchCanvasRow:
            performSegueWithIdentifier("showDetail", sender: self)
        case touchCanvasRow:
            performSegueWithIdentifier("touchCanvas", sender: self)
        case touchCanvasRow + 1:
            performSegueWithIdentifier("forceProgress", sender: self)
        default:
            print("Unhandled indexPath \(indexPath)")
        }
    }

}

// MARK: - IBActions

extension MasterViewController {

    /// Removes dynamic quick actions
    @IBAction func didTapTrashButton() {
        if #available(iOS 9.0, *) {
            UIApplication.sharedApplication().shortcutItems = []

            let message = "Dynamic quick actions have been removed"
            print(message)

            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func didTapActionButton(sender: UIBarButtonItem) {
        guard #available(iOS 9.0, *) else { print("Poor you, still on iOS 8. Lemme guess, 16GB model?"); return }

        let safari = SFSafariViewController(URL: NSURL(string: "http://freinbichler.me/apps/3dtouch/")!)
        presentViewController(safari, animated: true, completion: nil)
    }
}

// MARK: - SFSafariViewControllerDelegate

@available(iOS 9, *)
extension MasterViewController: SFSafariViewControllerDelegate {

    func safariViewController(controller: SFSafariViewController, activityItemsForURL URL: NSURL, title: String?) -> [UIActivity] {
        debugPrint("safariViewController:activityItemsForURL:title: \(URL) \(title)")

        return []
    }

    func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        debugPrint("safariViewController:didCompleteInitialLoad: - didLoadSuccessfully: \(didLoadSuccessfully)")
    }

    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        debugPrint("safariViewControllerDidFinish")
    }
}
