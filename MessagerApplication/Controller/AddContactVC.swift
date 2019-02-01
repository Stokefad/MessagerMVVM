//
//  AddContact.swift
//  MessagerApplication
//
//  Created by Igor-Macbook Pro on 30/01/2019.
//  Copyright © 2019 Igor-Macbook Pro. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

class AddContactVC : UIViewController {
    
    var currentEmail : String?
    var currentUser : User!
    let vm = AddContactVM()
    
    @IBOutlet weak var contactTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let observer = Signal<Bool, NoError>.Observer(
            value: { [weak self] value in
                if value == true {
                    let destVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainScreen")
                    self!.navigationController?.pushViewController(destVC, animated: true)
                }
        },
            failed: { error in
                print("Failed with error \(error)")
        })
        
        vm.output.observe(observer)
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        if let text = contactTF.text, let text1 = currentEmail {
            
            vm.currentEmail = text1
            vm.newContact = text
            
            performSegue(withIdentifier: "backToMain", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! ContactListVC
        
        destVC.currentUser = currentUser
    }
    
}
