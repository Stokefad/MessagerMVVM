//
//  ProfileVM.swift
//  MessagerApplication
//
//  Created by Igor-Macbook Pro on 02/02/2019.
//  Copyright © 2019 Igor-Macbook Pro. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import FirebaseStorage
import FirebaseFirestore

class ProfileVM {
    
    var currentUser : String? {
        didSet {
            producer = SignalProducer { [weak self] (observer, lifetime) in
                self!.sendInfo(producerCompletion: { (user) in
                    observer.send(value: user)
                })
            }
        }
    }
    
    var producer : SignalProducer<User, NoError>!
    
    private func sendInfo(producerCompletion : @escaping (_ user : User) -> ()) {
        if let user = currentUser {
            Firestore.firestore().collection("users").document(user).getDocument { (snapshot, error) in
                if let doc = snapshot?.data() {
                    let user = User()
                    
                    user.email = doc["email"] as! String
                    user.name = doc["name"] as! String
                    
                    producerCompletion(user)
                }
            }
        }
    }
    
}
