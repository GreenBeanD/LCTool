//
//  LCCache.swift
//  LCTool
//
//  Created by 懒猫 on 2017/10/27.
//  Copyright © 2017年 懒猫. All rights reserved.
//

import UIKit

class LCCache: NSObject {
    //LCCache是基于sqlite的缓存模块，支持缓存的数据类型有Dictionary、Array、String、NSNumber、Data

    //默认表
    let lcCacheTable = LCTableConfig.initConfigure().with(tableName: "t_lcCache").with(column: "Key", DBType: .TEXT, option: "NOT NULL UNIQUE").with(column: "ContentText", DBType: .TEXT).with(column: "contentData", DBType: .BLOB).with(column: "type", DBType: .TEXT, option: "NOT NULL").end()

    private var currentTable: LCTableConfig!

    /** 缓存管理器 */
    open static let share = LCCache()

    //如果需要另外的表来存储不同的数据，可以使用此方法来指定一张表的名字(表结构不变)，进行单独的缓存管理，但是LCCache对象的生命周期将由使用者自行管理
    /** 创建LCCache对象并指定一张表 */
    public convenience init(tableName: String) {
        self.init()
        self.currentTable = LCTableConfig.initConfigure().with(tableName: "\(tableName)").with(column: "Key", DBType: .TEXT, option: "NOT NULL UNIQUE").with(column: "ContentText", DBType: .TEXT).with(column: "contentData", DBType: .BLOB).with(column: "type", DBType: .TEXT, option: "NOT NULL").end()
    }

    override init() {
        super.init()
        self.currentTable = self.lcCacheTable
    }

    //快捷的存取方法
    open subscript(key: String) -> Any? {
        get {
            return self.getCache(key: key)
        }
        set {
            if newValue != nil {
                self.saveCache(key: key, value: newValue!)
            }
            else {
                self.deleteSingleCache(key: key)
            }
        }
    }

    /** 清空所有缓存 */
    open func clearAllCache() {
        let sql = String.lcDelete(tableName: self.currentTable.tableName).lcDeleteAll()
        try? LCDataBase.share.executeSqlUpdate(sql: sql, arguments: nil, config: self.currentTable)
    }

    /** 删除一条缓存 */
    open func deleteSingleCache(key: String) {
        let sql = String.lcDelete(tableName: self.currentTable.tableName).lcWhereCondition(keyArray: ["Key"])
        try? LCDataBase.share.executeSqlUpdate(sql: sql, arguments: [key], config: self.currentTable)
    }

    /** 读取缓存数据 */
    open func getCache(key: String) -> Any? {
        let sql = String.lcQuery(tableName: self.currentTable.tableName).lcWhereCondition(keyArray: ["Key"])
        let resultGet = try? LCDataBase.share.executeSqlQuery(sql: sql, arguments: [key], config: self.currentTable)
        if resultGet == nil {
            return nil
        }
        let array = resultGet!
        if array?.isEmpty ?? true {
            return nil
        }

        let searchDict = array!.first!
        let type = searchDict["type"] as! String
        if type == "Data" {
            return searchDict["contentData"]
        }
        else if type == "String" {
            return searchDict["ContentText"]
        }
        else if type == "NSNumber" {
            let numStr = searchDict["ContentText"] as! String
            return NSNumber.init(value: Double(numStr)!)
        }
        else if type == "Json" {
            let jsonStr = searchDict["ContentText"] as! String
            let json = LCUtils.jsonToObject(data: jsonStr.data(using: String.Encoding.utf8)!)
            return json
        }
        return nil
    }

    /** 存储缓存数据 */
    open func saveCache(key: String, value: Any) {
        var sql = ""
        var type = ""
        var arguments: [Any] = []

        if value is Data {
            sql = "REPLACE INTO \(self.currentTable.tableName) (Key, contentData, type) values (?, ?, ?)"
            type = "Data"
            arguments += [key,value,type]
        }
        else {
            sql = "REPLACE INTO \(self.currentTable.tableName) (Key, ContentText, type) values (?, ?, ?)"

            if value is String {
                type = "String"
                arguments += [key,value,type]
            }
            else if value is NSNumber {
                type = "NSNumber"
                let tmpValue = value as! NSNumber
                arguments += [key,tmpValue.stringValue,type]
            }
            else {
                let result = LCUtils.ObjectToJson(data: value)
                if result != nil {
                    type = "Json"
                    arguments += [key,result!,type]
                }
            }
        }
        if type.isEmpty {
            return
        }
        try? LCDataBase.share.executeSqlUpdate(sql: sql, arguments: arguments, config: self.currentTable)
    }
}
