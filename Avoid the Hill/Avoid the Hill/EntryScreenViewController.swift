//
//  EntryScreenViewController.swift
//  Avoid the Hill
//
//  Created by Ege Tanboga on 7/16/17.
//  Copyright © 2017 Tanbooz. All rights reserved.
//

import UIKit

class EntryScreenViewController : UIViewController  {

override func viewDidLoad() {
    super.viewDidLoad()
    let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRight(recognizer:)))
    recognizer.direction = .right
    self.view .addGestureRecognizer(recognizer)
    }
    
    func swipeRight(recognizer : UISwipeGestureRecognizer) {
        self.performSegue(withIdentifier: "goToMap", sender: self)
    }
}
