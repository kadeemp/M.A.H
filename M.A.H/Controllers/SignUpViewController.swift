//
//  SignUpViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 7/25/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet var emailTxtField: UITextField!
    @IBOutlet var passwordTxtField: UITextField!
    @IBOutlet var firstNameTxTField: UITextField!
    @IBOutlet var lastNameTxtField: UITextField!
    @IBOutlet var displayName: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error)
        }
    }

    @IBAction func submitTxtField(_ sender: Any) {
        FirebaseController.instance.registerUser(firstName: firstNameTxTField.text!, lastName: lastNameTxtField.text!
        , displayName:displayName.text!, email: emailTxtField.text!, password: passwordTxtField.text! ) { (complete, error) in
            if complete {
                print("successful registration")
                if let user = Auth.auth().currentUser {
                    var userData:[String:Any] = [:]
                    userData["email"] = self.emailTxtField.text!
                    userData["firstName"] = self.firstNameTxTField.text!
                    let fullName = self.firstNameTxTField.text! + " "
                        + self.lastNameTxtField.text!
                    userData["fullName"] = fullName
                    FirebaseController.instance.createDBUser(uid: user.uid, userData: userData)
                    print("user saved to database")
                } else {
                    print("Error signing user in during registration")
                }


            } else {
                print(error)
            }
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
