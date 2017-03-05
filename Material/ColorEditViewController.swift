//
//  ColorEditViewController.swift
//  Material
//
//  Created by Truth on 2016. 1. 4..
//  Copyright © 2016년 Truth. All rights reserved.
//

import UIKit

class ColorEditViewController: UIViewController {
    @IBOutlet weak var colorSelectButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hexField: UITextField!
    
    var main = MainViewController()
    var listIndex = 0
    var subIndex = 0
    var color = Color()
    var titles = ["COLOR NAME", "MEMO"]
    var isKeyboardShowing = false
    var ishexTouched = false
    
    let nameRow = 0
    let memoRow = 1
    
    @IBAction func cancleButtonDidTap(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonDidTap(sender: AnyObject) {
        let nameCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: nameRow, inSection: 0)) as! ColorEditCell
        let memoCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: memoRow, inSection: 0)) as! ColorEditCell
        
        main.colors[listIndex][subIndex].title = nameCell.valueField.text!
        main.colors[listIndex][subIndex].memo = memoCell.valueField.text!
        main.colors[listIndex][subIndex].RGB = self.hexField.text!
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(
            frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 1)
        )
        self.hexField.text = color.RGB
        self.hexField.tintColor = .whiteColor()
        self.hexField.delegate = self
        self.hexField.addTarget(self, action: #selector(ColorEditViewController.didChangedHexText(_:)), forControlEvents: .EditingChanged)
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.hexField.becomeFirstResponder()
        }
        
        self.colorSelectButton.layer.cornerRadius = (0.35 * (self.view.frame.height - 64)) / 2
        self.colorSelectButton.clipsToBounds = true
        self.colorSelectButton.backgroundColor = stringToColor(color.RGB)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ColorEditViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ColorEditViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ColorEditViewController.handleTap(_:)))
        self.view!.addGestureRecognizer(tap)
    }
    
    func didChangedHexText(textField: UITextField) {
        if textField.text?.characters.first != "#" {
            textField.text = "#" + textField.text!
        }
        if textField.text?.characters.count > 7 {
            textField.deleteBackward()
        }
        textField.text = textField.text?.uppercaseString
        self.colorSelectButton.backgroundColor = stringToColor(textField.text!)
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(notification:NSNotification) {
        if isKeyboardShowing == false{
            if !ishexTouched {
                adjustingHeight(true, notification: notification)
            }
            isKeyboardShowing = true
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        print(self.view.layer.position.y)
        if isKeyboardShowing == true{
            if !ishexTouched {
                adjustingHeight(false, notification: notification)
            }
            ishexTouched = false
            isKeyboardShowing = false
        }
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

extension ColorEditViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let nibArray = NSBundle.mainBundle().loadNibNamed("CustomCell", owner: self, options: nil)
        var cell = tableView.dequeueReusableCellWithIdentifier("EDITCell") as? ColorEditCell
        
        if cell == nil {
            cell = nibArray![5] as? ColorEditCell
        }
        
        cell!.titleLabel.text = titles[indexPath.row]
        if indexPath.row == 0 {
            cell!.valueField.text = color.title
            cell!.valueField.placeholder = "TOUCH TO WRITE NAME"
        } else {
            cell!.valueField.text = color.memo
        }
        
        cell!.valueField.tintColor = .whiteColor()
        cell!.backgroundColor = .clearColor()
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
}
extension ColorEditViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if !isKeyboardShowing {
            ishexTouched = true
        }
        return true
    }
}
