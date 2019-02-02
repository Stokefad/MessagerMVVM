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
import FirebaseStorage

class MessageListVM {
    
    let (outputInfo, inputInfo) = Signal<Bool, NoError>.pipe()
    
    let (voiceOutput, voiceInput) = Signal<Bool, NoError>.pipe()
    
    var voiceMessagesCounter = 0
    
    var currentUser : User? {
        didSet {
            inputInfo.send(value: true)
            print("got it")
        }
    }
    var currentContact : Contact? {
        didSet {
            NotificationCenter.default.addObserver(self, selector: #selector(saveMessage(notification:)), name: Notification.Name(rawValue: "\(String(describing: currentContact!.email))"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(getFileName(notification:)), name: Notification.Name(rawValue: "\(currentContact!.email)Voice"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(getVoiceMsgId(notification:)), name: Notification.Name(rawValue: "cool"), object: nil)
            print("HOW MUCH")
            inputInfo.send(value: true)
            print("got it")
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
    
    let db = Firestore.firestore().collection("users")
    
    let (output, input) = Signal<[Message], NoError>.pipe()
    
    
    @objc private func saveMessage(notification : Notification) {
        print("here")
        if let text = notification.userInfo!["text"] as? String, let date = notification.userInfo!["date"] as? Date, let sender = notification.userInfo!["sender"] as? String, let reciever = notification.userInfo!["reciever"] as? String {
            let msg = Message()
            
            msg.date = date
            msg.sender = sender
            msg.text = text
            msg.reciever = reciever

            saveMessage(message: msg)
        }
    }
    
    @objc private func getFileName(notification : Notification) {
        if let text = notification.userInfo!["filename"] as? String, let sender = notification.userInfo!["sender"] as? String, let reciever = notification.userInfo!["reciever"] as? String, let date = notification.userInfo!["date"] as? Date {
            let msg = Message()
            
            msg.date = date
            msg.sender = sender
            msg.reciever = reciever
            msg.text = " "
            
            saveVoiceMessage(msg: msg, path: text)
        }
    }
    
    @objc private func getVoiceMsgId(notification : Notification) {
        if let id = notification.userInfo!["id"] as? String {
            retrieveVoiceMessage(id: id)
        }
    }
    
    private func retrieveMessages() {
        if let user = currentUser, let contact = currentContact {
            db.document(user.email).collection("contacts").document(contact.email).collection("messages").addSnapshotListener { [weak self] (snapshot, error) in
                if let docs = snapshot?.documents {
                    
                    var msgArr = [Message]()
                    
                    for item in docs {
                        let message = Message()
                        message.date = item["date"] as! Date
                        message.sender = item["sender"] as! String
                        message.text = item["text"] as! String
                        message.isVoice = item["isVoice"] as! Bool
                        message.id = item["id"] as! String
                        message.reciever = item["reciever"] as! String
                        
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
    
    private func saveVoiceMessage(msg : Message, path : String) {
        voiceMessagesCounter += 1
        if let user = currentUser, let contact = currentContact {
            
            let id = Firestore.firestore().collection("usertress").document(user.email).collection("contacts").document(contact.email).collection("messages").addDocument(data: [
                "" : ""
                ]).documentID
            
            Firestore.firestore().collection("users").document(user.email).collection("contacts").document(contact.email).collection("messages").document(id).setData([
                "isVoice" : true,
                "sender" : msg.sender,
                "date" : msg.date,
                "text" : msg.text,
                "reciever" : msg.reciever,
                "id" : id
            ])
            
                Firestore.firestore().collection("users").document(msg.reciever).collection("contacts").document(user.email).getDocument { [weak self] (snapshot, error) in
                if snapshot?.data() == nil {
                    self!.db.document(msg.reciever).collection("contacts").document(user.email).setData([
                        "email" : user.email,
                        "name" : user.name
                    ])
                }
            }
            Firestore.firestore().collection("users").document(contact.email).collection("contacts").document(user.email).collection("messages").document(id).setData([
                "isVoice" : true,
                "sender" : msg.sender,
                "date" : msg.date,
                "text" : msg.text,
                "reciever" : msg.reciever,
                "id" : id
            ])
            
            let ref = Storage.storage().reference().child("messages").child("\(id).m4a")
            
            ref.putFile(from: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(path), metadata: nil) { (metadata, error) in
                if error == nil {
                    print("Sended!")
                }
            }
        }
    }
    
    private func retrieveVoiceMessage(id : String) {
        Storage.storage().reference().child("messages").child("\(id).m4a").getData(maxSize: 1 * 1024 * 1024 * 8) { [weak self] (data, error) in
            if let data = data {
                FileManager.default.createFile(atPath: "voice.m4a", contents: data, attributes: nil)
                self!.voiceInput.send(value: true)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "go"), object: nil, userInfo: [
                    "data" : data
                ])
            }
        }
    }
    
    private func saveMessage(message : Message) {
        
        print("Cuurent contact \(String(describing: currentContact))")
        
        if let user = currentUser {
            db.document(user.email).collection("contacts").document(message.reciever).collection("messages").addDocument(data: [
                "sender" : message.sender,
                "date" : message.date,
                "text" : message.text,
                "reciever" : message.reciever,
                "isVoice" : false,
                "id" : "notVoice"
            ]) { (error) in
                if error != nil {
                    print("Error occured \(String(describing: error))")
                }
            }
            
            db.document(message.reciever).collection("contacts").document(user.email).getDocument { [weak self] (snapshot, error) in
                if snapshot?.data() == nil {
                    self!.db.document(message.reciever).collection("contacts").document(user.email).setData([
                        "email" : user.email,
                        "name" : user.name
                    ])
                }
            }
            
            db.document(message.reciever).collection("contacts").document(user.email).collection("messages").addDocument(data: [
                "sender" : message.sender,
                "date" : message.date,
                "text" : message.text,
                "reciever" : message.reciever,
                "isVoice" : false,
                "id" : "notVoice"
            ]) { (error) in
                if error != nil {
                    print("Error occured \(String(describing: error))")
                }
            }
        }
    }
    
}
