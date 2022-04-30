//
//  SelectionView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import UIKit

class SelectionView: UIView {
    var numberOfButton: Int?
    
    var colorOfBar: UIColor?
    
    var colorOfText: UIColor?
    
    var fontOfText: UIFont?
    
    var textOfButtons: [ButtonModel] = []
    
    let width = UIScreen.main.bounds.width
    
    var buttonHeight: CGFloat = 50
    
    var indicatorView = UIView()
    
    var buttonIndex: Int?
    
    var buttons = [UIButton]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setButtons()
        setIndicatorView()
    }
    
    weak var selectionViewDataSource: SelectionViewDataSource?
    weak var selectionViewDelegate: SelectionViewDelegate?
    
    func setButtons() {
        
        numberOfButton = self.selectionViewDataSource?.numberOfSelectionView(self) ?? 2
        textOfButtons = self.selectionViewDataSource?.labelOfSelectionView(self) ?? []
        colorOfText = self.selectionViewDataSource?.colorOfText() ?? .white
        fontOfText = self.selectionViewDataSource?.fontOfText() ?? .systemFont(ofSize: 18)
        
        for button in 0 ..< (numberOfButton ?? 0) {
            let selectedButton = UIButton()
            selectedButton.frame = CGRect(x: (width/CGFloat(numberOfButton ?? 0) + 1) * CGFloat(button), y: 0, width: width/CGFloat(numberOfButton ?? 0) - 0.5, height: buttonHeight)
            selectedButton.setTitle(textOfButtons[button].title, for: .normal)
            selectedButton.titleLabel?.font = fontOfText
            ElementsStyle.styleButton(selectedButton)
            selectedButton.addTarget(self, action: #selector(changeIndicatorView), for: .touchUpInside)
            buttons.append(selectedButton)
            if button == 0 {
                ElementsStyle.styleSelectedButton(selectedButton)
            }
            addSubview(selectedButton)
        }
    }
    
    func setIndicatorView() {
        colorOfBar = self.selectionViewDataSource?.colorOfIndicator() ?? .blue
        self.addSubview(indicatorView)
        indicatorView.frame = CGRect(x: 0, y: buttonHeight + 1, width: width/CGFloat(numberOfButton ?? 0) - 0.5, height: 2)
        indicatorView.backgroundColor = colorOfBar
    }
    
    @objc func changeIndicatorView(_ sender: UIButton) {
        buttonIndex = Int(sender.frame.origin.x/(width/CGFloat(numberOfButton ?? 0)))
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.indicatorView.frame.origin.x = sender.frame.minX
        })
        self.selectionViewDelegate?.didSelectedButton?(self, at: buttonIndex ?? 0)
        
        for button in buttons {
            if button != sender {
                ElementsStyle.styleNotSelectedButton(button)
            }
        }
        ElementsStyle.styleSelectedButton(sender)
    }
}
