//
//  LCDataBaseExample.swift
//  LCTool
//
//  Created by 懒猫 on 2017/10/18.
//  Copyright © 2017年 懒猫. All rights reserved.
//

import UIKit

class LCDataBaseExample: NSObject {

    //LCDataBase在使用时会自动创建不存在的表，只需要提前创建表配置文件和指定数据库名字、路径即可

    //表配置文件可以单独放在一个管理文件中作为全局资源，这里只是演示如何使用
    //创建一个表配置文件
    //with(tableName: "yourTableName")：指定这张表的名字
    //with(column: "yourTableColumn1", DBType: LCTableConfig.DateBaseType.TEXT)：指定这张表的一个字段的名字和类型
    //with(column: "yourTableColumn2", DBType: LCTableConfig.DateBaseType.TEXT, option: "NOT NULL")：可以添加更多的限制
    //end()：表配置结束，使用上述配置方法需要在最后调用end()方法
    let t_testTable = LCTableConfig.initConfigure().with(tableName: "yourTableName").with(column: "yourTableColumn1", DBType: LCTableConfig.DateBaseType.TEXT).with(column: "yourTableColumn2", DBType: LCTableConfig.DateBaseType.TEXT, option: "NOT NULL").end()

    //注意：还有另一种方法来配置表
    let t_testTableA = LCTableConfig.initConfigure().with(tableName: "yourTableName").with(tableField: "colomnName1 TEXT NOT NULL UNIQUE, colomnName2 TEXT NOT NULL, colomnName3 TEXT NOT NULL")



    //接下来是对这张表的增删改查
    //插入一条数据
    func insertDataForOne() {
        //创建一条插入语句
        //lcInsert(tableName:向哪一张表中插入
        //lcInsertCondition(keyArray:向该表中的哪些字段插入
        let insertSql = String.lcInsert(tableName: self.t_testTable.tableName).lcInsertCondition(keyArray: ["yourTableColumn1","yourTableColumn2"])
        //执行sql
        //最好捕获异常以防止程序出错
        //使用该方法才会自动检测表的存在
        try? LCDataBase.share.executeSqlUpdate(sql: insertSql, arguments: ["column1Data","column2Data"], config: self.t_testTable)
    }

    //批量插入数据
    func insertDataForMore() {
        //此处只演示批量插入数据，其他的批量操作同理
        let nameArray = ["like_1","like_2","like_3","like_4","like_6","like_8","like_11","like_12"]
        let aliasArray = ["淡黄午后","橙色人生","红色箴言","粉色情怀","艳色飞扬","绿草悠悠","蓝色畅想","紫色诱惑"]

        let insertSql = String.lcInsert(tableName: self.t_testTable.tableName).lcInsertCondition(keyArray: ["yourTableColumn1","yourTableColumn2"])

        //使用事务插入
        LCDataBase.share.dbQuene.inTransaction { (db, rollback) in
            do {
                for index in 0..<nameArray.count {
                    try db.executeUpdate(insertSql, values: [nameArray[index],aliasArray[index]])
                }
            }catch {
                rollback.pointee = true
            }
        }
    }

    //删除数据
    func deleteData() {
        //删除全部使用lcDeleteAll()
        //lcWhereCondition(keyArray: 查询条件
        let deleteSql = String.lcDelete(tableName: self.t_testTable.tableName).lcWhereCondition(keyArray: ["yourTableColumn1"])
        try? LCDataBase.share.executeSqlUpdate(sql: deleteSql, arguments: ["column1Data"], config: self.t_testTable)
    }

    //修改数据
    func updateData() {
        //lcSetCondition(keyArray: 赋值条件
        let updateSql = String.lcUpDate(tableName: self.t_testTable.tableName).lcSetCondition(keyArray: ["yourTableColumn1"]).lcWhereCondition(keyArray: ["yourTableColumn1"])
        try? LCDataBase.share.executeSqlUpdate(sql: updateSql, arguments: ["newData","column1Data"], config: self.t_testTable)
    }

    //查询数据
    func queryData() {
        //查询所有的用lcQueryAll()
        let querySql = String.lcQuery(tableName: self.t_testTable.tableName).lcWhereCondition(keyArray: ["yourTableColumn1"])
        let result = try? LCDataBase.share.executeSqlQuery(sql: querySql, arguments: ["newData"], config: self.t_testTable)
        if result != nil {
            let resultunpack = result!
            print(resultunpack ?? "")
        }
    }

}
