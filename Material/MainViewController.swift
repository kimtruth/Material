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
    var indexPathToBeDeleted = IndexPath()
    var colors = [[Color]](){
        didSet {
            saveAll()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    func loadAll(){
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        // 경로의 리스트를 생성
        let documentsDirectory: String = paths[0] as! String
        // 리스트로부터 문서 경로를 가져옴
        let path: String = (documentsDirectory as NSString).appendingPathComponent("colorlist.plist")
        // 전체 경로를 생성
        
        let fileManager: FileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            let bundle: String = Bundle.main.path(forResource: "colorlist", ofType: "plist")!
            //번들 디렉토리에 만들었던 문서의 경로를 가져옴
            do {
                try fileManager.copyItem(atPath: bundle, toPath: path)
                self.firstLoad(path)
            } catch let error as NSError {
                print("Cannot copy file: \(error.localizedDescription)")
            }
            // document에 번들 파일 경로를 복사
        } else {
            let userDefaults = UserDefaults.standard
            if let dicts = userDefaults.object(forKey: "colors") as? [[[String : AnyObject]]] {
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
    
    func firstLoad(_ path: String){
        
        if let data = NSArray(contentsOfFile: path) as? [[AnyObject]]{
            for color in data {
                var dict = [Color]()
                for col in color[1..<color.count] {
                    if let RGB = col["RGB"] as? String,
                        let memo = col["memo"] as? String,
                        let title = col["title"] as? String,
                        let mainTitle = color[0] as? String{
                            dict.append(Color(RGB: RGB, memo: memo, title: title, mainTitle: mainTitle))
                    }
                }
                colors.append(dict)
            }
        }
    }
    
    
    func saveAll(){
        let userDefaults = UserDefaults.standard
        
        var dicts = [[[String: String]]]()
        for color in colors {
            let dict: [[String: String]] = color.map{
                [
                    "RGB": $0.RGB,
                    "memo": $0.memo,
                    "title": $0.title,
                    "mainTitle": $0.mainTitle
                ]
            }
            dicts.append(dict)
        }
        userDefaults.set(dicts, forKey: "colors")
        userDefaults.synchronize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let view = segue.destination as! ColorListViewController
        let title = colors[selectedIndex][0].mainTitle
        view.navigationItem.title = title
        view.navigationItem.backBarButtonItem?.title = title
        view.listIndex = selectedIndex
        view.colors = colors[selectedIndex]
        view.main = self
    }
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nibArray = Bundle.main.loadNibNamed("CustomCell", owner: self, options: nil)
        
        if indexPath.row != colors.count {
            var cell = tableView.dequeueReusableCell(withIdentifier: "MCCell") as? MainColorCell
            if cell == nil {
                cell = nibArray![0] as? MainColorCell
            }
            let color = colors[indexPath.row][0]
            cell!.bgLabel.backgroundColor = stringToColor(color.RGB)
            cell!.mainLabel.text = color.mainTitle
            cell!.subLabel.text = color.title + " " + color.RGB
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "MCLCell") as? MainColorLastCell
            if cell == nil {
                cell = nibArray![1] as? MainColorLastCell
            }
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120;
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == colors.count {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row  == colors.count {
            let alert = UIAlertView(
                title: "NEW COLOR SET",
                message: "ENTER THE NAME OF COLOR SET",
                delegate: self,
                cancelButtonTitle: "CANCEL",
                otherButtonTitles: "OK"
            )
            alert.alertViewStyle = .plainTextInput
            alert.show()
        } else {
            selectedIndex = indexPath.row
            self.performSegue(withIdentifier: "segueToList", sender: self)
        }
    }
}

extension MainViewController: UIAlertViewDelegate {
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.title == "NEW COLOR SET" && buttonIndex == 1 {
            var title = ""
            if let text = alertView.textField(at: 0)?.text {
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
            let path = IndexPath(row: colors.count - 1, section: 0)
            self.tableView.scrollToRow(at: path, at: .top, animated: true)
        } else if buttonIndex == 1 {
            self.colors.remove(at: indexPathToBeDeleted.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPathToBeDeleted], with: .automatic)
            self.tableView.endUpdates()
        }
    }
}
