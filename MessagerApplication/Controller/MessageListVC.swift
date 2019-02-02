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
import AVFoundation

class MessageListVC : UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textViewMsg: UITextView!
    
    @IBOutlet weak var voiceButton: UIButton!
    
    var currentContact : Contact? {
        didSet {
            vm.currentContact = currentContact
        }
    }
    
    var currentUser : User? {
        didSet {
            vm.currentUser = currentUser
        }
    }
    
    var msgList = [Message]()
    let vm = MessageListVM()
    
    
    var player : AVAudioPlayer!
    var recorder : AVAudioRecorder!
    var session : AVAudioSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            session.requestRecordPermission { [weak self] (allowed) in
                if allowed {
                    print("allowed")
                }
            }
        }
        catch {
            print("Error with session occured \(error)")
        }
        
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
        let cell : MessageCell = tableView.dequeueReusableCell(withIdentifier: "msgCell", for: indexPath) as! MessageCell
        
        cell.configure(msg: msgList[indexPath.row])
        cell.accessoryType = .none
        
        return cell
    }
    
    
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        print("pressed")
        if let text = textViewMsg.text, let sender = currentUser?.email, let reciever = currentContact?.email {
            print("valid")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "\(String(describing: currentContact!.email))"), object: nil, userInfo: [
                "text" : text,
                "sender" : sender,
                "date" : Date.init(),
                "reciever" : reciever
            ])
        }
    }
    
    @IBAction func voiceButtonPressed(_ sender: UIButton) {
        if voiceButton.titleLabel?.text == "voice" {
            voiceButton.setTitle("listen", for: .normal)
            setupRecorder(filename: "qq.m4a")
            recorder.record()
        }
        else {
            recorder.stop()
            voiceButton.setTitle("voice", for: .normal)
            if let contact = currentContact, let user = currentUser {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "\(contact.email)Voice"), object: nil, userInfo: [
                    "filename": "qq.m4a",
                    "date" : Date.init(),
                    "sender" : user.email,
                    "reciever" : contact.email
                ])
            }
        }
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "backMain", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! ContactListVC
        
        destVC.currentUser = currentUser!
    }
    
    
    
    private func setupRecorder(filename : String) {
        let audioFilename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        
        let settings = [
            AVFormatIDKey : kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey : 2,
            AVSampleRateKey : 44100.2
        ] as [String : Any]
        
        do {
            recorder = try AVAudioRecorder(url: audioFilename, format: AVAudioFormat(settings: settings)!)
            recorder.delegate = self
            recorder.prepareToRecord()
        }
        catch {
            print("Error with recorder initialization occured \(error)")
        }
    }
}
