//
//  ContactCell.swift
//  MessagerApplication
//
//  Created by Igor-Macbook Pro on 30/01/2019.
//  Copyright © 2019 Igor-Macbook Pro. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    public func configure(contact : Contact) {
        nameLabel.text = contact.name
        if contact.messages.count != 0 {
            msgLabel.text = contact.messages[contact.messages.count - 1].text
        }
    }
    
}
