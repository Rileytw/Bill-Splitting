//
//  ErrorType.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/19.
//

import UIKit
import SwiftUI

enum ErrorType {
    case generalError
    case networkError
    case dataFetchError
    case dataDeleteError
    case dataModifyError
    case dataUpdateError
    
    var errorMessage: String {
        switch self {
        case .generalError:
            return "發生錯誤，請稍後再試"
        case .networkError:
            return "網路未連線，請連線後再試"
        case .dataFetchError:
            return "資料讀取發生錯誤，請稍後再試"
        case .dataDeleteError:
            return "資料刪除失敗，請稍後再試"
        case .dataModifyError:
            return "資料修改失敗，請稍後再試"
        case .dataUpdateError:
            return "資料上傳發生錯誤，請稍後再試"
        }
    }
}

enum SuccessType {
    case addSuccess
    case deleteSuccess
    
    var successMessage: String {
        switch self {
        case .addSuccess:
            return ""
        case .deleteSuccess:
            return "資料已刪除"
        }
    }
}
