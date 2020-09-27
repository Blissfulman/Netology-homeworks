//
//  BlockView.swift
//  Course3FinalTask
//
//  Created by User on 26.09.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit

/// Блокирующее вью с индикатором активности.
class BlockView: UIView {

    var parentView = UIView()
    
    let activityIndicator = UIActivityIndicatorView()
    
    func setup() {
        
        // Настройка самого вью
        self.backgroundColor = .black
        self.alpha = 0.7
        self.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)
                
        let constraints = [
            self.topAnchor.constraint(equalTo: parentView.topAnchor),
            self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        // Настройка индикатора активности
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    func show() {
        activityIndicator.startAnimating()
        self.isHidden = false
    }
    
    func hide () {
        self.isHidden = true
        activityIndicator.stopAnimating()
    }
}
