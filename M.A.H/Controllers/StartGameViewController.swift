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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func startGamePressed(_ sender: Any) {
    }
    @IBAction func findGamePressed(_ sender: Any) {

        let alert = UIAlertController(title: "Find Game", message: "Enter the 4 digit Lobby Code provided by your game host", preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (action) in
            //Make a request to Sessions and sort by code
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true)
        }
        alert.addTextField { (textField) in
            textField.placeholder = "XXXX"
        }
        alert.addAction(cancelAction)
        alert.addAction(submitAction)
        self.present(alert, animated: true)
    }
    @IBAction func signOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error)
        }
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
