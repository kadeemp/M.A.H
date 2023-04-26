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
    @IBOutlet var startGame: UIButton!
    @IBOutlet var lobbyCodeLabel: UILabel!
    
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var hostLabel: UILabel!
    @IBOutlet weak var tableViewHeaderView: UIView!
    @IBOutlet var lobbyTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        questionButton.setTitle("", for: .normal)
        questionButton.setTitle("", for: .selected)
        questionButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 0) // Move the text label to the right
        lobbyTableView.layer.cornerRadius = lobbyTableView.frame.height/9
        lobbyTableView.layer.borderWidth = 1
        lobbyTableView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7).cgColor
        
        lobbyTableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableViewHeaderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        startGame.layer.cornerRadius = startGame.frame.height/8
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        lobbyTableView.dataSource = self
        lobbyTableView.delegate = self
        
        if let code = defaults.string(forKey: "code") {
            lobbyCodeLabel.text = "Lobby ID: \(code)"
        } else {
            lobbyCodeLabel.text = "Code not set"
        }

        
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

        print(1)
        //
//        if let session = session {
//
//            if let user = Auth.auth().currentUser?.uid {
//
//                if user == session.hostID {
//                    //  TODO:- Create an alert that lets them know this will kill the room. or reassign the host
//                } else if session.members.count == 1 {
//                    //TODO:- Delete the session
//                }
//                FirebaseController.instance.removeMemberFrom(session: session, memberID: user) { (mems) in
//
//                    self.navigationController?.popViewController(animated: true)
//                    self.defaults.set("", forKey: "code")
//                }
//            }
//        }
    }
    
    @IBAction func questionButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "How to start a game", message: "To start a game, you must have at least two other players. Steps to start: \n 1. Have friends download the game, \n 2. Sign up, \n 3. (Friend) Click 'Find Game', \n 4. Give them your lobby ID ", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    

    @IBAction func showMemes(_ sender: Any) {
        performSegue(withIdentifier: "showMemes", sender: self)
    }
    @IBAction func showPrompts(_ sender: Any) {
        performSegue(withIdentifier: "showPrompts", sender: self)
    }

    @IBAction func createGame(_ sender: Any) {

        if let session = session {
            print("DONT FORGET TO ADD LOBBY MINIMUM", #function)
//TODO:- CHANGE TO 3

            if session.members.count >= 3 {
                //create game
                //performSegue
                FirebaseController.instance.createGame(session: session) { returnedGame in
                    self.game = returnedGame

                }
            } else {
                //TODO:- Create an alert to let user know they can't start a game without
                let alertController = UIAlertController(title: "Lobby Minimum Not Met", message: "You must have at least 2 other players in your lobby to start a game", preferredStyle: .alert)

                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertController.addAction(okAction)

                present(alertController, animated: true, completion: nil)

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
