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
    
    
    var indexPathToBeDeleted = IndexPath()
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(ColorSetEditViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ColorSetEditViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        initPage()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(colors.count), height: 0)
        
        // Load the initial set of pages that are on screen
        loadVisiblePages()
    }
    
    func loadPage(_ page: Int) {
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
            frame = frame.insetBy(dx: 10.0, dy: 0.0)
            
            let newPageView = UILabel()
            newPageView.clipsToBounds = true
            newPageView.contentMode = .scaleAspectFit
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
        for index in firstPage...lastPage {
            loadPage(index)
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }
    
    @IBAction func doneButtonDidTap(_ sender: AnyObject) {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ColorEditCell
        main.colors[listIndex][0].mainTitle = cell.valueField.text!
        let tmp = main.colors[listIndex][0]
        main.colors[listIndex][0] = main.colors[listIndex][currentPage]
        main.colors[listIndex][currentPage] = tmp
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancleButtonDidTap(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    func keyboardWillShow(_ notification:Notification) {
        adjustingHeight(true, notification: notification)
    }
    
    func keyboardWillHide(_ notification:Notification) {
        adjustingHeight(false, notification: notification)
    }
    
    func adjustingHeight(_ show:Bool, notification:Notification) {
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let changeInHeight = (keyboardFrame.height - 40) * (show ? 1 : -1)
        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
            self.view.layer.position.y -= changeInHeight
        })
    }
}


extension ColorSetEditViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let nibArray = Bundle.main.loadNibNamed("CustomCell", owner: self, options: nil)
            var cell = tableView.dequeueReusableCell(withIdentifier: "EDITCell") as? ColorEditCell
            
            if cell == nil {
                cell = nibArray![5] as? ColorEditCell
            }
            
            cell!.titleLabel.text = titles[indexPath.row]
            cell!.backgroundColor = .clear
            cell!.valueField.text = colors[0].mainTitle
            cell!.valueField.placeholder = "TOUCH TO WRITE NAME"
            return cell!
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.textLabel?.text = "DELETE COLOR SET"
            cell.textLabel?.textColor = UIColor(red:0.94, green:0.33, blue:0.31, alpha:1)
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

extension ColorSetEditViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            main.colors.remove(at: listIndex)
            listView.deleted = true
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}

