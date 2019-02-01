//
//  RegistrationVM.swift
//  MessagerApplication
//
//  Created by Igor-Macbook Pro on 30/01/2019.
//  Copyright © 2019 Igor-Macbook Pro. All rights reserved.
//

import Foundation
import ReactiveSwift
import FirebaseFirestore
import FirebaseAuth
import Result

class RegistrationVM {
    
    var login : String? {
        didSet {
            if let log = login, let pass = password, let username = name {
                register(login: log, name: username, password: pass)
            }
        }
    }
    var password : String?
    var name : String?
    
    let (output, input) = Signal<Bool, NoError>.pipe()
    let (userOutput, userInput) = Signal<User, NoError>.pipe()
    
    private func register(login : String, name : String, password : String) {
        Auth.auth().createUser(withEmail: login, password: password) { [weak self] (result, error) in
            if error == nil {
                self!.saveUser(login: login, name: name)
            }
            else {
                print("ERROR \(String(describing: error))")
            }
        }
    }
    
    private func saveUser(login : String, name : String) {
        Firestore.firestore().collection("users").document(login).setData([
            "email" : login,
            "name" : name
        ], completion: { [weak self] error in
            if error == nil {
                self!.input.send(value: true)
                let user = User()
                user.email = login
                user.name = name
                self!.userInput.send(value: user)
            }
        })
    }
    
}
