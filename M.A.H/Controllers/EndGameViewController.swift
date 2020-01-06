//
//  EndGameViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 12/29/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit

class EndGameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.layer.cornerRadius = 15
        returnToLobbyBtn.layer.cornerRadius = 10
        restartGameBtn.layer.cornerRadius = 10

        let deadline = DispatchTime.now() + 6
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.dismiss(animated: true, completion: nil)
        }

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var returnToLobbyBtn: UIButton!

    @IBOutlet var restartGameBtn: UIButton!

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func restartGamePressed(_ sender: Any) {

        let notificationCenter = NotificationCenter.default
                self.dismiss(animated: true)
        notificationCenter.post(name:  Notification.Name("startNewGame"), object: nil)


    }
    @IBAction func returnToLobbyPressed(_ sender: Any) {
        let notificationCenter = NotificationCenter.default
                self.dismiss(animated: true)
        notificationCenter.post(name: Notification.Name("returnToLobby"), object: nil)



    }
}
