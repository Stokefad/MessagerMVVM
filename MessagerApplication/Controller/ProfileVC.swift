//
//  ProfileVC.swift
//  MessagerApplication
//
//  Created by Igor-Macbook Pro on 02/02/2019.
//  Copyright © 2019 Igor-Macbook Pro. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

class ProfileVC : UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    let vm = ProfileVM()
    
    var currentUser : String? {
        didSet {
            vm.currentUser = currentUser
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let observer = Signal<User, NoError>.Observer(
            value : { [unowned self] value in
                self.nameLabel.text = value.name
        },
            failed: { error in
                print("Failed with error \(error)")
        })
        
        vm.producer.start(observer)
    }
    
}
