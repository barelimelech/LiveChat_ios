//
//  ChatViewController.swift
//
//  Created by Bar Elimelech on 05/02/2025.


import UIKit
import FirebaseAuth
import FirebaseFirestoreInternal

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = [
        Message(sender: "bar@gmail.com", body: "hello"),
        Message(sender: "amit@gmail.com", body: "hey"),
        Message(sender: "adam@gmail.com", body: "how are you?")

    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        title = Constants.appName
        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        
        loadMessages()
    }
    
    func loadMessages() {
        db.collection(Constants.FStore.collectionName).addSnapshotListener() { (querySnapshot, error) in
            self.messages = []

                if let e = error {
                print("Error getting documents: \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let messageSender = data[Constants.FStore.senderField] as? String, let messageBody = data[Constants.FStore.bodyField] as? String {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
//        do {
//            messages = []
//            let snapshot = try await db.collection(Constants.FStore.collectionName).getDocuments()
//          for document in snapshot.documents {
//            print("\(document.documentID) => \(document.data())")
//          }
//        } catch {
//          print("Error getting documents: \(error)")
//        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let massageBody = messageTextfield.text, let senderEmail = Auth.auth().currentUser?.email {
            db.collection(Constants.FStore.collectionName).addDocument(data: [Constants.FStore.senderField: senderEmail, Constants.FStore.bodyField: massageBody]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore: \(e)")
                } else {
                    print("Successfully saved data")
                }
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }

}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = messages[indexPath.row].body
        return cell
    }
    
}

