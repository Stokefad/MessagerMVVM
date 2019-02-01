//
//  ContactListVC.swift
//  MessagerApplication
//
//  Created by Igor-Macbook Pro on 30/01/2019.
//  Copyright © 2019 Igor-Macbook Pro. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

class ContactListVC : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var contactList : [Contact] = [Contact]()
    
    var currentUser : User!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vm = ChalListVM(user: currentUser)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "contactCell")
        
        let observer = Signal<[Contact], NoError>.Observer(
            value : { [weak self] value in
                self!.contactList = value
                self!.tableView.reloadData()
        },
            failed : { error in
                print("Error occured \(error)")
        })
        
        vm.output.observe(observer)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactCell
        
        cell.configure(contact: contactList[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToMsg", sender: self)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToAdd", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToMsg" {
            let destVC = segue.destination as! MessageListVC
            
            destVC.currentContact = contactList[(tableView.indexPathForSelectedRow?.row)!]
            destVC.currentUser = currentUser
        }
        else {
            let destVC = segue.destination as! AddContactVC
            
            destVC.currentUser = currentUser
            destVC.currentEmail = currentUser.email
        }
    }
    
    
}
