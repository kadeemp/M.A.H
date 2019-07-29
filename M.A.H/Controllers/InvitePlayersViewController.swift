//
//  InvitePlayersViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 7/26/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit

class InvitePlayersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {



    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: Create custom navbar button for skip
        // Do any additional setup after loading the view.

    }
    
    @IBOutlet var invitedListLabel: UILabel!
    @IBOutlet var invitedPlayersTableView: UITableView!
    @IBAction func invitePlayers(_ sender: Any) {

    }

    //MARK:- TableView Datasource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = invitedPlayersTableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = "Kadeem Palacios"
        return cell!
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
