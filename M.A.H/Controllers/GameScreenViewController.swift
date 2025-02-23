//
//  GameScreenViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 8/6/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit
import Firebase

import SwiftyJSON
import SwiftyGif

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
    var columns:CGFloat = 3
    let inset:CGFloat = 10.0
    let spacing:CGFloat = 8.0
    var isUserModerator:Bool = false
    var hasRoundEnded = false
    var hasGameEnded = false
    var imageCache = NSCache<NSString, NSData>()
    
    @IBOutlet var scoreboardCollectionView: UICollectionView!
    
    @IBOutlet var tableHolderView: UIView!
    
    @IBOutlet weak var playerRoleLabel: UILabel!
    var drawerBottomConstraint: NSLayoutConstraint!
    @IBOutlet var tableImageView: UIImageView!
    @IBOutlet var promptDeckImageView: UIButton!
    @IBOutlet var memeDeckimageview: UIButton!
    @IBOutlet var cardDrawer: UIView!
    @IBOutlet var cardCollectionView: UICollectionView!
    @IBOutlet var slideUpIndicatorButton: UIButton!
    @IBOutlet var playedCardCollectionView: UICollectionView!
    @IBOutlet var promptLabel: UILabel!
    @IBOutlet weak var moderatorUpdateLabel: UILabel!
    @IBOutlet weak var promptButtonConstraint_trailingToSafeArea: NSLayoutConstraint!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet var stateLabel: UILabel!
    
    func addConstraintsToCardDrawer() {
        drawerBottomConstraint = cardDrawer.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        drawerBottomConstraint.isActive = true
        self.view.layoutIfNeeded()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidePromptCard()
        self.view.bringSubviewToFront(slideUpIndicatorButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(startNewGame), name: Notification.Name("startNewGame"), object: nil)
        
        guard let currentUser = Auth.auth().currentUser else {return}

        
        addConstraintsToCardDrawer()
        promptLabel.hideLabelWithAnimation(true)
        
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        cardCollectionView.dragDelegate = self
        cardCollectionView.dropDelegate = self
        
        playedCardCollectionView.delegate = self
        playedCardCollectionView.dataSource = self
        playedCardCollectionView.dropDelegate = self
        
        let tableDropInteraction = UIDropInteraction(delegate: self)
        self.tableHolderView.addInteraction(tableDropInteraction)
        self.playedCardCollectionView.addInteraction(tableDropInteraction)
        self.memeDeckimageview.isUserInteractionEnabled = true
        
        if let game = game {
            
            FirebaseController.instance.observeIsModerator(sessionKey: session.key, userKey: Auth.auth().currentUser!.uid) { (moderatorStatus) in
                //                print("\(Auth.auth().currentUser?.displayName)'s moderator status is \(moderatorStatus) \n the game state is \(self.game.state)")
                let members = self.session.members
                let memberIndex = members.index(forKey: Auth.auth().currentUser!.uid)
                self.session.members.updateValue(["isModerator":moderatorStatus], forKey: Auth.auth().currentUser!.uid)
                //                self.scoreboardCollectionView.reloadData()
                //     self.updateState(self.game.state)
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
                
                self.members = returnedMembers
                //                self.scoreboardCollectionView.reloadData()
            }
            FirebaseController.instance.observeGameWinningResult(gameKey: game.key) { (result) in
                //                if let result = result {
                //                    self.responses = []
                //                    self.playedCardCollectionView.deleteItems(at: self.playedCardCollectionView.indexPathsForVisibleItems)
                //
                //                    var deadline = DispatchTime.now() + 3
                //                    DispatchQueue.main.asyncAfter(deadline: deadline) {
                //
                //                        self.responses.append(result)
                //                        let indexPath = IndexPath(row: 0, section: 0)
                //                        self.playedCardCollectionView.insertItems(at: [indexPath])
                //
                //                    }
                //
                //                    deadline = DispatchTime.now() + 5
                //                    DispatchQueue.main.asyncAfter(deadline: deadline) {
                //
                //                        self.responses = []
                //                        self.playedCardCollectionView.deleteItems(at: self.playedCardCollectionView.indexPathsForVisibleItems)
                //
                //                    }
                //                }
            }
            FirebaseController.instance.observePlayedCards(gameKey: self.game.key) { (indexes) in
                if self.game.state == 2 || self.game.state == 3 {
                    if !self.isModerator() {
                        if let indexToReveal = indexes.last {
                            let indexPathOfResponse = IndexPath(item: indexToReveal, section: 0)
                            
                            if let cell = self.playedCardCollectionView.cellForItem(at: indexPathOfResponse) as? PlayedCardCollectionViewCell2 {
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
                                    self.playedCardCollectionView.cellForItem(at: IndexPath(item: index, section: 0))?.contentView.alpha = 1
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
                var currentScore = Int(self.scoreLabel.text!)
                
                var returnedScore = returnedSession?.members[Auth.auth().currentUser!.uid]!["score"] as! Int
                
                if currentScore != returnedScore as! Int {
                    self.scoreLabel.text = String(returnedScore)
                }
            }
            
            //TODO- FIX  Crashes if game is just starting and table has not been created.
            //            if self.responses == [] {
            //                if game.table != nil {
            //                    var resp = game.table!["responses"]!
            //                    for i in resp {
            //                        let a = i.value as! [String:Any]
            //                        var newResponse = MemeCard(
            //                            cardKey: a["cardKey"] as! String,
            //                            fileName: a["fileName"] as! String,
            //                            fileType: a["fileType"] as! String,
            //                            playedBy: a["playedBy"] as! String,
            //                            cardType: "gif",
            //                            isRevealed: a["isRevealed"] as! Bool
            //                        )
            //                        self.responses.append(newResponse)
            //                        //                TODO:- ADD INSERTION ANIMATION
            //
            //                    }
            //                    self.playedCardCollectionView.reloadData()
            //                }
            //            }
            
            updateState(self.game.state)
        }
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        //TODO:Convert this to observe hand?/check if person is a member, if they arent, add them , and give them a hand.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 5)) {
            FirebaseController.instance.returnHand(user: user.uid) { returnedCards in
                self.cards = returnedCards
                if returnedCards.count == 0 {
                    FirebaseController.instance.loadHand(session: self.session) {
                        FirebaseController.instance.returnHand(user: Auth.auth().currentUser!.uid) { (newHand) in
                            self.cards = newHand
                        }
                    }
                }
                self.cardCollectionView.reloadData()
            }
        }
    }
    
    func pingModerator(){
        var label = UILabel()
        label.frame = CGRect(x: 0, y: (self.view.bounds.height / 2) - (self.view.bounds.height / 4) , width: 300, height: 20)
        label.textColor = .white
        label.text = "Youre the moderator!"
        label.layer.opacity = 0
        label.center.x = view.bounds.width / 2
        label.center.x -= view.bounds.width / 2
        view.addSubview(label)
        UIView.animate(withDuration: 0.5, delay: 0.4, animations: {
            label.layer.opacity = 1
        })
        
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
            label.center.x = self.view.bounds.width / 2
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 5, animations: {
                label.layer.opacity = 0
            }) { (_) in
                label.removeFromSuperview()
            }
        }
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
    
    func updateState(_ state:Int) {
        //        print("the state in the fn is \(state) \n the state on the game is \(self.self.game.state)")
        // print("the responses are \(self.responses)")
        print("current state: \(state)")
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        switch state {
            //Start game. Initial setup
            //waiting for moderator to pick prompt
        case -2 :
            //TODO:-  Test to make sure that this works.
            self.navigationController?.popViewController(animated: true)
        case -1:
            
            //MARK: RESET TABLE, PROPMPT, AND DISABLE PROMPT DECK FOR EVERYONE
            self.responses = []
            self.promptLabel.text = ""
            self.hasRoundEnded = false
            self.promptDeckImageView.isUserInteractionEnabled = false
            
            self.updateState(0)
            
            
        case 0:
            //MARK: DISABLE MEME DECK | ENABLE PROMPT DECK FOR MODERATOR
            
            //TODO: MOVE ERROR HANDLING TO FUNCTION
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
            print(session.members)
            if isModerator() == true {
                playerRoleLabel.text = "Moderator"
                animateShowPromptCard()
                //TODO: CREATE ANIMATED CARD THAT SAYS YOURE THE MODERATOR
                print("moderator label placed")
            moderatorUpdateLabel.updatePromptLabel(prompt: "You're the moderator! Pick a prompt below. First to 4 points wins!")
                
                //  print("\(Auth.auth().currentUser!.displayName) has access to promots")
                
                self.promptDeckImageView.isUserInteractionEnabled = true
                //TODO:ANIMATE CARD SHOWING THEM THEY ARE THE MODERATOR
                
                //add card animation
            } else {
                playerRoleLabel.text = "Player"
                self.promptDeckImageView.isUserInteractionEnabled = false
                print("player label placed")
               moderatorUpdateLabel.updatePromptLabel(prompt: "Waiting for the moderator to reveal the prompt. First to 4 points wins!")
                //     print("\(Auth.auth().currentUser!.displayName) doeesn't have access to promots")
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.moderatorUpdateLabel.hideLabelWithAnimation(true)
            }
            memeDeckimageview.isUserInteractionEnabled = false
            cardCollectionView.dragInteractionEnabled = false
            //promot has just been revealed
            //players pick their responses
        case 1:
            //MARK: ALLOW NON-MODERATORS TO PLAY CARDS | SHOW PROMPT
            // print("case 1 running \n")
            if !isModerator() {
                self.cardCollectionView.isUserInteractionEnabled = true
                self.cardCollectionView.dragInteractionEnabled = true
            }
            
            if let currentPrompt = currentPrompt {
                if promptLabel.text != currentPrompt.prompt {
                    if currentPrompt.isRevealed == true  {
                        moderatorUpdateLabel.hideLabelWithAnimation(true)
                        promptLabel.clearPrompt()
                        promptLabel.updatePromptLabel(prompt: currentPrompt.prompt)
                    }
                }
            }
            //table is full
            //moderator reveals cards
        case 2:
            //MARK: ALLOW MODERATOR TO CHOOSE CARDS | STOP MORE CARDS FROM BEING PLAYED
            //  print("case 2 running \n")
            if isModerator() {
                self.playedCardCollectionView.isUserInteractionEnabled = true
                
                //add card animation
            } else {
                self.playedCardCollectionView.isUserInteractionEnabled = false
            }
            
            cardCollectionView.dragInteractionEnabled = false
            memeDeckimageview.isUserInteractionEnabled = true
            //moderator chooses a winning card
        case 3:
            //MARK:
            playedCardCollectionView.isUserInteractionEnabled = true
            cardCollectionView.dragInteractionEnabled = false
            //show winning card to all non-moderators
        case 4:
            //MARK: REMOVE ALL PLAYED CARDS | RETURN THE WINNING RESULT

            let playedCardCells = playedCardCollectionView.visibleCells
            DispatchQueue.main.async {
                UIView.animate(withDuration: 2, delay: 0, options: .curveEaseInOut) {
                    for cell in playedCardCells {
                        cell.contentView.alpha = 0
                    }
                } completion: { didComplete in
                    self.responses = []
                    self.playedCardCollectionView.reloadData()
                    self.promptLabel.hideLabelWithAnimation(false)


                    //TODO:CHECK IF THE CODE BELOW IS NEEDED
                    for cell in self.playedCardCollectionView.subviews {
                        cell.alpha = 1
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5, execute: {
                FirebaseController.instance.returnWinningResult(gameKey: self.game.key) { (winningCard) in
                    if let winningCard = winningCard {
                        let resultCard = WinningCardView2()
                        resultCard.frame = CGRect(x: 0, y: 0, width: 200, height: 290)
                        resultCard.center = CGPoint(x: self.view.frame.maxX / 2, y: self.view.frame.maxY / 3)
                        resultCard.promptLabel.text = self.promptLabel.text
                        resultCard.setupPlayer(urlString: winningCard.fileName)
                        resultCard.alpha = 0
                        self.view.addSubview(resultCard)
                        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut) {
                            resultCard.alpha = 1
                        } completion: { didComplete in
                            FirebaseController.instance.setStateTo(5, game: self.game)
                        }
                    }
                }
            })
            
            cardCollectionView.dragInteractionEnabled = true
            memeDeckimageview.isUserInteractionEnabled = true
            //add animation
        case 5:
            //MARK: AFTER 5 SECONDS, CLEAR TABLE AND PROMPT | SWAP MODERATOR
            if hasRoundEnded == false {
                let deadlineTime = DispatchTime.now() + .seconds(5)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.responses = []
                    self.playedCardCollectionView.reloadData()
                    self.hasCardBeenRevealed = false
                    self.promptLabel.hideLabelWithAnimation(true)
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
            //MARK:
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
    
    func checkScoreboard(session:Session) {
        let members = session.members
        var didWin = false
        for member in members {
            if member.value["score"] as! Int >= 4 && self.hasGameEnded == false {
                //var label = UILabel(frame: CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: 150, height: 30))
                
                if session.hostID == Auth.auth().currentUser?.uid {
                    
                    var alert = UIAlertController(title: "\(member.value["name"] as! String) won", message: "What would you like to do?", preferredStyle: .alert)
                    let returnAction = UIAlertAction(title: "Return to Lobby", style: .cancel) { (action) in
                        //                        TODO:- Make sure this works.
                        self.navigationController?.popViewController(animated: true)
                        FirebaseController.instance.setStateTo(-2, game: self.game)
                        //                        AppDelegate.shared.rootViewController.popVC()
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
                    endGameCard.promptLabel.text = promptLabel.text
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

        if !isCardVisible {
            isCardVisible = !isCardVisible
            animateCardDrawerOpening()
        }
        
        else {
            self.isCardVisible = false
            animateCardDrawerClosing()
            
        }
        //        print("constant after is\(self.drawerBottomConstraint.constant) \n")
    }
    
    func animateCardDrawerClosing() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.drawerBottomConstraint.constant += self.cardDrawer.frame.height
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    func animateCardDrawerOpening() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) { [self] in
                self.drawerBottomConstraint.constant -= self.cardDrawer.frame.height
                //                    cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.view.layoutIfNeeded()
            }}
        
    }
    func animateShowPromptCard() {
        ///40 makes it about 10 unites from safe area
        ///50 makes it closer to safe area
        ///
        /////20 makes it closer?
        /// /150 -> -280
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.promptButtonConstraint_trailingToSafeArea.constant = self.promptLabel.frame.width / 50
            }}
        
        
    }
    func hidePromptCard() {
        self.promptButtonConstraint_trailingToSafeArea.constant = -self.promptLabel.frame.width
    }
    
    func animateHidePromptCard() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.promptButtonConstraint_trailingToSafeArea.constant = -self.promptLabel.frame.width
            }}
    }
    
    @IBAction func promptDeckPressed(_ sender: Any) {
        if !hasCardBeenRevealed {
            animateHidePromptCard()
            FirebaseController.instance.returnPromptFromDeck(gameID: session.gameID!) { (card) in
                //print(card)
                let prompt = PromptCardView(frame:CGRect(x: self.view.bounds.midX - (self.view.frame.width * 0.75), y: self.view.bounds.height, width: self.view.frame.width * 0.75, height: self.view.frame.height * 0.4))
                prompt.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY  + self.view.frame.height * 2)
                
                prompt.layer.opacity = 0
                FirebaseController.instance.addPromptToTable(gameId: self.session.gameID!, card: card)
                prompt.revealButton.addTarget(self, action: #selector(self.revealPrompt), for: .touchUpInside)
                prompt.revealButton.isUserInteractionEnabled = true
                self.view.addSubview(prompt)
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5, animations: {
                        prompt.layer.opacity = 1
                        prompt.center.y = self.view.center.y - 100
                        prompt.promptLabel.text = "\(card.prompt)"
                        
                        self.promptDeckImageView.isUserInteractionEnabled = false
                    })
                }
            }
        } else {
            //            print(returnPrompt())
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
            
            let cell = collectionView.cellForItem(at: indexPath) as! PlayedCardCollectionViewCell2
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
        } else if collectionView == cardCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell2
            let animation = CABasicAnimation(keyPath: "transform.scale.x")
            let animation2 = CABasicAnimation(keyPath: "transform.scale.y")
            let deadline = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                animation.duration = 0.5
                animation.fromValue = 1
                animation.toValue = 2
                animation.autoreverses = true
                animation2.duration = 0.5
                animation2.fromValue = 1
                animation2.toValue = 2
                animation2.autoreverses = true
                cell.layer.add(animation, forKey: nil)
                cell.layer.add(animation2, forKey: nil)
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
            //        case scoreboardCollectionView:
            //            count = members.count
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
            
            width = Int(collectionView.frame.width / 3)
            height = Int(collectionView.frame.height /
                         2)
            size = CGSize(width: width, height: height)
            return size
            //        case scoreboardCollectionView:
            //            columns = CGFloat(Int(members.count))
            //            width = Int(collectionView.frame.width / columns)
            //            height = Int(collectionView.frame.height)
            //            size = CGSize(width: width, height: height)
            //            return size
        default:
            print()
        }
        return CGSize(width: 0, height: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch collectionView {
        case cardCollectionView:
            return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
            
        case playedCardCollectionView:
            return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
            //        case scoreboardCollectionView:
            //
            //            return UIEdgeInsets(top: 5, left: 20 ,bottom: 5, right: 5)
        default:
            print()
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0 ,right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case cardCollectionView:
            return spacing
        case playedCardCollectionView:
            return spacing
            //        case scoreboardCollectionView:
            //            return 0
        default:
            print()
        }
        return spacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case cardCollectionView:
            return spacing
        case playedCardCollectionView:
            return spacing
            //        case scoreboardCollectionView:
            //            return 0
        default:
            print()
        }
        return spacing
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        switch collectionView {
        case cardCollectionView:
            let cell = cardCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardCollectionViewCell2
            let card = cards[indexPath.row]
            let url = URL(string: card.fileName)!
            cell.setupPlayer(urlString: card.fileName)
            
            return cell
        case playedCardCollectionView:
            let cell2 = playedCardCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PlayedCardCollectionViewCell2
            cell2.cardImageView.isHidden = false
            cell2.imageHolderView.bringSubviewToFront(cell2.cardImageView)
            if responses.count > 0 {
                
                let maxIndex = responses.count - 1
                if indexPath.row <= maxIndex {
                    if responses[indexPath.row] != nil {
                        
                        let response = responses[indexPath.row]
                        if response.isRevealed == true {
                            cell2.cardImageView.isHidden = true
                        } else {
                            cell2.revealedCardImageView.isHidden = true
                            cell2.cardImageView.isHidden = false
                        }
                        cell2.setupPlayer(urlString: response.fileName)
                        
                        return cell2
                    }
                }
            }
            //        case scoreboardCollectionView:
            //
            //            let cell3 = scoreboardCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ScoreboardCollectionViewCell
            //            let member = members[indexPath.row]
            //
            //            cell3.profilePhoto.loadImageUsingCacheWithUrlString(urlString: member.profileURL)
            //            if member.moderatorStatus {
            //                cell3.profilePhoto.layer.borderColor = UIColor.yellow.cgColor
            //            } else {
            //                cell3.profilePhoto.layer.borderColor = UIColor.purple.cgColor
            //            }
            //            cell3.profilePhoto.contentMode = .scaleAspectFill
            //            cell3.nameLabel.text = member.name
            //            cell3.scoreLabel.text = "\(member.score)"
            //
            //            return cell3
            
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
    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        
        
        
        UIView.animate(withDuration: 2) {
            self.tableImageView.layer.backgroundColor = .init(red: 1, green: 0, blue: 0, alpha: 0)
            self.tableImageView.layer.borderColor = CGColor(red: 1, green: 0, blue: 0, alpha: 0)
            self.tableImageView.layer.borderWidth = 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
            self.tableImageView.layer.cornerRadius = self.tableImageView.frame.height/8
        
        UIView.animate(withDuration: 0.8) {
            self.tableImageView.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
            self.tableImageView.layer.borderWidth = 1

        }
                    
    }
}



//    func returnPrompt() -> PromptCard? {
//        var card:PromptCard = PromptCard(cardKey: "", prompt: "", playedBy: nil, isRevealed: false)
//        guard let table = game.table else {
//            return nil
//        }
//        guard let prompt = table["currentPrompt"] else {
//            return nil
//        }
//        return card
//    }

//        guard let fetchedDisplayName =  currentUser.displayName else { print("no diplay name found",#function)
//            return }
//        guard let profilePhotoURL = currentUser.photoURL else { print("no photo url found",#function)
//            return }
