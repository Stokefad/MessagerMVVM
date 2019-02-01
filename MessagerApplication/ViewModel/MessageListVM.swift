//
//  MessageListVM.swift
//  MessagerApplication
//
//  Created by Igor-Macbook Pro on 31/01/2019.
//  Copyright © 2019 Igor-Macbook Pro. All rights reserved.
//

import Foundation
import FirebaseFirestore
import ReactiveSwift
import Result

class MessageListVM {
    
    let (outputInfo, inputInfo) = Signal<Bool, NoError>.pipe()
    
    var currentUser : String? {
        didSet {
            inputInfo.send(value: true)
        }
    }
    var currentContact : String? {
        didSet {
            NotificationCenter.default.addObserver(self, selector: #selector(getMessage(notification:)), name: Notification.Name(rawValue: "\(String(describing: currentContact!))"), object: nil)
            print("HOW MUCH")
            inputInfo.send(value: true)
        }
    }
    
    init() {
        
        var counter = 0
        
        let observer = Signal<Bool, NoError>.Observer(
            value : { [weak self] value in
                counter += 1
                if counter == 2 {
                    self!.retrieveMessages()
                }
        },
            failed: { error in
                print("error occured \(error)")
        })
        
        outputInfo.observe(observer)
    }
    
    deinit {
        print("deinited")
        NotificationCenter.default.removeObserver(self)
    }
    
    let db = Firestore.firestore().collection("users")
    
    let (output, input) = Signal<[Message], NoError>.pipe()
    
    
    @objc private func getMessage(notification : Notification) {
        if let text = notification.userInfo!["text"] as? String, let date = notification.userInfo!["date"] as? Date, let sender = notification.userInfo!["sender"] as? String, let reciever = notification.userInfo!["reciever"] as? String {
            let msg = Message()
            
            msg.date = date
            msg.sender = sender
            msg.text = text
            msg.reciever = reciever

            saveMessage(message: msg)
        }
    }
    
    
    private func retrieveMessages() {
        if let user = currentUser, let contact = currentContact {
            db.document(user).collection("contacts").document(contact).collection("messages").addSnapshotListener { [weak self] (snapshot, error) in
                if let docs = snapshot?.documents {
                    
                    var msgArr = [Message]()
                    
                    for item in docs {
                        let message = Message()
                        message.date = item["date"] as! Date
                        message.sender = item["sender"] as! String
                        message.text = item["text"] as! String
                        
                        msgArr.append(message)
                    }
                    msgArr.sort(by: { (msg1, msg2) -> Bool in
                        return msg1.date < msg2.date
                    })
                    print("sending info")
                    self!.input.send(value: msgArr)
                }
            }
        }
        else {
            print("e erorr here")
        }
    }
    
    private func saveMessage(message : Message) {
        
        print("Cuurent contact \(String(describing: currentContact))")
        
        if let user = currentUser {
            db.document(user).collection("contacts").document(message.reciever).collection("messages").addDocument(data: [
                "sender" : message.sender,
                "date" : message.date,
                "text" : message.text,
                "reciever" : message.reciever
            ]) { (error) in
                if error != nil {
                    print("Error occured \(String(describing: error))")
                }
            }
            
            db.document(message.reciever).collection("contacts").document(user).getDocument { [weak self] (snapshot, error) in
                if snapshot?.data() == nil {
                    self!.db.document(message.reciever).collection("contacts").document(user).setData([
                        "email" : user,
                        "name" : "undefined"
                    ])
                }
            }
            
            db.document(message.reciever).collection("contacts").document(user).collection("messages").addDocument(data: [
                "sender" : message.sender,
                "date" : message.date,
                "text" : message.text,
                "reciever" : message.reciever
            ]) { (error) in
                if error != nil {
                    print("Error occured \(String(describing: error))")
                }
            }
        }
    }
    
}
