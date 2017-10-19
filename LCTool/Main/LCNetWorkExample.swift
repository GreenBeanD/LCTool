//
//  LCNetWorkExample.swift
//  LCTool
//
//  Created by 懒猫 on 2017/10/16.
//  Copyright © 2017年 懒猫. All rights reserved.
//

import UIKit

class LCNetWorkExample: NSObject {

    func startNetWork() {
        //如果需要设置基础URL，则可这样设置
        LCNetWork.manager.intactUrl = ""

        //默认不会自动打印请求的JSON数据,如需统一打印数据，请调用以下方法，记得在release情况下关闭
        LCNetWork.manager.openLog()

        ///不带缓存的GET请求

        //如果在某一个地方需要使用不同的参数格式，可以使用这个属性
        LCNetWork.tempRequestSerializer = .JSON

        //GET请求
        LCNetWork.GET(url: "https://httpbin.org/get", parameters: nil, successClosure: { (response) in
            print(response)
        }) { (error) in

        }

        //如果需要取消某个请求，可以调用
        LCNetWork.manager.cancelTask(withUrl: "url")

        ///带缓存的GET请求
        
        //缓存会在请求失败的情况下重新调用successClosure抛出缓存数据
        //LCNetWork.GETWithCache...

        //POST请求同理
    }

}
