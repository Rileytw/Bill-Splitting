//
//  RoportManager.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/5.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore


class ReportManager {
    static var shared = ReportManager()
    lazy var db = Firestore.firestore()
    
    func updateReport(report: Report, completion: @escaping (Result<(), Error>) -> Void) {
        let reportRef = db.collection(FirebaseCollection.reports.rawValue).document()
        let report = report
        do {
            try db.collection(FirebaseCollection.reports.rawValue).document("\(reportRef.documentID)").setData(from: report)
            completion(.success(()))
        } catch {
            print(error)
            completion(.failure(error))
        }
    }
}
