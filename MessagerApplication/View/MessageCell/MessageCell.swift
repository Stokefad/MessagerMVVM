//
//  MessageCell.swift
//  MessagerApplication
//
//  Created by Igor-Macbook Pro on 31/01/2019.
//  Copyright © 2019 Igor-Macbook Pro. All rights reserved.
//

import UIKit
import AVFoundation
import ReactiveSwift
import Result

class MessageCell: UITableViewCell, AVAudioPlayerDelegate {
    
    @IBOutlet weak var textView: UITextView!
    let vm = MessageListVM()
    var player : AVAudioPlayer!
    
    var id : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        NotificationCenter.default.addObserver(self, selector: #selector(executeIt), name: Notification.Name(rawValue: "go"), object: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        
    
    @objc private func executeIt(notification : Notification) {
        if let data = notification.userInfo!["data"] as? Data {
            setupPlayer(data: data)
            player.play()
        }
    }
    
    @objc private func playButtonPressed(sender : UIButton) {
        print("pressed")
        if let id = id {
            print("id is valid")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "cool"), object: nil, userInfo: [
                "id" : id
            ])
        }
    }
    
    
    public func configure(msg : Message) {
        if msg.isVoice == false {
            textView.text = msg.text
        }
        else {
            textView.isHidden = true
            id = msg.id
            let button = UIButton()
            
            button.frame = CGRect(x: 70, y: 10, width: 70, height: 70)
            button.setTitle("Listen", for: .normal)
            button.backgroundColor = UIColor.red
            button.addTarget(self, action: #selector(playButtonPressed(sender:)), for: .touchUpInside)
            self.addSubview(button)
        }
    }
    
    
    private func setupPlayer(data : Data) {
        do {
            player = try AVAudioPlayer(data: data)
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
        }
        catch {
            print("Error with player initialization occured \(error)")
        }
    }
    
}
