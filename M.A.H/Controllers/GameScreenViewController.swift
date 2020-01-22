//
//  GameScreenViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 8/6/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit
import Firebase
import AlamofireImage

class GameScreenViewController: UIViewController {

    var isCardVisible = false
    var session:Session!
    var currentPrompt:PromptCard!
    var game:Game!
    var cardTableHasBeenLoaded = false
    var hasCardBeenRevealed:Bool = false
    var responses:[MemeCard] = []
    var cards:[MemeCard] = []
    var members:[Member] = []
    let columns:CGFloat = 2.5
    let inset:CGFloat = 10.0
    let spacing:CGFloat = 8.0
    var isUserModerator:Bool = false
    var hasRoundEnded = false
    var hasGameEnded = false
    var imageCache = NSCache<NSString, NSData>()
    @IBOutlet var scoreboardCollectionView: UICollectionView!
    
    @IBOutlet var tableHolderView: UIView!

    @IBOutlet var drawerBottomConstraint: NSLayoutConstraint!
    @IBOutlet var tableImageView: UIImageView!
    @IBOutlet var promptDeckImageView: UIButton!
    @IBOutlet var memeDeckimageview: UIButton!
    @IBOutlet var cardDrawer: UIView!
    @IBOutlet var cardCollectionView: UICollectionView!
    @IBOutlet var slideUpIndicatorButton: UIButton!
    @IBOutlet var playedCardCollectionView: UICollectionView!
    @IBOutlet var promptLabel: UILabel!

    @IBOutlet var stateLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(returntoLobby), name: Notification.Name("returnToLobby"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startNewGame), name: Notification.Name("startNewGame"), object: nil)

        switch self.view.frame.height {
        case 896:
            self.drawerBottomConstraint.constant = -cardDrawer.frame.height - 65
        default:
            self.drawerBottomConstraint.constant = -cardDrawer.frame.height
        }

        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        cardCollectionView.dragDelegate = self
        cardCollectionView.dropDelegate = self
