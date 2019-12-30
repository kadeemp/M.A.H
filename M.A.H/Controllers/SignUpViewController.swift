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

    @IBOutlet var submitBtn: UIButton!

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
        submitBtn.isEnabled = false
        let fullName = self.firstNameTxTField.text! + " "
            + self.lastNameTxtField.text!
        FirebaseController.instance.registerUser(firstName: firstNameTxTField.text!, lastName: lastNameTxtField.text!
        , displayName:fullName,  email: emailTxtField.text!, password: passwordTxtField.text! ) { (complete, error) in
            if complete {
                print("successful registration")
                FirebaseController.instance.loginUser(withEmail: self.emailTxtField.text!, andPassword: self.passwordTxtField.text!, completion: { (loginComplete, error) in
                    if loginComplete {
                        //self.performSegue(withIdentifier: "toStartGame", sender: self)
                        var userData:[String:Any] = [:]
                        userData["email"] = self.emailTxtField.text!
                        userData["firstName"] = self.firstNameTxTField.text!

                        userData["fullName"] = fullName
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = fullName
                        changeRequest?.commitChanges(completion: { (error) in
                            if error != nil {
                                print(error)
                                print("error commiting profile changes")
                            }
                        })
                        FirebaseController.instance.createDBUser(uid: Auth.auth().currentUser!.uid.stripID(), userData: userData)
                        print("user saved to database")
                         let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let navigationController:UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
                        let rootViewController:UIViewController = storyboard.instantiateViewController(withIdentifier: "StartGame")
                        navigationController.viewControllers = [rootViewController]
                        self.view.window?.rootViewController = navigationController
                        self.view.window?.makeKeyAndVisible()

                    } else {
                        print("Error signing user in during registration")
                        print(error)
                    }
                })

            } else {
                self.submitBtn.isEnabled = true
                print(error)
            }
        }
    }

}
