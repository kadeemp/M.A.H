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
    var currentPrompt:PromptCard!
    var game:Game!
    var cardTableHasBeenLoaded = false
    var hasCardBeenRevealed:Bool = false
    var responses:[MemeCard] = []
    var cards:[MemeCard] = []
    let columns:CGFloat = 2.5
    let inset:CGFloat = 10.0
    let spacing:CGFloat = 8.0
    var isUserModerator:Bool = false
    var hasRoundEnded = false
    var hasGameEnded = false

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
    @IBOutlet var promptLabel: UILabel!

    @IBOutlet var stateLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

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
        //TODO: Add observers for state, table, winning result,

        self.drawerBottomConstraint.constant = -280
        self.view.layoutIfNeeded()




        if let game = game {
            //            FirebaseController.instance.observeIsModerator(sessionKey: session.key, userKey: Auth.auth().currentUser!.uid) { (moderatorStatus) in
            //                print("\(Auth.auth().currentUser?.displayName)'s moderator status is \(moderatorStatus) \n the game state is \(self.game.state)")
            //                self.isUserModerator = moderatorStatus
            //                self.updateState(self.game.state)
            //
            //            }
            FirebaseController.instance.observeGameState(gameKey: game.key) { (newState) in
                print("The new state is \(newState) \n \(Auth.auth().currentUser?.displayName)'s moderator status is \(self.isModerator())")
                if self.game.state != newState {
                    self.game.state = newState
                    self.updateState(newState)
                    self.stateLabel.text! = "\(newState)"
                }
                print("the state has been set to \(self.game.state)")
            }
            FirebaseController.instance.observeCurrentPrompt(gameKey: game.key) { (currentPrompt) in
                if let currentPrompt = currentPrompt {
                    self.currentPrompt = currentPrompt
                    if self.game.state == 1 {
                        self.updateState(self.game.state)
                    }
                }
            }

            FirebaseController.instance.observeGameWinningResult(gameKey: game.key) { (result) in
                if let result = result {
                    let resultCard = WinningCardView()
                    resultCard.frame = CGRect(x: 100, y: 130, width: 200, height: 290)
                    resultCard.promptLabel.text = "\(self.session.members[result.playedBy!]!["name"]!) wins!"
                    FirebaseController.instance.downloadGif(gifName: result.fileName) { (data) in
                        do {
                            let gif = try UIImage(gifData:data)
                            resultCard.gifImage.setGifImage(gif)
                            self.view.addSubview(resultCard)
                            let deadline = DispatchTime.now() + 5
                            DispatchQueue.main.asyncAfter(deadline: deadline) {

                                resultCard.removeFromSuperview()

                            }

                        }
                        catch {
                            print(error)
                        }
                        //TODO:Update scoreboard
                    }
                }
            }
            FirebaseController.instance.observePlayedCards(gameKey: self.game.key) { (indexes) in
                if self.game.state == 2 || self.game.state == 3 {
                    if !self.isModerator() {
                        if let indexToReveal = indexes.last {
                            print("revealing index:\(indexToReveal)")
                            let indexPathOfResponse = IndexPath(item: indexToReveal, section: 0)
                            let cell = self.playedCardCollectionView.cellForItem(at: indexPathOfResponse) as! PlayedCardCollectionViewCell
                            UIView.transition(from: cell.cardImageView, to: cell.revealedCardImageView, duration: 1, options: .transitionFlipFromLeft, completion: nil)

                        }
                    }
                }

            }

            FirebaseController.instance.observeResponses(gameKey: game.key) { (returnedResponses) in

                if  returnedResponses != nil {
                    if self.game.state == 1 {
                        if returnedResponses!.count != self.responses.count {
                            for response in returnedResponses! {
                                if !self.responses.contains(response) {
                                    let index = self.responses.count - 1
                                    let indexPathOfResponse = IndexPath(item: 0, section: 0)
                                    let indexes = [indexPathOfResponse]
                                    self.responses.append(response)


                                    
                                    self.playedCardCollectionView.insertItems(at: indexes)
                                    //self.playedCardCollectionView.reloadItems(at: indexes)
                                }
                            }
                        }
                    }
                }

//                var indexPathTracker:[IndexPath] = []
//                if  returnedResponses != nil {
//                    indexPathTracker = []
//                    if !self.cardTableHasBeenLoaded {
//                        self.responses = returnedResponses!
//                        self.cardTableHasBeenLoaded = true
//                        self.playedCardCollectionView.reloadData()
//                    } else {
//                        print("There are \(returnedResponses!.count) responses")
//                        var index = 0
//                        for response in returnedResponses! {
//                            if self.toKeyArray(memes: self.responses).contains(response.cardKey) {
//                                //TODO: check if self.responses contains the whole card
//                                //if it doesn't, find the indexpath, and do a view transition
//                                if self.responses.contains(response) {
//                                    break
//                                } else {
//                                    let indexPathOfResponse = IndexPath(item: index, section: 0)
//                                    let cell = self.playedCardCollectionView.cellForItem(at: indexPathOfResponse) as! PlayedCardCollectionViewCell
//                                    UIView.transition(from: cell.cardImageView, to: cell.revealedCardImageView, duration: 1, options: .transitionFlipFromLeft, completion: nil)
//                                }
//
//                            } else {
//                                self.responses.append(response)
//                                let indexPathOfResponse = IndexPath(item: index, section: 0)
//                                index += 1
//                                self.playedCardCollectionView.insertItems(at: indexPathTracker)
//                            }
//                        }
//                    }
//                }

                if (self.responses.count >=  self.session.members.count - 1) && (self.game!.state <= 1) {
                    FirebaseController.instance.setStateTo(2, game: game)
                    print("STATE CHANGE TO 2")
                }
                self.updateState(self.game.state)

            }
            FirebaseController.instance.observeSession(session: session) { (returnedSession) in
                if returnedSession != nil {
                    self.session = returnedSession!
                } else {
                    print("ERROR OBSERVING SESSION", #function)
                }
            }
            if isModerator() {
                self.moderatorBadgeImageView.backgroundColor = UIColor.red
                //add card animation
            } else {
                self.moderatorBadgeImageView.backgroundColor = UIColor.green
            }

            updateState(self.game.state)
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
        self.memeDeckimageview.isUserInteractionEnabled = true

    }

    func toKeyArray(memes:[MemeCard]) -> [String]{
        var result:[String] = []
        for meme in memes {
            result.append(meme.cardKey)
        }
        return result
    }

    @objc func revealPrompt() {
        //MARK: STATE CHANGE TO 1
        FirebaseController.instance.revealPrompt(gameId: self.game.key)
        FirebaseController.instance.setStateTo(1, game: self.game)

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
        return card
    }

    func updateState(_ state:Int) {
//        print("the state in the fn is \(state) \n the state on the game is \(self.self.game.state)")
        print("the responses are \(self.responses)")

        guard let user = Auth.auth().currentUser else {
            return
        }
        stateLabel.text! = String(state)
        switch state {
            //Start game. Initial setup
        //waiting for moderator to pick prompt
        case 0:
            self.hasRoundEnded = false
            //amke deck border glow
            // print("case 0 running \n")
            self.memeDeckimageview.isUserInteractionEnabled = false

            if isModerator() == true {

                //  print("\(Auth.auth().currentUser!.displayName) has access to promots")
                self.promptDeckImageView.isUserInteractionEnabled = true
                self.moderatorBadgeImageView.backgroundColor = UIColor.red
                //add card animation
            } else {
                self.promptDeckImageView.isUserInteractionEnabled = false
                //     print("\(Auth.auth().currentUser!.displayName) doeesn't have access to promots")
                self.moderatorBadgeImageView.backgroundColor = UIColor.green
            }
            memeDeckimageview.isUserInteractionEnabled = false
            cardCollectionView.dragInteractionEnabled = false
            //promot has just been revealed
        //players pick their responses
        case 1:
            // print("case 1 running \n")
            if !isModerator() {
                self.cardCollectionView.dragInteractionEnabled = true
            }
            if let currentPrompt = currentPrompt {
                if currentPrompt.isRevealed == true  {
                    promptLabel.layer.opacity = 0
                    promptLabel.text = currentPrompt.prompt
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.5, animations: {
                            self.promptLabel.layer.opacity = 1
                        })
                    }
                }
            }


            //table is full
        //moderator reveals cards
        case 2:

            //  print("case 2 running \n")
            if isModerator() {
                self.playedCardCollectionView.isUserInteractionEnabled = true

                //add card animation
            } else {
                self.playedCardCollectionView.isUserInteractionEnabled = false
            }
            //MARK:  STATE CHANGED TO 3
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
                    resultCard.promptLabel.text = "\(self.session.members[winningCard.playedBy!]!["name"]!) wins!"
                    FirebaseController.instance.downloadGif(gifName: winningCard.fileName) { (data) in
                        do {
                            let gif = try UIImage(gifData:data)
                            resultCard.gifImage.setGifImage(gif)
                            self.view.addSubview(resultCard)
                            FirebaseController.instance.setStateTo(5, game: self.game)
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
            if hasRoundEnded == false {
                self.hasRoundEnded = true
                let deadlineTime = DispatchTime.now() + .seconds(5)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    if self.isModerator() {
                        FirebaseController.instance.swapModerator(session: self.session)
                        FirebaseController.instance.startNewRound(game: self.game, session:self.session)
                    }
                    self.responses = []
                    self.playedCardCollectionView.reloadData()
                    self.hasCardBeenRevealed = false
                    self.promptLabel.text! = ""
                    self.hasRoundEnded = true


                    //TODO: Add  animations


                }
            }

        //TODO: Present Game Over. Restart game or send everyone back to lobby
        case 6:
            if hasGameEnded == false {
                checkScoreboard(session: self.session)
            }



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
               // print("the current user is \(Auth.auth().currentUser?.displayName) and they are not the moderator")
            }
        }
        return result
    }
    @objc func startNewGame() {
        print("AAaa")
    }
    @objc func returntoLobby() {
        self.dismiss(animated: true) {
            //TODO:Database cleanup
        }
    }
    func checkScoreboard(session:Session) {
        let members = session.members
        var didWin = false
        for member in members {
            if member.value["score"] as! Int >= 3 && self.hasGameEnded == false {
                //var label = UILabel(frame: CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: 150, height: 30))
                var endGameCard = EndGameCardView()
                endGameCard.center = CGPoint(x: self.view.frame.midX - 100, y: self.view.frame.midY - self.view.frame.height/3)
                endGameCard.promptLabel.text = "\(member.value["name"] as! String) won the game!"
                if session.hostID == Auth.auth().currentUser?.uid {
                    print("this person is the host")
                } else {
                    endGameCard.newGameButton.isHidden = true
                    endGameCard.returntoLobby.isHidden = true

                }
                endGameCard.newGameButton.addTarget(self, action: #selector(startNewGame), for: .allTouchEvents)

                //label.backgroundColor = UIColor.yellow
                self.view.addSubview(endGameCard)
                self.hasGameEnded = true
                didWin = true
            }
        }
        if didWin {
            
            print("success!!")
        } else {
            print(#function, "FAILED TO GET WINNINING SCORE")
        }
    }
    func allResponsesHaveBeenRevealed(responses:[MemeCard]) -> Bool {
        var result = true
        for response in responses {
            if response.isRevealed == false {
                result = false
            }
        }

        if responses.count == 0 {
            result = false
        }
        return result
    }

    @IBAction func slideupIndicatorTriggered(_ sender: Any) {
        if !isCardVisible {
            isCardVisible = !isCardVisible
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
                //print(card)
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
                        self.promptLabel.text = card.prompt

                        self.promptDeckImageView.isUserInteractionEnabled = false
                    })
                }
            }
        } else {
//            print(returnPrompt())
        }
    }

    @IBAction func memeDeckPressed(_ sender: Any) {
        FirebaseController.instance.swapModerator(session: self.session)
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
                    var gameHasBeenWon = false
                    let members = session.members
                    for member in members {
                        if member.value["score"] as! Int >= 3 && response.playedBy! == member.key as! String {
                            gameHasBeenWon = true
                        }
                    }
                    if gameHasBeenWon {
                        FirebaseController.instance.incrementScore(game: self.game, session: self.session, userID: response.playedBy!)
                        FirebaseController.instance.setStateTo(6, game: self.game)
                    } else {
                        FirebaseController.instance.incrementScore(game: self.game, session: self.session, userID: response.playedBy!)
                        FirebaseController.instance.addWinningResult(card: response, gameKey: game.key)
                        FirebaseController.instance.setStateTo(4, game: self.game)
                    }
                }
            } else  {
                if  isModerator() {
                    if self.game.state == 2 {
                        //TODO: FIX SO THAT OBERVER CAN CALL THE ANIMATION RATHER THAN RELOADING

                        UIView.transition(from: cell.cardImageView, to: cell.revealedCardImageView, duration: 1, options: .transitionFlipFromLeft, completion: nil)
                        let deadline = DispatchTime.now() + 1
                        DispatchQueue.main.asyncAfter(deadline: deadline) {
                            FirebaseController.instance.revealResponse(gameKey: self.game.key, card: response)
                            FirebaseController.instance.addResponseIndex(gameKey: self.game.key, index: indexPath.row)

                        }
                        self.responses[indexPath.row].isRevealed = !response.isRevealed
                        if allResponsesHaveBeenRevealed(responses: responses) {
                            FirebaseController.instance.setStateTo(3, game: self.game)
                        }
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
//            print(card.fileName)

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
            let cell2 = playedCardCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PlayedCardCollectionViewCell
            //            print("responses is \(responses), index path is \(indexPath.row)")
            if responses.count > 0 {

                let maxIndex = responses.count - 1
                // print("maxIndex is \(maxIndex ), index path is \(indexPath.row)")
                if indexPath.row <= maxIndex {
                    if responses[indexPath.row] != nil {

                        let response = responses[indexPath.row]
                        cell2.response = response
                        if response.isRevealed == true {
                            cell2.cardImageView.isHidden = true
                        } else {
                            cell2.cardImageView.isHidden = false
                        }


                        FirebaseController.instance.downloadGif(gifName: response.fileName) { (data) in
                            do {
                                cell2.revealedCardImageView.clear()
                                let gif = try UIImage(gifData:data)
                                let gifView = UIImageView(gifImage: gif)
                                gifView.frame.origin = CGPoint(x: 0, y: 0)
                                gifView.frame = CGRect(x:0, y:0, width: 100, height: 100)
                                cell2.revealedCardImageView.setGifImage(gif)

                            }
                            catch {
                                print(error)
                            }

                        }

                        return cell2
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
        var card = session.items.first!.localObject as! Card
        card.card.playedBy = Auth.auth().currentUser!.uid
        FirebaseController.instance.addResponse(card: card.card, gameKey: game.key)
        self.cards.remove(at: card.indexPath.row)
        cardCollectionView.deleteItems(at:[card.indexPath])

        cardCollectionView.reloadData()
        FirebaseController.instance.removeCardFromHand(cardKey: card.card.cardKey)
        FirebaseController.instance.addCardtoHand(gameKey: game.key, completion: { newCard in
            //TODO: FIX so that it animates the new card in
            self.cards.append(newCard)

            self.cardCollectionView.insertItems(at: [IndexPath(item: self.cards.count - 1, section: 0)])
        })
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {

        return UIDropProposal(operation: .move)
    }
}

