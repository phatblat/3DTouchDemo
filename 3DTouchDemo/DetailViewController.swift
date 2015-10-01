//
//  DetailViewController.swift
//  3DTouchDemo
//
//  Created by Ben Chatelain on 9/26/15.
//  Copyright © 2015 Ben Chatelain. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet var detailDescriptionLabel: UILabel!

    /// Property to hold the detail item's title.
    var detailItemTitle: String?

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()

        // Set up the detail view's `navigationItem`.
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true
    }

    // MARK: - Private

    private func configureView() {
        if let title = detailItemTitle {
            self.title = title
        }

        // Update the user interface for the detail item.
        if let detail = detailItem {
            detailDescriptionLabel.text = detail.description
        }
    }

}

// MARK: - Action Items for Preview (Peek)

@available(iOS 9.0, *)
extension DetailViewController {

    override func previewActionItems() -> [UIPreviewActionItem] {
        let action1 = UIPreviewAction(title: "Action 1", style: .Default) { (action: UIPreviewAction, vc: UIViewController) -> Void in
            print("Action 1 triggered")
        }

        let selectedAction = UIPreviewAction(title: "Selected Action", style: .Selected) { (action: UIPreviewAction, vc: UIViewController) -> Void in
            print("Selected action triggered")
        }

        let destructiveAction = UIPreviewAction(title: "Destructive Action", style: .Destructive) { (action: UIPreviewAction, vc: UIViewController) -> Void in
            print("Destructive action triggered!")
        }

        let actions = [action1, selectedAction, destructiveAction]

        let group = UIPreviewActionGroup(title: "Action Group", style: .Default, actions: actions)
        
        return [group]
    }
    
}
