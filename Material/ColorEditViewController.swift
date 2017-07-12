//
//  ColorEditViewController.swift
//  Material
//
//  Created by Truth on 2016. 1. 4..
//  Copyright © 2016년 Truth. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    
    @IBAction func cancleButtonDidTap(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonDidTap(_ sender: AnyObject) {
        let nameCell = tableView.cellForRow(at: IndexPath(row: nameRow, section: 0)) as! ColorEditCell
        let memoCell = tableView.cellForRow(at: IndexPath(row: memoRow, section: 0)) as! ColorEditCell
        
        main.colors[listIndex][subIndex].title = nameCell.valueField.text!
        main.colors[listIndex][subIndex].memo = memoCell.valueField.text!
        main.colors[listIndex][subIndex].RGB = self.hexField.text!
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(
            frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 1)
        )
        self.hexField.text = color.RGB
        self.hexField.tintColor = .white
        self.hexField.delegate = self
        self.hexField.addTarget(self, action: #selector(ColorEditViewController.didChangedHexText(_:)), for: .editingChanged)
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.hexField.becomeFirstResponder()
        }
        
        self.colorSelectButton.layer.cornerRadius = (0.35 * (self.view.frame.height - 64)) / 2
        self.colorSelectButton.clipsToBounds = true
        self.colorSelectButton.backgroundColor = stringToColor(color.RGB)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ColorEditViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ColorEditViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ColorEditViewController.handleTap(_:)))
        self.view!.addGestureRecognizer(tap)
    }
    
    func didChangedHexText(_ textField: UITextField) {
        if textField.text?.characters.first != "#" {
            textField.text = "#" + textField.text!
        }
        if textField.text?.characters.count > 7 {
            textField.deleteBackward()
        }
        textField.text = textField.text?.uppercased()
        self.colorSelectButton.backgroundColor = stringToColor(textField.text!)
    }
    
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if isKeyboardShowing == false{
            if !ishexTouched {
                adjustingHeight(true, notification: notification)
            }
            isKeyboardShowing = true
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        print(self.view.layer.position.y)
        if isKeyboardShowing == true{
            if !ishexTouched {
                adjustingHeight(false, notification: notification)
            }
            ishexTouched = false
            isKeyboardShowing = false
        }
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

extension ColorEditViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nibArray = Bundle.main.loadNibNamed("CustomCell", owner: self, options: nil)
        var cell = tableView.dequeueReusableCell(withIdentifier: "EDITCell") as? ColorEditCell
        
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
        
        cell!.valueField.tintColor = .white
        cell!.backgroundColor = .clear
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 55
    }
}
extension ColorEditViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if !isKeyboardShowing {
            ishexTouched = true
        }
        return true
    }
}
