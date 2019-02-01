//
//  LoginVM.swift
//  MessagerApplication
//
//  Created by Igor-Macbook Pro on 30/01/2019.
//  Copyright © 2019 Igor-Macbook Pro. All rights reserved.
//

import Foundation
import FirebaseAuth
import ReactiveSwift
import Result
import FirebaseFirestore

class LoginVM {
    
    var email : String? {
        didSet {
            if let emailText = email, let pass = password {
                loginUser(email: emailText, pass: pass)
            }
        }
    }
    var password : String?
    
    let (curInfo, inputInfo) = Signal<User, NoError>.pipe()
    
    private func loginUser(email : String, pass : String) {
        Firestore.firestore().collection("users").document(email).getDocument { [weak self] (snapshot, error) in
            if let data = snapshot?.data() {
                Auth.auth().signIn(withEmail: email, password: pass, completion: { (result, error) in
                    if error == nil {
                        print("signed")
                        let user = User()
                        user.email = email
                        user.name = data["name"] as! String
                        self!.inputInfo.send(value: user)
                    }
                    else {
                        print("Error occured \(String(describing: error))")
                    }
                })
            }
            else {
                print("ERROR")
            }
        }
    }
    
}
