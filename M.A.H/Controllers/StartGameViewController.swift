//
//  StartGameViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 7/25/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit
import Firebase

class StartGameViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    var session:Session?
    
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var enterLobby: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO- update this to use user defaults based on uid

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        //        if let code = userDefaults.string(forKey: "code") {
        //            FirebaseController.instance.searchSessionsByCode(code: code) { (found, newSession) in
        //                if found {
        //                    self.enterLobby.isHidden = false
        //                } else {
        //                    self.enterLobby.isHidden = true
        //                }
        //            }
        //        }
    }
    
    @IBAction func testBtn(_ sender: Any) {
        //                                FirebaseController.instance.createRequest(senderId: Auth.auth().currentUser!.uid, recieverId: session!.hostID, requestType: "join", session: session!) {
        //TODO:- NOTiFIY USER THAT IT HAS BEEN CREATED.
        print("Request has been created")
        //                                }
    }
    @IBAction func enterLobbyPressed(_ sender: Any) {
        if (userDefaults.string(forKey: "code") != (nil ?? "")) {
            self.performSegue(withIdentifier: "toLobby", sender: self)
        }
    }
    
    @available(iOS 13.0, *)
    @IBAction func startGamePressed(_ sender: Any) {
        let uid = UUID().description
        var code = ""
        let codeCharacters = Array(uid)
        var counter = 0
        while counter < 4 {
            code += String(codeCharacters[counter])
            counter += 1
        }
        //TODO:- Fix this so that it replies either on user defaults or core data
        if code.count == 4 && Auth.auth().currentUser != nil {
            userDefaults.set(code, forKey: "code")
            FirebaseController.instance.returnFirstName { (name) in
                FirebaseController.instance.createSession(code: code, hostID: Auth.auth().currentUser!.uid, host: (name))
            }
            
            
            performSegue(withIdentifier: "toLobby", sender: self)
        }
    }
    
    @IBAction func findGamePressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Find Game", message: "Enter the 4 digit Lobby Code provided by your game host", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true)
        }
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (action) in
            //Make a request to Sessions and sort by cod
            
            //TODO, IF GAME IS ACTIVE IS TRUE, STOP THEM ROM BEING ABLE TO JOIN
            
            FirebaseController.instance.searchSessionsByCode(code: alert.textFields![0].text!.uppercased(), handler: { (found, session ) in
                if found {
                    let gameConfirmationAlert = UIAlertController(title: "Game Found", message: "Host:\(session!.host). ", preferredStyle: .alert)
                    let joinAction = UIAlertAction(title: "Request to join", style: .default, handler: { (action) in
                        self.userDefaults.set(session!.code, forKey: "code")
                        
                        FirebaseController.instance.createRequest(senderId: Auth.auth().currentUser!.uid, recieverId: session!.hostID, requestType: "join", session: session!) {
                            //                                TODO:- NOTiFIY USER THAT IT HAS BEEN CREATED.
                            print("Request has been created")
                        }
                        
                        //Safely unwrap
                        FirebaseController.instance.addUserToSession(code: session!.code, userID: Auth.auth().currentUser!.uid, displayName: (Auth.auth().currentUser?.displayName ?? "Player" )!)
                        self.performSegue(withIdentifier: "toLobby", sender: self)
                        
                    })
                    gameConfirmationAlert.addAction(cancelAction)
                    gameConfirmationAlert.addAction(joinAction)
                    self.present(gameConfirmationAlert, animated: true, completion: nil)
                    print(session!)
                } else {
                    //TODO:- Add no session found alert
                    let failedSearchAlert = UIAlertController(title: "No Game Found", message: "Try again?", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in failedSearchAlert.dismiss(animated: true, completion: nil)})
                    
                    failedSearchAlert.addAction(okAction)
                    self.present(failedSearchAlert, animated: true, completion: nil)
                }
            })
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "XXXX"
        }
        alert.addAction(cancelAction)
        alert.addAction(submitAction)
        self.present(alert, animated: true)
    }
    @IBAction func signOutPressed(_ sender: Any) {
        

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
