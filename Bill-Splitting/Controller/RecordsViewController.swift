//
//  RecordsViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import UIKit
import Lottie

class RecordsViewController: UIViewController {
    
    private var animationView = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAnimation()
    }
    
    func setAnimation() {
        animationView = .init(name: "list")
        
        animationView.frame = view.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.75
        view.addSubview(animationView)
        animationView.play()
    }
}
