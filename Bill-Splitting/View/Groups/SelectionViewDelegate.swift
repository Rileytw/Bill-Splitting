//
//  SelectionViewDelegate.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import Foundation
@objc protocol SelectionViewDelegate: AnyObject {
    
    @objc optional func didSelectedButton(_ selectionView: SelectionView, at index: Int)

    @objc optional func shouldSelectedButton(_ selectionView: SelectionView, at index: Int) -> Bool
}
