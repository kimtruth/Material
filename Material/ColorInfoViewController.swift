//
//  ColorInfoViewController.swift
//  Material
//
//  Created by Truth on 2016. 1. 4..
//  Copyright © 2016년 Truth. All rights reserved.
//

import UIKit

class ColorInfoViewController: UIViewController {
    @IBOutlet weak var bgLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var main = MainViewController()
    var listIndex = 0
    var subIndex = 0
    var color = Color()
    var titles = ["WEB COLOR", "RGB COLOR", "MEMO"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        load()
    }
    
    func load(){
        color = main.colors[listIndex][subIndex]
        
        print("====Info load =====")
        print(listIndex)
        print(subIndex)
        print("====Info load =====")
        
        self.mainLabel.text = color.mainTitle;
        self.subLabel.text = color.title;
        self.bgLabel.backgroundColor = stringToColor(color.RGB);
        
        self.tableView.tableFooterView = UIView(
            frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 1)
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        load()
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navi = segue.destinationViewController as! UINavigationController
        let view = navi.viewControllers.first as! ColorEditViewController
        view.color = color
        view.main = main
        view.subIndex = subIndex
        view.listIndex = listIndex
        
        print("====Info -> Edit =====")
        print(listIndex)
        print(subIndex)
        print("====Info -> Edit =====")
    }
}

extension ColorInfoViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let nibArray = NSBundle.mainBundle().loadNibNamed("CustomCell", owner: self, options: nil)
        var cell = tableView.dequeueReusableCellWithIdentifier("INFOCell") as? ColorInfoCell
        
        if cell == nil {
            cell = nibArray![4] as? ColorInfoCell
        }
        
        cell!.titleLabel.text = titles[indexPath.row]
        if indexPath.row == 0 {
            cell!.valueLabel.text = color.RGB
        } else if indexPath.row == 1 {
            cell!.valueLabel.text = hexStringFromColor(stringToColor(color.RGB))
        } else {
            cell!.valueLabel.text = color.memo
        }
        
        cell!.backgroundColor = .clearColor()
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
}
extension ColorInfoViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ColorInfoCell
        let hexString = cell.valueLabel.text
        UIPasteboard.generalPasteboard().string = hexString
        let alert = UIAlertView(
            title: "복사되었습니다!",
            message: hexString,
            delegate: self,
            cancelButtonTitle: "확인"
        )
        alert.show()
    }
}

