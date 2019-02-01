//
//  RegistrationVC.swift
//  MessagerApplication
//
//  Created by Igor-Macbook Pro on 30/01/2019.
//  Copyright © 2019 Igor-Macbook Pro. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

class RegistrationVC : UIViewController {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    
    let vm = RegistrationVM()
    
    var sendUser : User! {
        didSet {
            performSegue(withIdentifier: "goToChatList", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let signal = Signal<Bool, NoError>.Observer(value: { (isValid) in
                if isValid == true {
                    print("IsValid")
                }
        },  failed: { (error) in
                print("Failed \(error)")
        },  completed: {
                print("Completed")
        }) {
                print("Interrupted")
        }
        
        let observeUser = Signal<User, NoError>.Observer(
            value: { [weak self] value in
                self!.sendUser = value
        },
            failed: { error in
                print("Error occured \(error)")
        })
        
        vm.output.observe(signal)
        vm.userOutput.observe(observeUser)
    }
    
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        if let email = emailTF.text, let pass = passTF.text, let name = nameTF.text {
            vm.name = name
            vm.password = pass
            vm.login = email
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! ContactListVC
        
        destVC.currentUser = sendUser
    }
    
}
