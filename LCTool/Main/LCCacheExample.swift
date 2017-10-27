//
//  LCCacheExample.swift
//  LCTool
//
//  Created by 懒猫 on 2017/10/27.
//  Copyright © 2017年 懒猫. All rights reserved.
//

import UIKit

class LCCacheExample: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    let differentCache = LCCache.init(tableName: "t_differentCache")

    var imageDict:[String:UIImage] = [:]

    var isUseDefault = true

    @IBOutlet weak var currentStr: UILabel!

    @IBOutlet weak var cacheStr: UILabel!

    @IBOutlet weak var segment: UISegmentedControl!

    @IBOutlet weak var currentImage: UIImageView!

    @IBOutlet weak var cacheImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "缓存操作示例"

        self.currentStr.text = self.getCurrentDate()
        self.cacheStr.text = "点击获取缓存"

        self.otherTest()
    }

    @IBAction func insertCurrentStr(_ sender: UIButton) {
        self.currentStr.text = self.getCurrentDate()
        //插入缓存
        self.saveCache(key: "test", value: self.currentStr.text)
    }
    
    @IBAction func readCacheStr(_ sender: UIButton) {
        //读取缓存

        let result = self.getCache(key: "test")
        if result != nil {
            self.cacheStr.text = result as? String
        }else {
            self.cacheStr.text = "没有缓存"
        }
    }
    
    @IBAction func deleteStr(_ sender: UIButton) {
        //单个的两种不同的删除方式
        //清空表用clear方法
        if self.isUseDefault {
            LCCache.share["test"] = nil
        }
        else {
            self.differentCache.deleteSingleCache(key: "test")
        }
    }
    
    @IBAction func segmentChange(_ sender: UISegmentedControl) {
        self.isUseDefault = (sender.selectedSegmentIndex == 0)
        var imageKey = "default"
        if self.isUseDefault {
            self.cacheStr.text = "已切换至默认表"
        }
        else {
            self.cacheStr.text = "已切换至额外表"
            imageKey = "different"
        }
        let tmpImage = imageDict[imageKey]
        self.currentImage.image = tmpImage
    }
    
    @IBAction func pickImage(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imgPickerCtrl = UIImagePickerController()
            imgPickerCtrl.delegate = self
            imgPickerCtrl.allowsEditing = true
            imgPickerCtrl.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imgPickerCtrl, animated: true, completion: nil)
        }
    }
    
    @IBAction func readImage(_ sender: UIButton) {
        let result = self.getCache(key: "image")
        if let imageData = result as? Data {
            let image = UIImage.init(data: imageData)
            self.cacheImage.image = image
        }else {
            self.cacheImage.image = nil
        }
    }

    func getCurrentDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }

    //插入缓存
    func saveCache(key:String, value: Any?) {
        if self.isUseDefault {
            LCCache.share[key] = value
        }
        else {
            self.differentCache[key] = value
        }
    }

    //读取缓存
    func getCache(key: String) -> Any? {
        if self.isUseDefault {
            return LCCache.share[key]
        }
        else {
            return self.differentCache[key]
        }
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType]
        let mediaString = mediaType as! String
        // 相册图片
        var selectImage: UIImage?
        if mediaString == "public.image" {
            selectImage = info[UIImagePickerControllerEditedImage] as? UIImage
        }
        self.currentImage.image = selectImage
        if self.isUseDefault {
            self.imageDict["default"] = selectImage
        }
        else {
            self.imageDict["different"] = selectImage
        }

        //将图片插入数据库
        if selectImage != nil {
            let imageData = UIImageJPEGRepresentation(selectImage!, 1)
            self.saveCache(key: "image", value: imageData)
        }

        picker.dismiss(animated: true, completion: nil)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func otherTest() {
        let dict: [String : Any] = ["name":"LazyCat",
                                    "age":24,
                                    "greeting":["H","I"]]
        LCCache.share["dict"] = dict

        LCCache.share["number"] = NSNumber.init(value: 2017)

        LCCache.share["array"] = ["Do","you","like","me","?"]

        print(LCCache.share["dict"] ?? "呀,竟然没有值")
        print(LCCache.share["number"] ?? "呀,竟然没有值")
        print(LCCache.share["array"] ?? "呀,竟然没有值")
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
