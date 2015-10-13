//
//  MasterViewController.swift
//  3DTouchDemo
//
//  Created by Ben Chatelain on 9/28/15.
//  Copyright © 2015 Ben Chatelain. All rights reserved.
//

import UIKit

extension MasterViewController: UIViewControllerPreviewingDelegate {

    // MARK: - UIViewControllerPreviewingDelegate

    /// Create a previewing view controller to be shown as a "Peek".
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // Obtain the index path and the cell that was pressed.
        guard let indexPath = tableView.indexPathForRowAtPoint(location),
                  cell = tableView.cellForRowAtIndexPath(indexPath) else { return nil }

        if #available(iOS 9, *) {
            // Set the source rect to the cell frame, so surrounding elements are blurred.
            previewingContext.sourceRect = cell.frame
        }

        return viewControllerForIndexPath(indexPath)
    }
    
    /// Present the view controller for the "Pop" action.
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        // Reuse the "Peek" view controller for presentation.
        showViewController(viewControllerToCommit, sender: self)
    }

}

extension MasterViewController {

    private func viewControllerForIndexPath(indexPath: NSIndexPath) -> UIViewController? {
        switch indexPath.row {
        case 0..<touchCanvasRow:
            // Create a detail view controller and set its properties.
            guard let detailViewController = storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as? DetailViewController else { return nil }

            let previewDetail = sampleData[indexPath.row]
            detailViewController.detailItemTitle = previewDetail.title

            // Set the height of the preview by setting the preferred content size of the detail view controller.
            // Width should be zero, because it's not used in portrait.
            detailViewController.preferredContentSize = CGSize(width: 0.0, height: previewDetail.preferredHeight)

            return detailViewController

        case touchCanvasRow:
            return storyboard?.instantiateViewControllerWithIdentifier("TouchCanvasViewController")

        case touchCanvasRow + 1:
            return storyboard?.instantiateViewControllerWithIdentifier("ForceProgressViewController")

        default:
            return nil
        }
    }

}
