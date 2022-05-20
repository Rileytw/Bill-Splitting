//
//  WeCountTests.swift
//  WeCountTests
//
//  Created by 雷翎 on 2022/5/20.
//

import XCTest
@testable import WeCount

class WeCountTests: XCTestCase {
    var sut: CustomGroupViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = CustomGroupViewController()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
//        sut = nil
        try super.tearDownWithError()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testUpdateDateTimestamp() {
      // given
        let component: Calendar.Component = .month
        let startDate = Date.getTimeDate(timeStamp: 1653019200)
        
      // when
//        Date.updateDateTimestamp(component: component, startDate: startDate)

      // then
        XCTAssertEqual(Date.updateDateTimestamp(component: component, startDate: startDate),
                       1655697600,
                       "updateDate is wrong")
    
    }
    
    func testPersonalExpense() {
        // given
        let personalExpense = 200.33423
        
        // when
        sut.showPersonalExpense(personalExpense: personalExpense)
        
        // then
        XCTAssertEqual(sut.groupDetailView.personalFinalPaidLabel.text,
                       "你的總支出為：200.33 元",
                         "personalExpense is wrong")
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
