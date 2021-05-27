//
//  LobbyViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 7/26/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit
import Firebase

@available(iOS 13.0, *)
class LobbyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let defaults = UserDefaults.standard
    var users:[String] = []
    var session:Session?
    var game:Game!
    var gamehasLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        lobbyTableView.dataSource = self
        lobbyTableView.delegate = self



        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Leave Lobby", style: .plain, target: self, action: #selector(leaveLobby(_:)))
        lobbyCodeLabel.text = defaults.string(forKey: "code") ?? "Code not set"
        
        FirebaseController.instance.loadLobby(by: defaults.string(forKey: "code") ?? "") { (session) in
            if session.members.count > 1 {
                //TODO: add them as a host and start new member group with them
                //or kick them and make them start another
            }

            if let user = Auth.auth().currentUser?.uid {
               
                if session.hostID == user {

                } else {
                    self.startGame.isHidden = true
                }
            }


            self.hostLabel.text = "\(session.members.count)/6"
            self.session = session
            if session.isActive {
                if self.gamehasLoaded == false {
                    self.gamehasLoaded = !self.gamehasLoaded
                    if self.game != nil {
                        self.performSegue(withIdentifier: "toGameScreen", sender: self)
                    } else {
                        FirebaseController.instance.returnGameSession(session: session) { (returnedGame) in
                            self.game = returnedGame
                            self.performSegue(withIdentifier: "toGameScreen", sender: self)
                        }
                    }
                }
            }
            for member in session.members.keys {
                //TODO: SAFELY UNWRAP
                if !self.users.contains(session.members[member]!["name"]! as! String) {
                    self.users.append((session.members[member]!["name"]! as! String))
                }

            }
            self.lobbyTableView.reloadData()
            //            for member in session.members {
            //                FirebaseController.instance.returnDisplayName(userID:member , completion: { (fullName) in
            //                    // && fullName != session.host
            //                    if !self.users.contains(fullName)  {
            //                        self.users.append(fullName)
            //                        self.lobbyTableView.reloadData()
            //                    }
            //                })
            //            }
        }
        // Do any additional setup after loading the view.
    }
    @objc func leaveLobby() {

        if let session = session {

            if let user = Auth.auth().currentUser?.uid {

                if user == session.hostID {
                    //  TODO:- Create an alert that lets them know this will kill the room. or reassign the host
                } else if session.members.count == 1 {
                    //TODO:- Delete the session
                }
                FirebaseController.instance.removeMemberFrom(session: session, memberID: user) { (mems) in

                    self.navigationController?.popViewController(animated: true)
                    self.defaults.set("", forKey: "code")
                }
            }
        }
    }
    
    @IBOutlet var startGame: UIButton!
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

        if let session = session {
            //Change back to 2


            if session.members.count >= 3 {
                //create game
                //performSegue
                FirebaseController.instance.createGame(session: session) { returnedGame in
                    self.game = returnedGame

                }
            } else {
                //TODO:- Create an alert to let user know they can't start a game without
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGameScreen" {
            let destVC = segue.destination as! GameScreenViewController
            destVC.session = session!
            destVC.game = self.game
        }
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
                //                if session.hostID == session.members[indexPath.row] {
                //                    cell?.textLabel?.textColor = UIColor.orange
                //                } else {
                //                    cell?.textLabel?.textColor = UIColor.black
                //                }
            }
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if let session = session {
            if let userID = Auth.auth().currentUser?.uid {
                //                if (session.hostID == userID) && session.members[indexPath.row] != userID  {
                //                    return .delete
                //                }
                //                else {
                //                    return .none
                //                }
            }

        }
        return .none
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            users.remove(at: indexPath.row)
            lobbyTableView.deleteRows(at: [indexPath], with: .fade)
            //            if let session = session {
            //                var members = session.members
            //                FirebaseController.instance.removeMemberFrom(session: session, memberID: session.members[indexPath.row]) {(mems) in
            //                    self.lobbyTableView.reloadData()
            //                }
            //            }
        }
    }

}
