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
                //self.performSegue(withIdentifier: "toStartGame", sender: self)
                 let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let navigationController:UINavigationController =  UINavigationController()
                let rootViewController:UIViewController = storyboard.instantiateViewController(withIdentifier: "StartGame")
                navigationController.viewControllers = [rootViewController]
                self.view.window?.rootViewController = navigationController
                self.view.window?.makeKeyAndVisible()

                print("successful login")
            } else {
                let loginFailedAlert = UIAlertController(title: "Login Failed", message: "An error occured while trying to log you in. Try again?", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                print(error!,"error previous")
                loginFailedAlert.addAction(okAction)
                self.present(loginFailedAlert, animated: true, completion: nil)
            }
        }
    }
}


