//
//  SettingsViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 4/29/23.
//  Copyright © 2023 Kadeem Palacios. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    
    var label: UILabel!
    
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    

    override func viewWillAppear(_ animated: Bool) {
        signOutButton.layer.cornerRadius = signOutButton.frame.height/6
        signOutButton.layer.borderWidth = 1
        signOutButton.layer.borderColor = UIColor.purple.cgColor
        deleteAccountButton.layer.cornerRadius = signOutButton.frame.height/6
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//addSlideDownReminderLabel()
        // Do any additional setup after loading the view.
    }
    
    func addSlideDownReminderLabel() {
        // Create the label
               label = UILabel()
               label.text = "SLIDE DOWN"
               label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
               label.textColor = .white
               label.textAlignment = .center
               label.alpha = 0
               label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
               
               // Add the label to the view
               view.addSubview(label)
               
               // Set up the timer to trigger the animation
               Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(startAnimation), userInfo: nil, repeats: true)
        
    }
    
    @objc func startAnimation() {
          
          // Animate the label's alpha and scale
          UIView.animate(withDuration: 3, animations: {
              self.label.alpha = 1
              self.label.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
              self.label.textColor = .red
          }) { (finished) in
              UIView.animate(withDuration: 1, animations: {
                  self.label.alpha = 0
                  self.label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                  self.label.textColor = .white
              })
          }
      }
  
    

    @IBAction func signOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error)
        }
        AppDelegate.shared.loadLoadLoginScreen(window: AppDelegate.shared.window!)
    }
    
    @IBAction func deleteAccountPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Are you sure", message: "This will delete your account and you'll be signed out. This cannot be undone.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            
            //TODO:- Add code to delete user from realtime database
            let user = Auth.auth().currentUser

            user?.delete { error in
              if let error = error {
                // An error happened.
              } else {
                // Account deleted.
                  AppDelegate.shared.loadLoadLoginScreen(window: AppDelegate.shared.window!)
              }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
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
