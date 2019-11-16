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
    var cards:[MemeCard] = []
    let columns:CGFloat = 2.5
    let inset:CGFloat = 10.0
    let spacing:CGFloat = 8.0

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

        cardCollectionView.dragInteractionEnabled = true
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        cardCollectionView.dragDelegate = self
        cardCollectionView.dropDelegate = self
        playedCardCollectionView.delegate = self
        playedCardCollectionView.dataSource = self
        playedCardCollectionView.dropDelegate = self
        profileImageView.clipsToBounds = true
        moderatorBadgeImageView.clipsToBounds = true
        moderatorBadgeImageView.layer.cornerRadius = moderatorBadgeImageView.frame.width/2
        moderatorBadgeImageView.backgroundColor = UIColor.green
        //TODO: Add observers for state, table, winning result,

        if let session = session {

            FirebaseController.instance.observeGame(session: session, completion: { (game) in
                if game != nil {
                    self.game = game
                    FirebaseController.instance.returnResponses(gameKey: game!.key) {
                        Responses in
                        print("there are \(Responses.count) responses" )
                        self.responses = Responses
                        self.playedCardCollectionView.reloadData()
                        print(#function, "current state is \(self.game.state)")

                        self.updateState(game!.state)
                    }
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
//                if returnedCards.count == 0 {
//                    FirebaseController.instance.loadHand(session: self.session) {
//                        FirebaseController.instance.returnHand(user: Auth.auth().currentUser!.uid) { (newHand) in
//                            self.cards = newHand
//                        }
//                    }
//                }
                self.cardCollectionView.reloadData()
            }
        }

        let tableDropInteraction = UIDropInteraction(delegate: self)
        self.tableHolderView.addInteraction(tableDropInteraction)
        self.playedCardCollectionView.addInteraction(tableDropInteraction)

    }

    @objc func revealPrompt() {
        //MARK: STATE CHANGE TO 1
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

    func updateState(_ state:Int) {

        guard let user = Auth.auth().currentUser else {
            return
        }
        switch state {
            //Start game. Initial setup
        //waiting for moderator to pick prompt
        case 0:
            //amke deck border glow
            print("case 0 running \n")
            self.memeDeckimageview.isUserInteractionEnabled = false
            if isModerator() {

                //  print("\(Auth.auth().currentUser!.displayName) has access to promots")
                self.promptDeckImageView.isUserInteractionEnabled = true
                self.moderatorBadgeImageView.backgroundColor = UIColor.red
                //add card animation
            } else {
                self.promptDeckImageView.isUserInteractionEnabled = false
                //     print("\(Auth.auth().currentUser!.displayName) doeesn't have access to promots")
                self.moderatorBadgeImageView.backgroundColor = UIColor.green
            }
            memeDeckimageview.isUserInteractionEnabled = true
            cardCollectionView.dragInteractionEnabled = false
            //promot has just been revealed
        //players pick their responses
        case 1:
            print("case 1 running \n")
            if game != nil {
                guard let table = game.table else {
                    print("couldnt load table")
                    return
                }
                guard let isRevealed = table["currentPrompt"]?["isRevealed"] as? Bool else {
                    print("could'nt load Bool")
                    return
                }
                if !isModerator() {
                    cardCollectionView.dragInteractionEnabled = true
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
                            card.layer.opacity = 0
                            self.view.addSubview(card)
                            self.hasCardBeenRevealed = true

                            DispatchQueue.main.async {
                                UIView.animate(withDuration: 0.5, animations: {
                                    card.layer.opacity = 1
                                })
                            }
                        }
                    }
                } else {
                    //MARK: STATE CHANGE TO 2
                    if (self.responses.count >=  self.session.members.count - 1) {
                        FirebaseController.instance.setStateTo(2, game: game!)
                        print("STATE CHANGE TO 2")
                    }
                }
            }
            cardCollectionView.dragInteractionEnabled = true
        //table is full
        //moderator reveals cards
        case 2:
            var responsesComplete:Bool = true
            print("case 2 running \n")
            if isModerator() {
                self.playedCardCollectionView.isUserInteractionEnabled = true

                //add card animation
            } else {
                self.playedCardCollectionView.isUserInteractionEnabled = false
            }
            //MARK:  STATE CHANGED TO 3
            if allResponsesHaveBeenRevealed(responses: responses) {
                FirebaseController.instance.setStateTo(3, game: self.game)
            }
            cardCollectionView.dragInteractionEnabled = false
            memeDeckimageview.isUserInteractionEnabled = true
        //moderator chooses a winning card
        case 3:
            playedCardCollectionView.isUserInteractionEnabled = true
            cardCollectionView.dragInteractionEnabled = false
        //show winning card to all non-moderators
        case 4:
            FirebaseController.instance.returnWinningResult(gameKey: game.key) { (winningCard) in
                if let winningCard = winningCard {
                    let resultCard = WinningCardView()
                    resultCard.frame = CGRect(x: 100, y: 130, width: 200, height: 290)
                    FirebaseController.instance.incrementScore(game: self.game, session: self.session, userID: winningCard.playedBy!)
                    resultCard.promptLabel.text = "\(self.session.members[winningCard.playedBy!]!["name"]!) wins!"
                    FirebaseController.instance.downloadGif(gifName: winningCard.fileName) { (data) in
                        do {
                            let gif = try UIImage(gifData:data)
                            resultCard.gifImage.setGifImage(gif)
                            self.view.addSubview(resultCard)
                        }
                        catch {
                            print(error)
                        }
                        //TODO:Update scoreboard
                    }
                }
            }
            cardCollectionView.dragInteractionEnabled = true
            memeDeckimageview.isUserInteractionEnabled = true
        //add animation
        case 5:
            let deadlineTime = DispatchTime.now() + .seconds(5)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                FirebaseController.instance.startNewRound(game: self.game, session:self.session)

            }
            hasCardBeenRevealed = false
            //TODO: Present Game Over. Restart game or send everyone back to lobby
        case 6:
            print()
            checkScoreboard(session: session)

        default:
            cardCollectionView.dragInteractionEnabled = false
        }
    }

    func isModerator() -> Bool {
        var result = false

        if let member = session.members[Auth.auth().currentUser!.uid] {
            let isModertor = member["isModerator"] as! Bool
            if isModertor == true {
                result = true
            }
            else {
                print("the current user is \(Auth.auth().currentUser?.displayName) and they are not the moderator")
            }
            print("THIS USER IS NOT IN THE GROUP")
        }
        return result
    }
    func checkScoreboard(session:Session) {
        let members = session.members
        for member in members {
            if member.value["score"] as! Int >= 5 {
                var label = UILabel(frame: CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: 100, height: 30))
                label.text! = "\(member.value["name"] as! String) wins!"
                label.backgroundColor = UIColor.black
                self.view.addSubview(label)
                if game.state != 6 {
                    FirebaseController.instance.setStateTo(6, game: self.game)
                }

            }
        }
    }
    func allResponsesHaveBeenRevealed(responses:[MemeCard]) -> Bool {
        var result = true
        for response in responses {
            if response.isRevealed == false {
                result = false
            }
        }
        return result
    }

    @IBAction func slideupIndicatorTriggered(_ sender: Any) {
        if isCardVisible {
            isCardVisible = !isCardVisible
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5) {
                    self.drawerBottomConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }}} else {
            self.isCardVisible = true
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
                        self.promptDeckImageView.isUserInteractionEnabled = false
                    })
                }
            }
        } else {
            print(returnPrompt())
        }
    }

    @IBAction func memeDeckPressed(_ sender: Any) {

    }
}

