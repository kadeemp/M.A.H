//
//  GameScreenViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 8/6/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit
import Firebase

class GameScreenViewController: UIViewController {

    var isCardVisible = false
    var session:Session!
    var cardTable:CardTable!
    var game:Game!
    var hasCardBeenRevealed:Bool = false
    var responses:[MemeCard] = []

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
    @IBOutlet var UsernameLabel: UILabel!
    @IBOutlet var playedCardCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        playedCardCollectionView.delegate = self
        playedCardCollectionView.dataSource = self
        playedCardCollectionView.dropDelegate = self

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

            FirebaseController.instance.observeGame(session: session, completion: { (game) in
                if game != nil {
                    self.game = game
                    FirebaseController.instance.returnResponses(gameKey: game!.key) {
                        responses in
                        self.responses = responses
                        if (self.responses.count >=  self.session.members.count - 1) {
                            FirebaseController.instance.setStateTo(2, game: game!)
                            print("STATE CHANGE TO 2")
                        }
                    }
                    print(#function, "current state is \(self.game.state)")
                    self.updateState(game!.state)
                } else {
                    //figure out what to put here
                    print("ERROR: Game not found")
                }})
            FirebaseController.instance.observeSession(session: session) { (returnedSession) in
                if returnedSession != nil {
                    self.session = returnedSession!


                } else {
                    print("ERROR OBSERVING SESSION", #function)
                }
            }
        }

        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        guard let user = Auth.auth().currentUser else {
            return
        }
        UsernameLabel.text = user.displayName!

        //TODO:Convert this to observe hand?
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 5)) {
            FirebaseController.instance.returnHand(user: user.uid) { returnedCards in
                self.cards = returnedCards
                print("card count", returnedCards.count)
                self.cardCollectionView.reloadData()
            }
        }


        let tableDropInteraction = UIDropInteraction(delegate: self)
        self.tableHolderView.addInteraction(tableDropInteraction)
        self.playedCardCollectionView.addInteraction(tableDropInteraction)

    }


    @objc func revealPrompt() {

        FirebaseController.instance.setStateTo(1, game: self.game)
        FirebaseController.instance.revealPrompt(gameId: self.game.key)
        self.hasCardBeenRevealed  = true


        
    }
    func returnPrompt() -> PromptCard? {
        var card:PromptCard = PromptCard(cardKey: "", prompt: "", playedBy: nil, isRevealed: false)
        guard let table = game.table else {
            return nil
        }
        guard let prompt = table["currentPrompt"] else {
            return nil
        }
        print(prompt)
        print(prompt["prompt"]!)
        print(prompt["playedBy"]!)
        print(prompt["isRevealed"] as! Bool)

        return card
    }
    /*
     func summonCurrentPrompt(asModerator:Bool) {
     //need to figure out what to do with the hascardbeenrevealed
     let card = PromptCardView(frame:CGRect(x: 100, y: 130, width: 200, height: 290))
     guard let prompt = game.table!["currentPrompt"]!["prompt"] as? String else {
     return
     }
     card.promptLabel.text = prompt
     card.layer.opacity = 0
     if !asModerator {
     card.swapButtons()
     }
     self.view.addSubview(card)
     DispatchQueue.main.async {
     UIView.animate(withDuration: 0.5, animations: {
     card.layer.opacity = 1
     })
     }
     }
     */

    func updateState(_ state:Int) {
        print("current user is \(Auth.auth().currentUser?.displayName) \n")
        guard let user = Auth.auth().currentUser else {
            return
        }
        //Moderator Check
        if session.moderator!.first!.key == user.uid {
            self.promptDeckImageView.isUserInteractionEnabled = true
            self.moderatorBadgeImageView.backgroundColor = UIColor.red
            //add card animation
        }

        switch state {

        //waiting for moderator to pick prompt
        case 0:
            print("case 0 running \n")

            //                print("moderator check", moderator,Auth.auth().currentUser?.uid )
            print(#function, session.moderator!.first!.key , Auth.auth().currentUser!.uid   )
            if session.moderator!.first!.key == Auth.auth().currentUser!.uid {
                self.promptDeckImageView.isUserInteractionEnabled = true
                self.moderatorBadgeImageView.backgroundColor = UIColor.red
                //add card animation
            } else {
                self.promptDeckImageView.isUserInteractionEnabled = false
                self.memeDeckimageview.isUserInteractionEnabled = false
            }


            cardCollectionView.dragInteractionEnabled = false
        //players pick their cards
        case 1:
            print("case 1 running \n")
            if game != nil {
                //   print(game.moderator,"Test \n", user.uid)
                //                if game.moderator == user.uid {
                //                    self.moderatorBadgeImageView.backgroundColor = UIColor.red
                //                }
                guard let table = game.table else {
                    print("could'nt load table")
                    return
                }
                guard let isRevealed = table["currentPrompt"]?["isRevealed"] as? Bool else {
                    print("could'nt load Bool")
                    return
                }
                if session.moderator!.keys.first != user.uid {
                    if hasCardBeenRevealed == false {
                        print("hasCardBeenRevealed is \(hasCardBeenRevealed)")
                        if isRevealed == true {
                            print("CARD SHOULD BE SUMMONED")
                            let card = PromptCardView(frame:CGRect(x: 100, y: 130, width: 200, height: 290))
                            guard let prompt = game.table!["currentPrompt"]!["prompt"] as? String else {
                                return
                            }
                            card.swapButtons()
                            card.promptLabel.text = prompt
                            //card.layer.opacity = 0
                            self.view.addSubview(card)
                            self.hasCardBeenRevealed = true

                            DispatchQueue.main.async {
                                UIView.animate(withDuration: 0.5, animations: {
                                    card.layer.opacity = 1
                                })
                            }
                        }
                    }
                }
            }

            cardCollectionView.dragInteractionEnabled = true

        //moderator reveals cards
        case 2:
            print("case 2 running \n")
            cardCollectionView.dragInteractionEnabled = false
        //moderator chooses a card
        case 3:
            cardCollectionView.dragInteractionEnabled = false
        //pick new cards and start new round
        case 4:
            cardCollectionView.dragInteractionEnabled = true
            memeDeckimageview.isUserInteractionEnabled = true
        //add animation
        case 5:
            hasCardBeenRevealed = false
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
        if !hasCardBeenRevealed {
            FirebaseController.instance.returnPromptFromDeck(gameID: session.gameID!) { (card) in
                print(card)
                let prompt = PromptCardView(frame:CGRect(x: 100, y: 130, width: 200, height: 290))
                // prompt.center = CGPoint(x: self.view.frame.midX - prompt.frame.width - 15, y: self.view.frame.midY - prompt.frame.height)
                prompt.promptLabel.text = "\(card.prompt)"
                prompt.layer.opacity = 0
                FirebaseController.instance.addPromptToTable(gameId: self.session.gameID!, card: card)
                prompt.revealButton.addTarget(self, action: #selector(self.revealPrompt), for: .touchUpInside)
                self.view.addSubview(prompt)
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5, animations: {
                        prompt.layer.opacity = 1
                    })
                }

            }
        } else {
            print(returnPrompt())
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
        switch collectionView {
        case cardCollectionView:
            cards.count
        case playedCardCollectionView:
            responses.count
        default:
            return 0

        }
        return cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()

        switch collectionView {
        case cardCollectionView:
            let cell2 = cardCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardCollectionViewCell
            let card = cards[indexPath.row]

            FirebaseController.instance.downloadGif(gifName: card.fileName) { (data) in
                do {
                    let gif = try UIImage(gifData:data)
                    let gifView = UIImageView(gifImage: gif)
                    gifView.frame.origin = CGPoint(x: 0, y: 0)
                    gifView.frame = CGRect(x:0, y:0, width: 100, height: 100)
                    cell2.cardImage.setGifImage(gif)
                }
                catch {
                    print(error)
                }

            }
            return cell2
        case playedCardCollectionView:
             cell = playedCardCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            return cell
        default:
            return cell
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    //MARK: DRAG DELEGATE
    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {

        // let pet = cards[indexPath.row]
        let card = cards[indexPath.row]
        let itemProvider = NSItemProvider()
        //        itemProvider.registerDataRepresentation(forTypeIdentifier: "public.text", visibility: .all) { completion in

        //            let data = pet.data(using: .utf8)
        //            completion(data, nil)
        //            return nil

        //        }

        let dragItem = UIDragItem(itemProvider: itemProvider)
        let newCard = Card(card: card, indexPath: indexPath)
        dragItem.localObject = newCard
        return [dragItem]

    }
    //MARK: DROP DELEGATE


    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        print(session.items.first!.localObject!)
        let card = session.items.first!.localObject as! Card
        FirebaseController.instance.addResponse(card: card.card, gameKey: game.key)
        cards.remove(at: card.indexPath.row)
        cardCollectionView.deleteItems(at:[card.indexPath])

        cardCollectionView.reloadData()
        FirebaseController.instance.removeCardFromHand(cardKey: card.card.cardKey)
       // cardCollectionView.isUserInteractionEnabled = false

    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {


        return UIDropProposal(operation: .move)
    }
}

