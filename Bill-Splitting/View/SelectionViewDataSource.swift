//
//  SelectionViewDataSource.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import UIKit

protocol SelectionViewDataSource: AnyObject {
    
    func numberOfSelectionView (_ selectionView: SelectionView) -> Int

    func labelOfSelectionView (_ selectionView: SelectionView) -> [ButtonModel]
    
    func colorOfIndicator () -> UIColor
    
    func colorOfText () -> UIColor
    
    func fontOfText () -> UIFont
    
}

extension SelectionViewDataSource {
    func colorOfIndicator () -> UIColor {
        return UIColor.greenWhite
    }
    
    func colorOfText () -> UIColor {
        return .white
    }
    
    func fontOfText () -> UIFont {
        return .systemFont(ofSize: 16)
    }
}
