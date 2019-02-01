//
//  MessageListVC.swift
//  MessagerApplication
//
//  Created by Igor-Macbook Pro on 31/01/2019.
//  Copyright © 2019 Igor-Macbook Pro. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

class MessageListVC : UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textViewMsg: UITextView!
    
    var currentContact : Contact? {
        didSet {
            vm.currentContact = currentContact?.email
        }
    }
    
    var currentUser : User? {
        didSet {
            vm.currentUser = currentUser?.email
        }
    }
    
    var msgList = [Message]()
    
    let vm = MessageListVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "msgCell")
        
        let msgObserver = Signal<[Message], NoError>.Observer(
            value: { [weak self] value in
                self!.msgList = value
                self!.tableView.reloadData()
        },
            failed: { error in
                print("Failed to load messages \(error)")
        })
        
        vm.output.observe(msgObserver)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "msgCell", for: indexPath) as! MessageCell
        
        cell.configure(msg: msgList[indexPath.row])
        
        return cell
    }
    
    
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        if let text = textViewMsg.text, let sender = currentUser?.email, let reciever = currentContact?.email {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "\(String(describing: currentContact!.email))"), object: nil, userInfo: [
                "text" : text,
                "sender" : sender,
                "date" : Date.init(),
                "reciever" : reciever
            ])
        }
    }
    
    
    @IBAction func voiceButtonPressed(_ sender: UIButton) {
        
    }
    
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "backMain", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! ContactListVC
        
        destVC.currentUser = currentUser!
    }
}

