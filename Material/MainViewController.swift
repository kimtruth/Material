//
//  MainViewController.swift
//  Material
//
//  Created by Truth on 2016. 1. 4..
//  Copyright © 2016년 Truth. All rights reserved.
//


import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var selectedIndex = 0
    var indexPathToBeDeleted = NSIndexPath()
    var colors = [[Color]](){
        didSet {
            saveAll()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadAll()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    func loadAll(){
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        // 경로의 리스트를 생성
        let documentsDirectory: String = paths[0] as! String
        // 리스트로부터 문서 경로를 가져옴
        let path: String = (documentsDirectory as NSString).stringByAppendingPathComponent("colorlist.plist")
        // 전체 경로를 생성
        
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(path) {
            let bundle: String = NSBundle.mainBundle().pathForResource("colorlist", ofType: "plist")!
            //번들 디렉토리에 만들었던 문서의 경로를 가져옴
            do {
                try fileManager.copyItemAtPath(bundle, toPath: path)
                self.firstLoad(path)
            } catch let error as NSError {
                print("Cannot copy file: \(error.localizedDescription)")
            }
            // document에 번들 파일 경로를 복사
        } else {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            if let dicts = userDefaults.objectForKey("colors") as? [[[String : AnyObject]]] {
                for colors in dicts {
                    var dict = [Color]()
                    for color in colors {
                        if let RGB = color["RGB"] as? String,
                            let memo = color["memo"] as? String,
                            let title = color["title"] as? String,
                            let mainTitle = color["mainTitle"] as? String{
                                dict.append(Color(RGB: RGB, memo: memo, title: title, mainTitle: mainTitle))
                        }
                    }
                    self.colors.append(dict)
                }
            }
        }
    }
    
    func firstLoad(path: String){
        if let data = NSArray(contentsOfFile: path){
            for color in data {
                var dict = [Color]()
                for i in 1..<color.count {
                    if let RGB = color[i]["RGB"] as? String,
                        let memo = color[i]["memo"] as? String,
                        let title = color[i]["title"] as? String,
                        let mainTitle = color[0] as? String{
                            dict.append(Color(RGB: RGB, memo: memo, title: title, mainTitle: mainTitle))
                    }
                }
                colors.append(dict)
            }
        }
    }
    
    
    func saveAll(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        var dicts = [[[String: AnyObject]]]()
        for color in colors {
            let dict: [[String: AnyObject]] = color.map{
                [
                    "RGB": $0.RGB,
                    "memo": $0.memo,
                    "title": $0.title,
                    "mainTitle": $0.mainTitle
                ]
            }
            dicts.append(dict)
        }
        userDefaults.setObject(dicts, forKey: "colors")
        userDefaults.synchronize()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let view = segue.destinationViewController as! ColorListViewController
        let title = colors[selectedIndex][0].mainTitle
        view.navigationItem.title = title
        view.navigationItem.backBarButtonItem?.title = title
        view.listIndex = selectedIndex
        view.colors = colors[selectedIndex]
        view.main = self
    }
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let nibArray = NSBundle.mainBundle().loadNibNamed("CustomCell", owner: self, options: nil)
        
        if indexPath.row != colors.count {
            var cell = tableView.dequeueReusableCellWithIdentifier("MCCell") as? MainColorCell
            if cell == nil {
                cell = nibArray![0] as? MainColorCell
            }
            let color = colors[indexPath.row][0]
            cell!.bgLabel.backgroundColor = stringToColor(color.RGB)
            cell!.mainLabel.text = color.mainTitle
            cell!.subLabel.text = color.title + " " + color.RGB
            return cell!
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("MCLCell") as? MainColorLastCell
            if cell == nil {
                cell = nibArray![1] as? MainColorLastCell
            }
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120;
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == colors.count {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.indexPathToBeDeleted = indexPath
            let alert = UIAlertView(
                title: "WARNING",
                message: "DO YOU REALLY WANT TO DELETE?",
                delegate: self,
                cancelButtonTitle: "CANCEL",
                otherButtonTitles: "OK"
            )
            alert.show()
        }
    }
    
}

extension MainViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row  == colors.count {
            let alert = UIAlertView(
                title: "NEW COLOR SET",
                message: "ENTER THE NAME OF COLOR SET",
                delegate: self,
                cancelButtonTitle: "CANCEL",
                otherButtonTitles: "OK"
            )
            alert.alertViewStyle = .PlainTextInput
            alert.show()
        } else {
            selectedIndex = indexPath.row
            self.performSegueWithIdentifier("segueToList", sender: self)
        }
    }
}

extension MainViewController: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.title == "NEW COLOR SET" && buttonIndex == 1 {
            var title = ""
            if let text = alertView.textFieldAtIndex(0)?.text {
                if text.isEmpty {
                    title = "UNTITLED COLOR SET"
                } else {
                    title = text
                }
            }
            
            colors.append([Color(
                RGB: "#000000",
                memo: "",
                title: title,
                mainTitle: title
                )]
            )
            
            self.tableView.reloadData()
            let path = NSIndexPath(forRow: colors.count - 1, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(path, atScrollPosition: .Top, animated: true)
        } else if buttonIndex == 1 {
            self.colors.removeAtIndex(indexPathToBeDeleted.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths([indexPathToBeDeleted], withRowAnimation: .Automatic)
            self.tableView.endUpdates()
        }
    }
}
