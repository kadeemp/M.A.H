//
//  LobbyViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 7/26/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit
import Firebase

class LobbyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let defaults = UserDefaults.standard
    var users:[String] = []
    var session:Session?

    override func viewDidLoad() {
        super.viewDidLoad()
        lobbyTableView.dataSource = self
        lobbyTableView.delegate = self

        lobbyCodeLabel.text = defaults.string(forKey: "code") ?? "Code not set"
        
        FirebaseController.instance.loadLobby(by: defaults.string(forKey: "code") ?? "") { (session ) in
            self.hostLabel.text = "\(session.members.count)/6"
            self.session = session
            print(session.members)
            for member in session.members {
                FirebaseController.instance.returnDisplayName(userID:member , completion: { (fullName) in
                    // && fullName != session.host
                    if !self.users.contains(fullName)  {
                        self.users.append(fullName)
                        self.lobbyTableView.reloadData()
                    }
                })
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet var lobbyCodeLabel: UILabel!
    @IBOutlet var hostLabel: UILabel!
    @IBOutlet var lobbyTableView: UITableView!
    @IBAction func showMemes(_ sender: Any) {
        performSegue(withIdentifier: "showMemes", sender: self)
    }
    @IBAction func showPrompts(_ sender: Any) {
        performSegue(withIdentifier: "showPrompts", sender: self)
    }

    @IBAction func createGame(_ sender: Any) {
    }

    @IBAction func leaveLobby(_ sender: Any) {
        defaults.set("", forKey: "code")
        self.dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = lobbyTableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text   = users[indexPath.row]
        if let session = session {
            if let user = Auth.auth().currentUser?.uid {
                if session.id == user {
                    cell?.textLabel?.textColor = UIColor.orange
                }
            }

        }
        return cell!
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if let session = session {
            if let userID = Auth.auth().currentUser?.uid {
                if (session.id == userID) && session.members[indexPath.row] != userID  {
                    return .delete
                }
                else {
                    return .none
                }
            }

        }
        return .none
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            users.remove(at: indexPath.row)
            lobbyTableView.deleteRows(at: [indexPath], with: .fade)
            if let session = session {
                var members = session.members
                members.remove(at: indexPath.row)
                FirebaseController.instance.removeMemberFrom(session: session, members: members, completion: {
                    self.lobbyTableView.reloadData()
                })
            }
        }
    }

}
