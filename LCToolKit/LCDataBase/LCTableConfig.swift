//
//  LCTableConfig.swift
//  LCServer
//
//  Created by 懒猫 on 2017/6/5.
//  Copyright © 2017年 懒猫. All rights reserved.
//

import UIKit

public struct LCTableFieldSection {
    var column = ""
    var type = ""
    var option = ""
}

open class LCTableConfig: NSObject {

    @objc public enum DateBaseType: Int {
        case TEXT = 0
        case INTEGER
        case REAL
        case BLOB
        case NULL
    }

    private let typeArray: [String] = ["TEXT","INTEGER","REAL","BLOB","NULL"]

    // 表名
    @objc open var tableName: String = ""

    // 配置语句
    @objc open var tableField: String = ""

    //分段配置语句 注意:使用此方法配置的表才会自动检测更新操作
    open var tableFieldSubsection: [LCTableFieldSection] = []

    // 完整的sql语句
    @objc open var completeTable: String = ""

    var isExistTable = false

    /** 创建表配置对象 */
    @objc open static func initConfigure() -> LCTableConfig {
        let config = LCTableConfig()
        return config
    }

    /** 表名 */
    open func with(tableName: String) -> LCTableConfig {
        self.tableName = tableName
        return self
    }

    /** 表字段 */
    open func with(tableField: String) -> LCTableConfig {
        self.tableField = tableField
        self.completeTable = "CREATE TABLE IF NOT EXISTS \(self.tableName) (pk INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,\(self.tableField))"
        return self
    }

    /** 结束配置 */
    @objc open func end() -> LCTableConfig {
        if self.tableFieldSubsection.isEmpty {
            return self
        }
        var fieldString = ""
        for index in 0..<self.tableFieldSubsection.count {
            let item = self.tableFieldSubsection[index]
            fieldString.append("\(item.column) \(item.type)\(item.option)")
            if index < (self.tableFieldSubsection.count-1) {
                fieldString.append(", ")
            }
        }
        return self.with(tableField: fieldString)
    }

    /** 使用此方法配置表必须在结束时调用end()方法 */
    open func with(column: String, DBType: DateBaseType) -> LCTableConfig {
        var fieldSection = LCTableFieldSection()
        fieldSection.column = column
        fieldSection.type = self.typeArray[DBType.rawValue]
        self.tableFieldSubsection.append(fieldSection)
        return self
    }

    /** 具有额外配置列属性功能的方法 使用此方法配置表必须在结束时调用end()方法 */
    open func with(column: String, DBType: DateBaseType, option: String) -> LCTableConfig {
        var fieldSection = LCTableFieldSection()
        fieldSection.column = column
        fieldSection.type = self.typeArray[DBType.rawValue]
        fieldSection.option = " \(option)"
        self.tableFieldSubsection.append(fieldSection)
        return self
    }
}

extension LCTableConfig {
    //兼容OC的一套方法
    /** 表名 */
    @objc open func withTableName() -> ((String)->LCTableConfig) {
        return { (tableName: String)->LCTableConfig in
            self.tableName = tableName
            return self
        }
    }

    /** 表字段 */
    @objc open func withTableField() -> ((String)->LCTableConfig) {
        return { (tableField)->LCTableConfig in
            self.tableField = tableField
            self.completeTable = "CREATE TABLE IF NOT EXISTS \(self.tableName) (pk INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,\(self.tableField))"
            return self
        }
    }

    /** 具有额外配置列属性功能的方法 使用此方法配置表必须在结束时调用end()方法 */
    @objc open func withColumnOption() -> (_ column: String, _ DBType: DateBaseType, _ option: String)->LCTableConfig {
        return { (column: String, DBType: DateBaseType, option: String)->LCTableConfig in
            var fieldSection = LCTableFieldSection()
            fieldSection.column = column
            fieldSection.type = self.typeArray[DBType.rawValue]
            fieldSection.option = " \(option)"
            self.tableFieldSubsection.append(fieldSection)
            return self
        }
    }

    /** 使用此方法配置表必须在结束时调用end()方法 */
    @objc open func withColumn() -> (_ column: String, _ DBType: DateBaseType)->LCTableConfig {
        return { (column: String, DBType: DateBaseType)->LCTableConfig in
            var fieldSection = LCTableFieldSection()
            fieldSection.column = column
            fieldSection.type = self.typeArray[DBType.rawValue]
            self.tableFieldSubsection.append(fieldSection)
            return self
        }
    }
}
