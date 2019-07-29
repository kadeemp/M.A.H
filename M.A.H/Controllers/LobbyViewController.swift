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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = lobbyTableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text   = users[indexPath.row]
        return cell!
    }

    let defaults = UserDefaults.standard
    var users:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        lobbyTableView.delegate = self

        lobbyCodeLabel.text = defaults.string(forKey: "code") ?? "Code not set"
        
        FirebaseController.instance.loadLobby(by: defaults.string(forKey: "code") ?? "") { (session ) in
            self.hostLabel.text = session.host
            print(session.members)
            for member in session.members {
                FirebaseController.instance.returnDisplayName(userID:member , completion: { (fullName) in
                    if !self.users.contains(fullName) && fullName != session.host {
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
