//
//  WebViewController.swift
//  3DTouchDemo
//
//  Created by Ben Chatelain on 10/5/15.
//  Copyright © 2015 Ben Chatelain. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    let url = NSURL(string: "http://freinbichler.me/apps/3dtouch/")!

    let webView: WKWebView

    required init?(coder aDecoder: NSCoder) {
        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRectZero, configuration: configuration)

        super.init(coder: aDecoder)

        webView.navigationDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = view.frame
        view.addSubview(webView)
//        webView.translatesAutoresizingMaskIntoConstraints = false
//
//        let views = ["view": view, "webView": webView]
//
//        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[webView]|", options: .AlignAllCenterY, metrics: nil, views: views))
//        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|", options: .AlignAllCenterX, metrics: nil, views: views))

        print("webView added \(webView)")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        print("loading url: \(url)")
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }

}

extension WebViewController: WKNavigationDelegate {

    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation")
    }

    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        print("didFinishNavigation")
    }

}
