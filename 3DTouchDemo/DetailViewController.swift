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

