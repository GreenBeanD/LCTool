//
//  LCUtils.swift
//  LCServer
//
//  Created by 懒猫 on 2017/5/23.
//  Copyright © 2017年 懒猫. All rights reserved.
//

import UIKit

open class LCUtils: NSObject {

    //MARK: Json与Object的互转

    /** 任一对象转Json数据 */
    open static func ObjectToJson(data: Any?) -> String?{
        if data == nil {
            return nil
        }
        guard JSONSerialization.isValidJSONObject(data!) else {
            return nil
        }
        do {
            let result = try JSONSerialization.data(withJSONObject: data!, options: JSONSerialization.WritingOptions.prettyPrinted)
            return NSString(data: result, encoding: String.Encoding.utf8.rawValue) as String?
        } catch {
            return nil
        }
    }

    /** Json数据转对象 */
    open static func jsonToObject(data: Data) -> Any? {
        do {
            let result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            return result
        } catch {
            return nil
        }
    }

    // MARK: 利用UserDefault存取数据

    /** 存储数据到UserDefault */
    open static func saveDataToUserDefault(key: String, value: Any) {
        let userDefault = UserDefaults.standard
        userDefault.set(value, forKey: key)
        userDefault.synchronize()
    }

    /** 从UserDefault中读取数据 */
    open static func getDataFromUserDefault(key: String) -> Any? {
        let userDefault = UserDefaults.standard
        return userDefault.object(forKey: key)
    }

    //MARK: 获取当前View的控制器
    /** 获取当前View的控制器 */
    open static func getCurrentViewController(view: UIView) -> UIViewController? {
        var responder: UIResponder? = view.next
        guard responder != nil else {
            return nil
        }
        while responder?.next != nil {
            if responder is UIViewController {
                return responder as? UIViewController
            }
            responder = responder?.next
        }
        return nil
    }

    //MARK: 获取版本信息
    /** 获取版本号 */
    open static func getVersion() -> String {
        let result = Bundle.main.infoDictionary!
        return result["CFBundleShortVersionString"] as! String
    }
    /** 获取Build号 */
    open static func getBuild() -> String {
        let result = Bundle.main.infoDictionary!
        return result["CFBundleVersion"] as! String
    }

}
