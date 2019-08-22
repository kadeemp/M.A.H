//
//  GameScreenViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 8/6/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit
import Firebase

class GameScreenViewController: UIViewController{
    var isCardVisible = false
    var session:Session!

    var cards:[MemeCard] = [MemeCard(cardKey: "", fileName: "", fileType: "", playedBy: "", cardType: "", isRevealed: false)]
    
    @IBOutlet var tableHolderView: UIView!
    @IBOutlet var scoreboardButton: UIButton!
    @IBOutlet var drawerBottomConstraint: NSLayoutConstraint!
    @IBOutlet var tableImageView: UIImageView!
    @IBOutlet var promptDeckImageView: UIButton!
    @IBOutlet var memeDeckimageview: UIButton!
    @IBOutlet var cardDrawer: UIView!
    @IBOutlet var cardCollectionView: UICollectionView!
    @IBOutlet var slideUpIndicatorButton: UIButton!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var moderatorBadgeImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        cardCollectionView.dragInteractionEnabled = true
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        cardCollectionView.dragDelegate = self
        cardCollectionView.dropDelegate = self
        profileImageView.clipsToBounds = true
        moderatorBadgeImageView.clipsToBounds = true
        moderatorBadgeImageView.layer.cornerRadius = moderatorBadgeImageView.frame.width/2
        moderatorBadgeImageView.backgroundColor = UIColor.green
        if let session = session {
            updateState(session.state)
        }
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        FirebaseController.instance.returnHand { returnedCards in
            self.cards = returnedCards
            self.cardCollectionView.reloadData()
        }

        let tableDropInteraction = UIDropInteraction(delegate: self)
        self.tableHolderView.addInteraction(tableDropInteraction)

    }
    
    func updateState(_ state:Int) {
        switch state {

            //waiting for moderator to pick prompt
        case 0:
            FirebaseController.instance.loadModerator(gameKey: session.gameID!, completion: {(moderator) in
                print("moderator check", moderator,Auth.auth().currentUser?.uid )
                if moderator == Auth.auth().currentUser!.uid {
                    self.promptDeckImageView.isUserInteractionEnabled = true
                    self.moderatorBadgeImageView.backgroundColor = UIColor.red
                    //add card animation
                }
            })

            cardCollectionView.dragInteractionEnabled = false
            //players pick their cards
        case 1:
            cardCollectionView.dragInteractionEnabled = true

            //moderator reveals cards
        case 2:
            cardCollectionView.dragInteractionEnabled = false
        //moderator chooses a card
        case 3:
            cardCollectionView.dragInteractionEnabled = false
        //pick new cards and start new round
        case 4:
            cardCollectionView.dragInteractionEnabled = true
            memeDeckimageview.isUserInteractionEnabled = true
        //add animation
        default:
            cardCollectionView.dragInteractionEnabled = false
        }
    }

    @IBAction func slideupIndicatorTriggered(_ sender: Any) {
        if !isCardVisible {
            isCardVisible = true
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5) {
                    self.drawerBottomConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }}} else {
            self.isCardVisible = false
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5) {
                    self.drawerBottomConstraint.constant = -280
                    self.view.layoutIfNeeded()
                }
            }
      }
    }

    @IBAction func promptDeckPressed(_ sender: Any) {
        //TODO:-add card animation
        FirebaseController.instance.returnPromptFromDeck(gameID: session.gameID!) { (card) in
            print(card)
            let prompt = PromptCardView(frame:CGRect(x: 100, y: 130, width: 200, height: 290))
           // prompt.center = CGPoint(x: self.view.frame.midX - prompt.frame.width - 15, y: self.view.frame.midY - prompt.frame.height)
            prompt.promptLabel.text = "\(card.prompt)"
            prompt.layer.opacity = 0
            self.view.addSubview(prompt)
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    prompt.layer.opacity = 1
                })
            }
        }
    }

    @IBAction func memeDeckPressed(_ sender: Any) {
        //TODO:-add card animation
    }
}


extension GameScreenViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate, UICollectionViewDropDelegate , UIDropInteractionDelegate {

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {

    }

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {

        return dragItems(for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cardCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardCollectionViewCell
        let card = cards[indexPath.row]

        FirebaseController.instance.downloadGif(gifName: card.fileName) { (data) in
            do {
                let gif = try UIImage(gifData:data)
                let gifView = UIImageView(gifImage: gif)
                gifView.frame.origin = CGPoint(x: 0, y: 0)
                gifView.frame = CGRect(x:0, y:0, width: 100, height: 100)
                cell.cardImage.setGifImage(gif)
            }
            catch {

            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {

        // let pet = cards[indexPath.row]

        let itemProvider = NSItemProvider()
        //        itemProvider.registerDataRepresentation(forTypeIdentifier: "public.text", visibility: .all) { completion in

        //            let data = pet.data(using: .utf8)
        //            completion(data, nil)
        //            return nil

        //        }

        let dragItem = UIDragItem(itemProvider: itemProvider)
        //        dragItem.localObject = pet
        return [dragItem]

    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        //
        print("dropped")
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        print("\(session.location(in: self.view))")

        return UIDropProposal(operation: .move)
    }
}

