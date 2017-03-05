//
//  ColorSetEditViewController.swift
//  Material
//
//  Created by Truth on 2016. 1. 7..
//  Copyright © 2016년 Truth. All rights reserved.
//

import UIKit

class ColorSetEditViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    var indexPathToBeDeleted = NSIndexPath()
    var listView = ColorListViewController()
    var main = MainViewController()
    var colors = [Color]()
    var cellCount = 10
    var listIndex = 0
    var currentPage = 0
    var pageViews: [UILabel?] = []
    var titles = ["SET NAME"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(
            frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 1)
        )
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ColorSetEditViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ColorSetEditViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        initPage()
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func initPage(){
        let pageCount = colors.count
        
        // Set up the array to hold the views for each page
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        // Set up the content size of the scroll view
        print(scrollView.frame.size)
        scrollView.frame.size = CGSize(width: (self.view.bounds.height - 64) * 0.36, height: ceil((self.view.bounds.height - 64) * 0.36))
        print(CGSize(width: self.view.bounds.width, height: ceil((self.view.bounds.height - 64) * 0.36)))
        
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * CGFloat(colors.count), 0)
        
        // Load the initial set of pages that are on screen
        loadVisiblePages()
    }
    
    func loadPage(page: Int) {
        if page < 0 || page >= colors.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Load an individual page, first checking if you've already loaded it
        if let _ = pageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            frame = CGRectInset(frame, 10.0, 0.0)
            
            let newPageView = UILabel()
            newPageView.clipsToBounds = true
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            newPageView.frame.size.height = newPageView.frame.size.width
            newPageView.layer.cornerRadius = newPageView.frame.size.width / 2
            newPageView.backgroundColor = stringToColor(self.colors[page].RGB)
            
            scrollView.addSubview(newPageView)
            pageViews[page] = newPageView
        }
    }
    
    func loadVisiblePages() {
        // First, determine which page is currently visible
        let pageWidth = (self.view.bounds.height - 64) * 0.36
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width + 0.5)
        currentPage = page
        
        // Set Label
        let color = colors[page]
        self.nameLabel.text = color.title + " " + color.RGB
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Load pages in our range
        for var index = firstPage; index <= lastPage; index += 1 {
            loadPage(index)
        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }
    
    @IBAction func doneButtonDidTap(sender: AnyObject) {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! ColorEditCell
        main.colors[listIndex][0].mainTitle = cell.valueField.text!
        let tmp = main.colors[listIndex][0]
        main.colors[listIndex][0] = main.colors[listIndex][currentPage]
        main.colors[listIndex][currentPage] = tmp
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancleButtonDidTap(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(true, notification: notification)
    }
    
    func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(false, notification: notification)
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let changeInHeight = (CGRectGetHeight(keyboardFrame) - 40) * (show ? 1 : -1)
        UIView.animateWithDuration(animationDurarion, animations: { () -> Void in
            self.view.layer.position.y -= changeInHeight
        })
    }
}


extension ColorSetEditViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let nibArray = NSBundle.mainBundle().loadNibNamed("CustomCell", owner: self, options: nil)
            var cell = tableView.dequeueReusableCellWithIdentifier("EDITCell") as? ColorEditCell
            
            if cell == nil {
                cell = nibArray![5] as? ColorEditCell
            }
            
            cell!.titleLabel.text = titles[indexPath.row]
            cell!.backgroundColor = .clearColor()
            cell!.valueField.text = colors[0].mainTitle
            cell!.valueField.placeholder = "TOUCH TO WRITE NAME"
            return cell!
        } else {
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
            cell.textLabel?.text = "DELETE COLOR SET"
            cell.textLabel?.textColor = UIColor(red:0.94, green:0.33, blue:0.31, alpha:1)
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
            cell.selectionStyle = .None
            cell.backgroundColor = .clearColor()
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
}

extension ColorSetEditViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 1 {
        let alert = UIAlertView(
            title: "WARNING",
            message: "DO YOU REALLY WANT TO DELETE?",
            delegate: self,
            cancelButtonTitle: "CANCLE",
            otherButtonTitles: "OK"
        )
        alert.show()
        }
    }
}


extension ColorSetEditViewController: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            main.colors.removeAtIndex(listIndex)
            listView.deleted = true
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

