//
//  LCToolTests.swift
//  LCToolTests
//
//  Created by 懒猫 on 2017/10/16.
//  Copyright © 2017年 懒猫. All rights reserved.
//

import XCTest
@testable import LCTool

class LCToolTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        LCNetWork.intactUrl = "http://111.198.26.81:8999/nokkin/api/"
        LCNetWork.openLog()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let para = ["goodsId":"28"]
        LCNetWork.POSTWithCache(url: "getGoodsCommentSatisfaction", parameters: para, successClosure: { (response) in

        }) { (error) in

        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
