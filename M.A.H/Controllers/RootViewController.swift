//
//  RootViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 1/14/20.
//  Copyright © 2020 Kadeem Palacios. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
   private var current: UIViewController


    init() {

        //TODO:- Change this to be a splashscreen
       self.current = LoginViewController()
       super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self)
        // Do any additional setup after loading the view.
    }

    private func animateFadeTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        current.willMove(toParent: nil)
        addChild(new)

       transition(from: current, to: new, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut], animations: {
       }) { completed in
        self.current.removeFromParent()
        new.didMove(toParent: self)
            self.current = new
            completion?()  //1
       }
    }

    private func animateDismissTransition(to new: UIViewController, completion: (() -> Void)? = nil) {

        current.willMove(toParent: nil)
        addChild(new)
        print(current.parent)
        print(new.parent)
       transition(from: current, to: new, duration: 0.3, options: [], animations: {
          new.view.frame = self.view.bounds
       }) { completed in
        self.current.removeFromParent()
        new.didMove(toParent: self)
          self.current = new
          completion?()
       }
    }

    @available(iOS 13.0, *)
    func showLoginScreen() {
        print(self.view.subviews,1)

         let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let login = storyboard.instantiateViewController(identifier: "Login")

          let new = UINavigationController(rootViewController: login)
        addChild(new)

          new.view.frame = view.bounds
          view.addSubview(new.view)
        new.didMove(toParent: self)
        current.willMove(toParent: nil)
          current.view.removeFromSuperview()
        current.removeFromParent()
          current = new
        current.view.backgroundColor = .blue

        print(self.view.subviews,2)
       }

    func showMainScreen() {

      let storyboard = UIStoryboard(name: "Main", bundle: nil)
     let login = storyboard.instantiateViewController(identifier: "StartGame")

       let new = UINavigationController(rootViewController: login)
     addChild(new)
       new.view.frame = view.bounds
       view.addSubview(new.view)
     new.didMove(toParent: self)
     current.willMove(toParent: nil)
       current.view.removeFromSuperview()
     current.removeFromParent()
       current = new
     current.view.backgroundColor = .blue


    }
    func popVC() {
        self.navigationController?.popViewController(animated: true)
    }
    func switchToLogout() {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let login = storyboard.instantiateViewController(identifier: "Login")

       let logoutScreen = UINavigationController(rootViewController: login)
//       animateDismissTransition(to: logoutScreen)
    }

    func switchToMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
       let mainViewController = storyboard.instantiateViewController(identifier: "StartGame")
       let new = UINavigationController(rootViewController: mainViewController)
       animateFadeTransition(to:new)
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
