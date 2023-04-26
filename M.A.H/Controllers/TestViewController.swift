//
//  TestViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 4/12/23.
//  Copyright © 2023 Kadeem Palacios. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseController.instance.returnRandomMemeCard { returnedCard in
            FirebaseController.instance.returnPromptForMeme(cardkey: returnedCard.cardKey)
            let prompt2 = WinningCardView2(frame: CGRect(x: 0, y: 0, width: 200, height: 290))
            prompt2.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY  + self.view.frame.height * 2)

            prompt2.layer.opacity = 0
            self.view.addSubview(prompt2)
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    prompt2.layer.opacity = 1
                    prompt2.center.y = self.view.center.y - 100
                    
                    prompt2.setupPlayer(urlString: returnedCard.fileName )
                    
                })
            }
        }
        
    }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

