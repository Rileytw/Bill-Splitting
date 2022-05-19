//
//  ErrorType.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/19.
//

import UIKit

enum ErrorType {
    case generalError
    case networkError
    case dataError
    
    var errorMessage: String {
        switch self {
        case .generalError:
            return "發生錯誤，請稍後再試"
        case .networkError:
            return "網路未連線，請連線後再試"
        case .dataError:
            return "資料讀取發生錯誤，請稍後再試"
        }
    }
}

