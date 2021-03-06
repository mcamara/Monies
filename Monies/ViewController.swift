//
//  ViewController.swift
//  Monies
//
//  Created by Daniel Green on 05/06/2014.
//  Copyright (c) 2014 Daniel Green. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource, WebViewDriverProgressDelegate, HalifaxDriverDelegate {

    let halifax = (UIApplication.sharedApplication().delegate as! AppDelegate).halifax
    var accounts = HalifaxAccount.allObjects()
    @IBOutlet var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        halifax.delegate = self
        halifax.halifaxDelegate = self
        self.view.addSubview(halifax.webview)
        halifax.webview.hidden = true
        halifax.loadAccounts()
    }
    
    func webViewDriverProgress(progress: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = progress
    }
    
    func halifaxDriverAccountAdded(account: HalifaxAccount) {
        refresh()
    }
    
    func halifaxDriverLoadedPage(page: String) {
        toggleWebButton.title = page
    }
    
    override func viewWillAppear(animated: Bool) {
        self.refresh()
    }
    
    override func viewWillDisappear(animated: Bool) {
        webViewDriverProgress(false)
    }
    
    func refresh() {
        accounts = HalifaxAccount.allObjects()
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(accounts.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! AccountTableViewCell
        let account = accounts.objectAtIndex(UInt(indexPath.row)) as! HalifaxAccount
        cell.setContentForAccount(account)
        return cell
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        sizeWebView()
    }
    
    // Probably should use constraints here...
    func sizeWebView() {
        let top = self.tableView.contentInset.top
        let height = self.view.frame.height - top
        halifax.webview.frame = CGRect(x: 0, y: top, width: self.view.frame.width, height: height)
    }
    
    @IBOutlet var toggleWebButton : UIBarButtonItem!
    
    @IBAction func toggleWeb(sender : UIBarButtonItem) {
        if halifax.webview.hidden {
            halifax.webview.hidden = false
            tableView.hidden = true
            halifax.drive = false
            sizeWebView()
        } else {
            halifax.loadAccounts()
            halifax.webview.hidden = true
            tableView.hidden = false
            halifax.drive = true
        }
    }
}

