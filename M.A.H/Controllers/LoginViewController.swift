//
//  ViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 6/27/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//


import UIKit


class LoginViewController: UIViewController {


    @IBOutlet var emailTxtField: UITextField!
    @IBOutlet var passwordTxtField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func loginBtnPressed(_ sender: Any) {
        FirebaseController.instance.loginUser(withEmail: emailTxtField.text!, andPassword: passwordTxtField.text!) { (success, error) in
            if success {
                self.performSegue(withIdentifier: "toStartGame", sender: self)
                print("successful login")
            } else {
                print(error)
            }
        }
    }
}


