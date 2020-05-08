//
//  NavigationControllers.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 5/6/20.
//  Copyright © 2020 Kadeem Palacios. All rights reserved.
//

import Foundation
import UIKit

class MainNavigationController: UIViewController {
    static var shared = MainNavigationController?.self
    var Login = "Login"
    var StartGame = "StartGame"
    var Lobby = "Lobby"
    var Game = "Game"

   func loadLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "Login")
        var viewControllers = self.navigationController?.viewControllers
    print("ViewCintrollers",viewControllers)
        viewControllers?.removeAll()
        viewControllers = [loginVC]
        self.navigationController?.viewControllers = viewControllers!
        self.navigationController?.popViewController(animated: true)
    }
    func loadMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let startGameVC = storyboard.instantiateViewController(withIdentifier: "StartGame")
        var viewControllers = self.navigationController?.viewControllers
        viewControllers?.removeAll()
        viewControllers = [startGameVC]
        self.navigationController?.viewControllers = viewControllers ?? []
        self.navigationController?.popViewController(animated: true)
    }

    func pushVC(_ vcIdentifier:String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC = storyboard.instantiateViewController(withIdentifier: vcIdentifier)
        self.navigationController?.present(newVC, animated: true, completion: nil)

    }

}
