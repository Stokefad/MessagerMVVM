//
//  AddContact.swift
//  MessagerApplication
//
//  Created by Igor-Macbook Pro on 30/01/2019.
//  Copyright © 2019 Igor-Macbook Pro. All rights reserved.
//

import Foundation
import FirebaseFirestore
import ReactiveSwift
import Result

class AddContactVM {
    
    var currentEmail : String?
    var newContact : String? {
        didSet {
            if let text = newContact {
                getNewContact(email: text)
            }
        }
    }
    var contact : Contact? {
        didSet {
            if let cont = contact {
                saveNewContact(contact: cont)
            }
        }
    }
    
    let (output, input) = Signal<Bool, NoError>.pipe()
    
    
    private func saveNewContact(contact : Contact) {
        if let text = currentEmail {
            Firestore.firestore().collection("users").document(text).collection("contacts").document(contact.email).setData([
                "name" : contact.name,
                "email" : contact.email,
                "date" : Date.init()
            ]) { [weak self] (error) in
                if error != nil {
                    self!.input.send(value: false)
                }
                else {
                    self!.input.send(value: true)
                }
            }
        }
    }
    
    private func getNewContact(email : String) {
        print("here")
        Firestore.firestore().collection("users").document(email).getDocument(completion: { [weak self] (snapshot, error) in
            if let doc = snapshot?.data() {
                let cont = Contact()
                
                cont.email = doc["email"] as! String
                cont.name = doc["name"] as! String
                
                self!.contact = cont
            }
            else {
                self!.input.send(value: false)
            }
        })
    }
    
}
