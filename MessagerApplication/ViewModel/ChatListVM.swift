//
//  ChatListVM.swift
//  MessagerApplication
//
//  Created by Igor-Macbook Pro on 30/01/2019.
//  Copyright © 2019 Igor-Macbook Pro. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import FirebaseFirestore

class ChalListVM {
    
    var currentUser : User!
    let (output, input) = Signal<[Contact], NoError>.pipe()
    var contactBuffer : [Contact] = [Contact]()
    
    init(user : User) {
        currentUser = user
        retrieveContacts()
    }
    
    
    private func retrieveContacts() {
        
        let dbref = Firestore.firestore().collection("users").document(currentUser.email).collection("contacts")
        
        dbref.addSnapshotListener { (snapshot, error) in
            if let docs = snapshot?.documents {
                for item in docs {
                    let contact = Contact()
                    
                    contact.email = item["email"] as! String
                    contact.name = item["name"] as! String
                    
                    print(contact.email)
                    
                    dbref.document(contact.email).collection("messages").getDocuments(completion: { (snapshot, error) in
                        if let msgs = snapshot?.documents {
                            var msgArray : [Message] = [Message]()
                            print("here")
                            for item in msgs {
                                let message = Message()
                                
                                message.date = item["date"] as! Date
                                message.sender = item["sender"] as! String
                                message.text = item["text"] as! String
                                
                                msgArray.append(message)
                            }
                            msgArray.sort(by: { (msg1, msg2) -> Bool in
                                return msg1.date < msg2.date
                            })
                            
                            contact.messages = msgArray
                            self.getUniqueContacts(newItem: contact)
                            self.input.send(value: self.contactBuffer)
                        }
                    })
                }
            }
        }
    }
    
    
    private func getUniqueContacts(newItem : Contact) {
        var counter = 0
        if contactBuffer.count == 0 {
            contactBuffer.append(newItem)
        }
        for i in 0 ... contactBuffer.count - 1 {
            if contactBuffer[i].email == newItem.email {
                contactBuffer[i] = newItem
                counter += 1
            }
        }
        
        if counter == 0 {
            contactBuffer.append(newItem)
        }
        
        contactBuffer.sort { (cnt1, cnt2) -> Bool in
            if cnt1.messages.count > 1, cnt2.messages.count > 1 {
                return cnt1.messages[cnt1.messages.count - 1].date > cnt2.messages[cnt2.messages.count - 1].date
            }
            else if cnt1.messages.count < 1, cnt2.messages.count > 1 {
                return cnt1.date > cnt2.messages[cnt2.messages.count - 1].date
            }
            else if cnt1.messages.count > 1, cnt2.messages.count < 1 {
                return cnt1.messages[cnt1.messages.count - 1].date > cnt2.date
            }
            else {
                return cnt1.date > cnt2.date
            }
        }
    }
    
}
