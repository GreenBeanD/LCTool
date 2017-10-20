//
//  LCDataBase.swift
//  LCUtopia
//
//  Created by 懒猫 on 2017/8/3.
//  Copyright © 2017年 懒猫. All rights reserved.
//

import UIKit
import FMDB

open class LCDataBase: NSObject {

    public enum ErrorExplain: Error {
        case NoExistTable
        case Other
    }

    /** 单例对象 */
    @objc open static let share = LCDataBase()

    /** 数据库对象 */
    @objc open var db:FMDatabase {
        if self.cacheDB != nil {
            self.cacheDB?.open()
            return self.cacheDB!
        }
        self.cacheDB = FMDatabase.init(path: self.path)
        self.cacheDB?.open()
        return self.cacheDB!
    }

    /** 数据库操作队列对象 */
    @objc open var dbQuene: FMDatabaseQueue {
        if self.cacheDBQuene != nil {
            return self.cacheDBQuene!
        }
        self.cacheDBQuene = FMDatabaseQueue.init(path: self.path)
        return self.cacheDBQuene!
    }

    /** 增量路径  path/path/... */
    @objc open var appendPath: String = ""
    /** 数据库名字 */
    @objc open var dataBaseName: String = "lcDataBase"

    // 存储路径
    private var path: String {
        let documentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        var morePath = documentPath
        if !self.appendPath.isEmpty {
            morePath += self.appendPath
        }
        morePath += "/\(self.dataBaseName).sqlite"
        return morePath
    }

    private var cacheDB: FMDatabase?
    private var cacheDBQuene: FMDatabaseQueue?

    //打开数据库
    private func openDataBase() {
        self.db.open()
    }

    /** 创建表 */
    @objc open func creatTable(sql: String) throws -> Void {
        try self.executeSqlUpdate(sql: sql, arguments: nil)
    }

    /** 删除表 */
    @objc open func deleteTable(tableName: String) throws {
        let sql = "DROP TABLE IF EXISTS \(tableName)"
        try self.executeSqlUpdate(sql: sql, arguments: nil)
    }

    /** 查询数据库中是否存在该表，如果不存在，就创建该表 */
    @objc open func isExistThisTable(config: LCTableConfig) {
        if config.isExistTable {
            return
        }
        if self.db.tableExists(config.tableName) {
            config.isExistTable = true
        }else {
            do {
                try self.creatTable(sql: config.completeTable)
                config.isExistTable = true
            } catch {
                config.isExistTable = false
            }
        }
    }

    /** 执行SQL-Update语句 */
    @objc open func executeSqlUpdate(sql: String, arguments: [Any]!) throws -> Void {
        var isError:Error?
        self.dbQuene.inDatabase { (db) in
            do {
                try db.executeUpdate(sql, values: arguments)
            }catch {
                isError = error
            }
        }
        if isError != nil {
            throw isError!
        }
    }

    /** 执行SQL-Update语句 自动检验该表是否存在，不存在则创建 */
    @objc open func executeSqlUpdate(sql: String, arguments: [Any]!, config: LCTableConfig) throws -> Void {
        self.isExistThisTable(config: config)
        if !config.isExistTable {
            throw LCDataBase.ErrorExplain.NoExistTable
        }
        else {
            try self.executeSqlUpdate(sql: sql, arguments: arguments)
        }
    }

    /** 执行SQL-Query语句 */
    open func executeSqlQuery(sql: String, arguments: [Any]!) throws -> Array<Dictionary<AnyHashable, Any>>? {
        var resultArray: [Dictionary<AnyHashable, Any>] = []
        var isError:Error?
        self.dbQuene.inDatabase { (db) in
            do {
                let result = try db.executeQuery(sql, values: arguments)
                while result.next() {
                    if (result.resultDictionary != nil) {
                        let resultDict = result.resultDictionary
                        resultArray.append(resultDict!)
                    }
                }
            }catch {
                isError = error
            }
        }
        if isError != nil {
            throw isError!
        }
        if resultArray.count > 0 {
            return resultArray
        }
        return nil
    }

    /** 执行SQL-Query语句 自动检验该表是否存在，不存在则创建 */
    open func executeSqlQuery(sql: String, arguments: [Any]!, config: LCTableConfig) throws -> Array<Dictionary<AnyHashable, Any>>? {
        self.isExistThisTable(config: config)
        if !config.isExistTable {
            throw LCDataBase.ErrorExplain.NoExistTable
        }
        else {
            let result = try self.executeSqlQuery(sql: sql, arguments: arguments)
            return result
        }
    }

