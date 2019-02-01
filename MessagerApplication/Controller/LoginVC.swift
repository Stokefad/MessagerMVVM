//
//  LoginVC.swift
//  MessagerApplication
//
//  Created by Igor-Macbook Pro on 30/01/2019.
//  Copyright © 2019 Igor-Macbook Pro. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

class LoginVC : UIViewController {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    
    var currentUser : User?
    
    let vm = LoginVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentUserObserver = Signal<User, NoError>.Observer(
            value: { [weak self] value in
                self!.currentUser = value
                self!.performSegue(withIdentifier: "goToMainScreen", sender: self)
                print("YA")
        },
            failed: { error in
                print("Falied with error \(error)")
        })
        
        vm.curInfo.observe(currentUserObserver)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! ContactListVC
        
        destVC.currentUser = currentUser
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let pass = passTF.text, let login = emailTF.text {
            vm.password = pass
            vm.email = login
        }
    }
    
}