//        cardCollectionView.
        playedCardCollectionView.delegate = self
        playedCardCollectionView.dataSource = self
        playedCardCollectionView.dropDelegate = self


        //TODO: Add observers for state, table, winning result,

       // self.drawerBottomConstraint.constant = -cardDrawer.frame.height
        self.view.layoutIfNeeded()

        print(" height is\(self.view.frame.height)")
        if let game = game {
                        FirebaseController.instance.observeIsModerator(sessionKey: session.key, userKey: Auth.auth().currentUser!.uid) { (moderatorStatus) in
                            print("\(Auth.auth().currentUser?.displayName)'s moderator status is \(moderatorStatus) \n the game state is \(self.game.state)")
                            let members = self.session.members
                            let memberIndex = members.index(forKey: Auth.auth().currentUser!.uid)
                            self.session.members.updateValue(["isModerator":moderatorStatus], forKey: Auth.auth().currentUser!.uid)
                            self.updateState(self.game.state)
                        }
            FirebaseController.instance.observeGameState(gameKey: game.key) { (newState) in
                //                print("The new state is \(newState) \n \(Auth.auth().currentUser?.displayName)'s moderator status is \(self.isModerator())")
                if self.game.state != newState {
                    self.game.state = newState
                    self.updateState(newState)
                }
                //                print("the state has been set to \(self.game.state)")
            }
            FirebaseController.instance.observeCurrentPrompt(gameKey: game.key) { (currentPrompt) in
                if let currentPrompt = currentPrompt {
                    self.currentPrompt = currentPrompt
                    if self.game.state == 1 {
                        self.updateState(self.game.state)
                    }
                }
            }
            FirebaseController.instance.observeSessionMembers(session: session) { (returnedMembers) in
                print("members list:\(returnedMembers) \n",Auth.auth().currentUser?.displayName!)
                self.members = returnedMembers
                self.scoreboardCollectionView.reloadData()
            }
            FirebaseController.instance.observeGameWinningResult(gameKey: game.key) { (result) in
                if let result = result {
                    let resultCard = WinningCardView()
                    resultCard.frame = CGRect(x: 100, y: 130, width: 200, height: 290)
                    resultCard.promptLabel.text = "\(self.session.members[result.playedBy!]!["name"]!) wins!"
                    resultCard.gifImage.setGifFromURL(URL(string: result.fileName)!)
                    self.view.addSubview(resultCard)
                    let deadline = DispatchTime.now() + 5
                    DispatchQueue.main.asyncAfter(deadline: deadline) {

                        resultCard.removeFromSuperview()

                    }
                }
            }
            FirebaseController.instance.observePlayedCards(gameKey: self.game.key) { (indexes) in
                if self.game.state == 2 || self.game.state == 3 {
                    if !self.isModerator() {
                        if let indexToReveal = indexes.last {
                            let indexPathOfResponse = IndexPath(item: indexToReveal, section: 0)

                            if let cell = self.playedCardCollectionView.cellForItem(at: indexPathOfResponse) as? PlayedCardCollectionViewCell {
                                                            UIView.transition(from: cell.cardImageView, to: cell.revealedCardImageView, duration: 1, options: [.transitionFlipFromLeft,.showHideTransitionViews])
                            }
                        }
                    }
                }

            }

            FirebaseController.instance.observeResponses(gameKey: game.key) { (returnedResponses) in

                if  returnedResponses != nil {
                    //print(returnedResponses!,"\n",self.responses)
                    if self.game.state == 1 || self.game.state == 0  {
                        if returnedResponses!.count != self.responses.count {
                            for response in returnedResponses! {
                                if !self.responses.contains(response) {
                                    self.responses.append(response)
                                    let index = self.responses.count - 1
                                    let indexPathOfResponse = IndexPath(item: index, section: 0)
                                    let indexes = [indexPathOfResponse]
                                    self.playedCardCollectionView.insertItems(at: indexes)
                                }
                            }
                        }
                    }
                }

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
            updateState(self.game.state)
        }

        guard let user = Auth.auth().currentUser else {
            return
        }

        //TODO:Convert this to observe hand?/check if person is a member, if they arent, add them , and give them a hand.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 5)) {
            FirebaseController.instance.returnHand(user: user.uid) { returnedCards in
                self.cards = returnedCards
//                print("card count", returnedCards.count)
//                print(self.cards)
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
        print(" constant is\(self.drawerBottomConstraint.constant)")

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
        // print("the responses are \(self.responses)")

        guard let user = Auth.auth().currentUser else {
            return
        }
        switch state {
            //Start game. Initial setup
        //waiting for moderator to pick prompt
        case -1:
            self.responses = []
            self.promptLabel.text = ""
            //todo:Check if person has 5 cards
            //todo:alert next moderator
        case 0:
            if self.responses.count != 0 {
                //TODO FIX THIS BUG
                self.responses = []
                self.playedCardCollectionView.reloadData()
                print("TABLE NOT PROPERLY CLEARED")
            }
            self.hasRoundEnded = false
            //amke deck border glow
            // print("case 0 running \n")
            self.memeDeckimageview.isUserInteractionEnabled = false

            if isModerator() == true {

                //  print("\(Auth.auth().currentUser!.displayName) has access to promots")
                self.promptDeckImageView.isUserInteractionEnabled = true

                //add card animation
            } else {
                self.promptDeckImageView.isUserInteractionEnabled = false
                //     print("\(Auth.auth().currentUser!.displayName) doeesn't have access to promots")

            }
            memeDeckimageview.isUserInteractionEnabled = false
            cardCollectionView.dragInteractionEnabled = false
            //promot has just been revealed
        //players pick their responses
        case 1:
            // print("case 1 running \n")
            if !isModerator() {
                self.cardCollectionView.isUserInteractionEnabled = true
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
                    resultCard.gifImage.setGifFromURL(URL(string: winningCard.fileName)!)
                    self.view.addSubview(resultCard)
                    FirebaseController.instance.setStateTo(5, game: self.game)

                }
            }
            cardCollectionView.dragInteractionEnabled = true
            memeDeckimageview.isUserInteractionEnabled = true
        //add animation
        case 5:
            if hasRoundEnded == false {
                let deadlineTime = DispatchTime.now() + .seconds(5)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.responses = []
                    self.playedCardCollectionView.reloadData()
                    self.hasCardBeenRevealed = false
                    self.promptLabel.text! = ""
                    self.hasRoundEnded = true
                    if self.isModerator() {
                        FirebaseController.instance.swapModerator(session: self.session)
                        let deadline = DispatchTime.now() + 1
                        DispatchQueue.main.asyncAfter(deadline: deadline) {
                            FirebaseController.instance.startNewRound(game: self.game, session:self.session)
                        }
                    }
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
        FirebaseController.instance.startNewGame(session: self.session) {

        }
    }
    @objc func returntoLobby() {
        print("retrn2lbby")
        self.navigationController?.popViewController(animated: true)
    }
    func checkScoreboard(session:Session) {
        let members = session.members
        var didWin = false
        for member in members {
            if member.value["score"] as! Int >= 3 && self.hasGameEnded == false {
                //var label = UILabel(frame: CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: 150, height: 30))

                if session.hostID == Auth.auth().currentUser?.uid {
                    print("this person is the host")
                    var alert = UIAlertController(title: "\(member.value["name"] as! String) won", message: "What would you like to do?", preferredStyle: .alert)
                    let returnAction = UIAlertAction(title: "Return to Lobby", style: .cancel) { (action) in
                        self.navigationController?.popViewController(animated: true)
                        //TODO:- Set GameIsActive to false, record game data,  destory game data

                    }
                    let restartGameAction = UIAlertAction(title: "Restart Game", style: .default) { (action) in

                        let notificationCenter = NotificationCenter.default
                        notificationCenter.post(name:  Notification.Name("startNewGame"), object: nil)
                    }
                    alert.addAction(returnAction)
                    alert.addAction(restartGameAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    var endGameCard = EndGameCardView()
                    endGameCard.center = CGPoint(x: self.view.frame.midX - 100, y: self.view.frame.midY - self.view.frame.height/3)
                    endGameCard.promptLabel.text = "\(member.value["name"] as! String) won the game!"
                    endGameCard.newGameButton.isHidden = true
                    endGameCard.returntoLobby.isHidden = true
                    self.view.addSubview(endGameCard)
                    self.view.bringSubviewToFront(endGameCard)
                }
                self.hasGameEnded = true
                didWin = true
            }
        }
        if didWin {
            
            print("did win successs triggered", #function)
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
        print("constant before is\(self.drawerBottomConstraint.constant) \n")
        if !isCardVisible {
            isCardVisible = !isCardVisible
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5) {
                   // self.drawerBottomConstraint.constant = 0
                    switch self.view.frame.height {
                    case 896:
                        self.drawerBottomConstraint.constant += self.cardDrawer.frame.height + 65
                    default:
                        self.drawerBottomConstraint.constant += self.cardDrawer.frame.height
                    }
                    self.view.layoutIfNeeded()
                }}} else {
            self.isCardVisible = false
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5) {
                    switch self.view.frame.height {
                    case 896:
                        self.drawerBottomConstraint.constant = -self.cardDrawer.frame.height - 65
                    default:
                        self.drawerBottomConstraint.constant = -self.cardDrawer.frame.height
                    }
//                    self.drawerBottomConstraint.constant = -280
                    self.view.layoutIfNeeded()
                }
            }
        }
        print("constant after is\(self.drawerBottomConstraint.constant) \n")
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
                    let member = members[response.playedBy!]
                    var score: Int = member!["score"] as! Int
                        if (score + 1) >= 3 {
                        gameHasBeenWon = true
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

                        UIView.transition(from: cell.cardImageView, to: cell.revealedCardImageView, duration: 1, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
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
        case scoreboardCollectionView:
            count = members.count
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
        case scoreboardCollectionView:
            width = 50
            height = 70
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
            let url = URL(string: card.fileName)!
            //let imageCache = AutoPurgingImageCache()

//            if let cachedImage = imageCache.object(forKey: NSString(string:card.fileName ) )
//            {
//                do {
//                    cell.cardImage.gifImage = try UIImage(gifData: cachedImage as Data)
//                }
//                catch {
//                    print(error)
//                }
//
//                //cell.cardImage.setGifImage(cachedImage)
//            } else {
//
//                cell.cardImage.setGifFromURL(url)
//                imageCache.setObject(cell.cardImage.image!.imageData , forKey: NSString(string: card.fileName))
//            }
        cell.cardImage.setGifFromURL(url)

            return cell
        case playedCardCollectionView:
            let cell2 = playedCardCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PlayedCardCollectionViewCell
            cell2.cardImageView.isHidden = false
            cell2.imageHolderView.bringSubviewToFront(cell2.cardImageView)
            if responses.count > 0 {

                let maxIndex = responses.count - 1
                // print("maxIndex is \(maxIndex ), index path is \(indexPath.row)")
                if indexPath.row <= maxIndex {
                    if responses[indexPath.row] != nil {

                        let response = responses[indexPath.row]
                        if response.isRevealed == true {
                            cell2.cardImageView.isHidden = true
                        } else {
                            cell2.cardImageView.isHidden = false
                        }
                        cell2.revealedCardImageView.setGifFromURL(URL(string: response.fileName)!)
                        return cell2
                    }
                }
            }
        case scoreboardCollectionView:

            let cell3 = scoreboardCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ScoreboardCollectionViewCell
            let member = members[indexPath.row]
            
            let url = URL(string: member.profileURL)!
                            URLSession.shared.dataTask(with: url) { (data, response, error) in
                                if error != nil {
                                    print(error?.localizedDescription)
                                    return
                                }
                                let image = UIImage(data: data!)
                                     DispatchQueue.main.async {
                                        cell3.profilePhoto.image = image!
                                 }
                            }.resume()
            if member.moderatorStatus {
                cell3.profilePhoto.layer.borderColor = UIColor.yellow.cgColor

            } else {
                cell3.profilePhoto.layer.borderColor = UIColor.purple.cgColor
            }
            cell3.nameLabel.text = member.name
            cell3.scoreLabel.text = "\(member.score)"
            return cell3

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

