//
//  LCDataBaseControllerViewController.swift
//  LCTool
//
//  Created by 懒猫 on 2017/10/18.
//  Copyright © 2017年 懒猫. All rights reserved.
//

import UIKit

class LCDataBaseControllerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    let example = LCDataBaseExample()

    @IBAction func insertClick(_ sender: UIButton) {
        example.insertDataForOne()
    }

    @IBAction func deleteClick(_ sender: UIButton) {
        example.deleteData()
    }

    @IBAction func updateClick(_ sender: UIButton) {
        example.updateData()
    }
    
    @IBAction func queryClick(_ sender: UIButton) {
        example.queryData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
