//
//  BaseViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/2.
//

import UIKit
import Lottie

class BaseViewController: UIViewController {

    private var animationView = AnimationView()
    var mask = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func setAnimation() {
        mask.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height)
        mask.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.addSubview(mask)

        animationView = .init(name: "accountLoading")
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        animationView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        animationView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.75
        animationView.play()
    }
    
    func removeAnimation() {
        mask.removeFromSuperview()
        animationView.stop()
        animationView.removeFromSuperview()
    }
    
}