extension GameScreenViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate, UICollectionViewDropDelegate , UICollectionViewDelegateFlowLayout, UIDropInteractionDelegate {

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {

    }

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {

        return dragItems(for: indexPath)
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if collectionView == playedCardCollectionView {
            let response = responses[indexPath.row]


            let cell = collectionView.cellForItem(at: indexPath) as! PlayedCardCollectionViewCell
            //MARK:STATE CHANGED TO 4
            if response.isRevealed && allResponsesHaveBeenRevealed(responses: responses) {
                if self.game.state == 3 {

                    FirebaseController.instance.addWinningResult(card: response, gameKey: game.key)
                    FirebaseController.instance.setStateTo(4, game: self.game)
                }
            } else  {
                if  isModerator() {
                    if game.state == 2 {
                        //TODO: FIX SO THAT OBERVER CAN CALL THE ANIMATION RATHER THAN RELOADING

                        UIView.transition(from: cell.cardImageView, to: cell.revealedCardImageView, duration: 1, options: .transitionFlipFromLeft, completion: nil)
                        let deadline = DispatchTime.now() + 1
                        DispatchQueue.main.asyncAfter(deadline: deadline) {
                            FirebaseController.instance.revealResponse(gameKey: self.game.key, card: response)
                        }


                        //TODO: updatw this to rely on observer
                        //                        updateState(game.state)
                    }
                }
            }

        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        switch collectionView {
        case cardCollectionView:
            count = cards.count
        case playedCardCollectionView:
            count = responses.count
        default:
            return 0
        }
        return count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width:Int!
        var height:Int!
        var size:CGSize!

        switch collectionView {
        case playedCardCollectionView:

             width = Int(150)
             height = Int(collectionView.frame.height/2.7)
             size = CGSize(width: width, height: height)
            return size
        case cardCollectionView:
             width = Int(collectionView.frame.width / columns)
             height = Int(collectionView.frame.height /
                2)
             size = CGSize(width: width, height: height)
            return size
        default:
            print()

        }
        return CGSize(width: 0, height: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        switch collectionView {
        case cardCollectionView:
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
                    print(error)
                }

            }
            return cell
        case playedCardCollectionView:
            let cell = playedCardCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PlayedCardCollectionViewCell
            //            print("responses is \(responses), index path is \(indexPath.row)")
            if responses.count > 0 {

                let maxIndex = responses.count - 1
                print("maxIndex is \(maxIndex ), index path is \(indexPath.row)")
                if indexPath.row <= maxIndex {
                    if responses[indexPath.row] != nil {

                        let response = responses[indexPath.row]
                        if response.isRevealed == true {
                            cell.cardImageView.isHidden = true
                        }

                        FirebaseController.instance.downloadGif(gifName: response.fileName) { (data) in
                            do {
                                let gif = try UIImage(gifData:data)
                                let gifView = UIImageView(gifImage: gif)
                                gifView.frame.origin = CGPoint(x: 0, y: 0)
                                gifView.frame = CGRect(x:0, y:0, width: 100, height: 100)
                                cell.revealedCardImageView.setGifImage(gif)

                            }
                            catch {
                                print(error)
                            }

                        }
                        return cell
                    }
                }
            }

        default:
            print()
        }
        return cell
    }


    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    //MARK: DRAG DELEGATE
    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {

        let card = cards[indexPath.row]
        let itemProvider = NSItemProvider()
        let dragItem = UIDragItem(itemProvider: itemProvider)
        let newCard = Card(card: card, indexPath: indexPath)
        dragItem.localObject = newCard
        return [dragItem]
    }
    //MARK: DROP DELEGATE


    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        let card = session.items.first!.localObject as! Card
        FirebaseController.instance.addResponse(card: card.card, gameKey: game.key)
        cards.remove(at: card.indexPath.row)
        cardCollectionView.deleteItems(at:[card.indexPath])

        cardCollectionView.reloadData()
        FirebaseController.instance.removeCardFromHand(cardKey: card.card.cardKey)
        FirebaseController.instance.addCardtoHand(gameKey: game.key, completion: { newCard in
            //TODO: FIX so that it animates the new card in
            self.cards.append(newCard)
            self.cardCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])

        })
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {


        return UIDropProposal(operation: .move)
    }
}

