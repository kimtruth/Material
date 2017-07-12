//
//  ColorListViewController.swift
//  Material
//
//  Created by Truth on 2016. 1. 4..
//  Copyright © 2016년 Truth. All rights reserved.
//

import UIKit

class ColorListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var main = MainViewController()
    var colors = [Color]()
    var cellCount = 10
    var listIndex = 0
    var selectedIndex = 0
    var deleted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(
            frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 1)
        )
    }
    
    func setDeleted(){
        self.deleted = true
        print(self.deleted)
    }
    override func viewWillAppear(_ animated: Bool) {
        if deleted {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            colors = main.colors[listIndex]
            let title = colors[0].mainTitle
            self.navigationItem.title = title
            self.navigationItem.backBarButtonItem?.title = title
            
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSegue" {
            let navi = segue.destination as! UINavigationController
            let view = navi.viewControllers.first as! ColorSetEditViewController
            view.listIndex = listIndex
            view.colors = colors
            view.main = main
            view.listView = self
        } else {
            let view = segue.destination as! ColorInfoViewController
            view.color = colors[selectedIndex]
            view.main = main
            view.listIndex = listIndex
            view.subIndex = selectedIndex
            
            print("====listview -> Info =====")
            print(listIndex)
            print(selectedIndex)
            print("====listview -> Info =====")
        }
    }
}

extension ColorListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nibArray = Bundle.main.loadNibNamed("CustomCell", owner: self, options: nil)
        
        if indexPath.row != colors.count {
            var cell = tableView.dequeueReusableCell(withIdentifier: "DCCell") as? DetailColorCell
            if cell == nil {
                cell = nibArray![2] as? DetailColorCell
            }
            
            let color = colors[indexPath.row]
            cell!.colorLabel.backgroundColor = stringToColor(color.RGB)
            cell!.mainLabel.text = color.title
            cell!.subLabel.text = color.RGB
            cell!.backgroundColor = .clear
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "DCLCell") as? DetailColorLastCell
            if cell == nil {
                cell = nibArray![3] as? DetailColorLastCell
            }
            cell!.backgroundColor = .clear
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            main.colors[listIndex].remove(at: indexPath.row)
            colors = main.colors[listIndex]
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == colors.count {
            return false
        }
        return true
    }
}

extension ColorListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == colors.count {
            let alert = UIAlertView(
                title: "새로운 컬러",
                message: "컬러 이름을 입력하세요",
                delegate: self,
                cancelButtonTitle: "확인",
                otherButtonTitles: "취소"
            )
            alert.alertViewStyle = .plainTextInput
            alert.show()
        }
        else {
            selectedIndex = indexPath.row
            self.performSegue(withIdentifier: "segueToInfo", sender: self)
        }
    }
}

extension ColorListViewController: UIAlertViewDelegate {
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            return
        }
        var title = ""
        if let text = alertView.textField(at: 0)?.text {
            if text.isEmpty {
                title = "UNTITLED COLOR"
            } else {
                title = text
            }
        }
        
        main.colors[listIndex].append(Color(
            RGB: "#000000",
            memo: "memo",
            title: title,
            mainTitle: colors[0].mainTitle
            )
        )
        colors = main.colors[listIndex]
        
        self.tableView.reloadData()
        let path = IndexPath(row: colors.count - 1, section: 0)
        self.tableView.scrollToRow(at: path, at: .top, animated: true)
    }
}
