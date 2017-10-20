//
//  LCNetCache.swift
//  LCServer
//
//  Created by 懒猫 on 2017/10/12.
//  Copyright © 2017年 懒猫. All rights reserved.
//

import UIKit

class LCNetCache: NSObject {

    let lcNetCacheTable = LCTableConfig.initConfigure().with(tableName: "t_lcNetCache").with(column: "Key", DBType: LCTableConfig.DateBaseType.TEXT, option: "NOT NULL UNIQUE").with(column: "Content", DBType: LCTableConfig.DateBaseType.TEXT, option: "NOT NULL").end()

    //读取缓存
    //针对Json数据的读取操作
    subscript(key: String) -> Any? {
        get {
            return self.getJsonCache(key: key)
        }
        set {
            if newValue != nil {
                self.saveJsonCahce(key: key, value: newValue!)
            }
        }
    }

    /** 读取Json数据 */
    private func getJsonCache(key: String) -> Any? {
        //从数据库中查询
        let sql = "SELECT DISTINCT Content from \(self.lcNetCacheTable.tableName) where Key = ?"
        let resultGet = try? LCDataBase.share.executeSqlQuery(sql: sql, arguments: [key], config: self.lcNetCacheTable)
        if resultGet == nil {
            return nil
        }
        let array = resultGet!
        guard array != nil else {
            return nil
        }
        if array!.isEmpty {
            return nil
        }
        //json数据转对象
        let searchDict = array!.first!
        let searchData = searchDict["Content"] as! String
        let result = LCUtils.jsonToObject(data: searchData.data(using: String.Encoding.utf8)!)
        return result
    }

    /** 存储Json数据 */
    private func saveJsonCahce(key: String, value: Any) {
        //数据转换成json
        let result = LCUtils.ObjectToJson(data: value)
        if result == nil {
            return
        }
        //将数据存储到数据库
        let sql = "REPLACE INTO \(self.lcNetCacheTable.tableName) (Key, Content) values (?, ?)"
        do {
            try LCDataBase.share.executeSqlUpdate(sql: sql, arguments: [key,result!], config: self.lcNetCacheTable)
        } catch {
            // 异常处理
        }
    }
}
