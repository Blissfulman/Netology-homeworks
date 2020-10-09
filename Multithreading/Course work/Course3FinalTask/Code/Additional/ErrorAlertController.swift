//
//  ErrorAlertController.swift
//  Course3FinalTask
//
//  Created by User on 09.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class ErrorAlertController: UIAlertController {
    
    var parentVC: UIViewController!
    
    convenience init(parentVC: UIViewController) {
        self.init(title: "Unknown error!",
                  message: "Please, try again later",
                  preferredStyle: .alert)
        self.parentVC = parentVC
        addAction(.init(title: "Ok", style: .default, handler: nil))
    }
    
    func show() {
        parentVC.present(self, animated: true, completion: nil)
    }
}
