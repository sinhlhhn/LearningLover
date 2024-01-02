//
//  LearningLoverTests.swift
//  LearningLoverTests
//
//  Created by SinhLH.FHN on 29/12/2023.
//

import XCTest
import ViewInspector
@testable import LearningLover

struct TransactionModel {
    
}

import SwiftUI
struct TransactionListView: View {
    var body: some View {
        Text("")
    }
}

final class LearningLoverTests: XCTestCase {

    func test_onAppLaunch_displaysEmptyTransactionlist() throws {
        let newTransaction = TransactionModel()
        let view = try launch()
        
        view.simulateAdding(transaction: newTransaction)
        
        XCTAssertEqual(view.list().count, 0)
    }
    
    private func launch() throws -> TransactionListView {
        let view = TransactionListView()
        
        return view
    }
    
    class TestApp {
        
        private func selectAddTransaction() { }
        
        private func selectAmount(for transaction: TransactionModel) {}
        private func setCategory(for transaction: TransactionModel) {}
        private func save(_ transaction: TransactionModel) {}
        
        
    }

}

extension TransactionListView {
    func list() -> [TransactionModel] {
        return []
    }
    
    func simulateAdding(transaction: TransactionModel) {
        
    }
}
