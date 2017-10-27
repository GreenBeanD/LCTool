//
//  HomeViewController.swift
//  LCTool
//
//  Created by 懒猫 on 2017/10/16.
//  Copyright © 2017年 懒猫. All rights reserved.
//

import UIKit


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var sourceArray:[String] = ["LCNetWork使用示例","LCDataBase使用示例","LCCache使用示例"]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white

        self.navigationItem.title = "操作示例"

        self.tableView.register(UINib.init(nibName: "LCCell", bundle: nil), forCellReuseIdentifier: "HomeCellID")

        print(NSHomeDirectory())
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sourceArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LCCell = tableView.dequeueReusableCell(withIdentifier: "HomeCellID", for: indexPath) as! LCCell

        cell.textLabel?.text = self.sourceArray[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: LCCell = tableView.cellForRow(at: indexPath) as! LCCell
        if cell.textLabel?.text == "LCNetWork使用示例" {
            let vc = LCNetWorkExample()
            vc.startNetWork()
        }
        if cell.textLabel?.text == "LCDataBase使用示例" {
            let vc = LCDataBaseControllerViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if cell.textLabel?.text == "LCCache使用示例" {
            let vc = LCCacheExample()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