    /** 执行SQL-Query语句 针对OC的查询方法 */
    @objc open func executeSqlQueryForOC(sql: String, arguments: [Any]!, config: LCTableConfig) throws -> Any {
        let result = try self.executeSqlQuery(sql: sql, arguments: arguments, config: config)
        if result == nil {
            throw ErrorExplain.Other
        }
        return result!
    }
}

extension String {

    /** 增 */
    public static func lcInsert(tableName: String) -> String {
        let sql = "INSERT INTO \(tableName)"
        return sql
    }

    /** 删 */
    public static func lcDelete(tableName: String) -> String {
        let sql = "DELETE FROM \(tableName)"
        return sql
    }

    /** 删除全部 */
    public func lcDeleteAll() -> String {
        return self
    }

    /** 改 */
    public static func lcUpDate(tableName: String) -> String {
        let sql = "UPDATE \(tableName)"
        return sql
    }

    /** 查 */
    public static func lcQuery(tableName: String) -> String {
        let sql = "SELECT * FROM \(tableName)"
        return sql
    }

    /** 查询全部 */
    public func lcQueryAll() -> String {
        return self
    }
    /** 插入条件 */
    public func lcInsertCondition(keyArray: [String]) -> String {
        var sql = self
        var valueC = ""
        sql += " ("
        for item in keyArray {
            sql += "\(item),"
            valueC += "?,"
        }
        sql = String(sql[..<sql.index(before: sql.endIndex)])
        sql += ")"
        valueC = String(valueC[..<valueC.index(before: valueC.endIndex)])
        sql += " VALUES (\(valueC))"

        return sql
    }

    /** 查询条件 */
    public func lcWhereCondition(keyArray: [String]) -> String {
        var sql = self
        sql += " WHERE "
        sql += "("
        for item in keyArray {
            sql += "\(item)=?,"
        }
        sql = String(sql[..<sql.index(before: sql.endIndex)])
        sql += ")"
        return sql
    }
    /** 赋值条件 */
    public func lcSetCondition(keyArray: [String]) -> String {
        //SET值不能带括号
        var sql = self
        sql += " SET "
        for item in keyArray {
            sql += "\(item)=?,"
        }
        sql = String(sql[..<sql.index(before: sql.endIndex)])
        return sql
    }
}

@objc extension NSString {

    /** 增 */
    public static func lcInsert(tableName: NSString) -> NSString {
        let sql = NSString.init(string: "INSERT INTO \(tableName)")
        return sql
    }

    /** 删 */
    public static func lcDelete(tableName: NSString) -> NSString {
        let sql = NSString.init(string: "DELETE FROM \(tableName)")
        return sql
    }

    /** 删除全部 */
    public func lcDeleteAll() -> NSString {
        return self
    }

    /** 改 */
    public static func lcUpDate(tableName: NSString) -> NSString {
        let sql = NSString.init(string: "UPDATE \(tableName)")
        return sql
    }

    /** 查 */
    public static func lcQuery(tableName: NSString) -> NSString {
        let sql = NSString.init(string: "SELECT * FROM \(tableName)")
        return sql
    }

    /** 查询全部 */
    public func lcQueryAll() -> NSString {
        return self
    }
    /** 插入条件 */
    public func lcInsertCondition(keyArray: [NSString]) -> NSString {
        var sql = String(self)
        var valueC = ""
        sql += " ("
        for item in keyArray {
            sql += "\(item),"
            valueC += "?,"
        }
        sql = String(sql[..<sql.index(before: sql.endIndex)])
        sql += ")"
        valueC = String(valueC[..<valueC.index(before: valueC.endIndex)])
        sql += " VALUES (\(valueC))"

        return NSString.init(string: sql)
    }

    /** 查询条件 */
    public func lcWhereCondition(keyArray: [NSString]) -> NSString {
        var sql = String(self)
        sql += " WHERE "
        sql += "("
        for item in keyArray {
            sql += "\(item)=?,"
        }
        sql = String(sql[..<sql.index(before: sql.endIndex)])
        sql += ")"
        return NSString.init(string: sql)
    }
    /** 赋值条件 */
    public func lcSetCondition(keyArray: [NSString]) -> NSString {
        //SET值不能带括号
        var sql = String(self)
        sql += " SET "
        for item in keyArray {
            sql += "\(item)=?,"
        }
        sql = String(sql[..<sql.index(before: sql.endIndex)])
        return NSString.init(string: sql)
    }
}
