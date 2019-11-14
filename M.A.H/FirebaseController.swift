//
//  FirebaseController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 7/20/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import Foundation
import Firebase


let DB_BASE = Database.database().reference()


class FirebaseController {

    static let instance = FirebaseController()

    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_SESSIONS = DB_BASE.child("sessions")
    private var _REF_GIFS = DB_BASE.child("gifs")
    private var _REF_GAMES = DB_BASE.child("games")
    private var _REF_IMAGES = DB_BASE.child("images")
    private var _REF_PROMPTS = DB_BASE.child("prompts")
    private var _REF_RESPONSES = DB_BASE.child("responses")

    //MARK:- Database Refrences
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    var REF_USERS:DatabaseReference {
        return _REF_USERS
    }
    var REF_SESSIONS:DatabaseReference {
        return _REF_SESSIONS
    }
    var REF_GIFS:DatabaseReference {
        return _REF_GIFS
    }
    var REF_IMAGES:DatabaseReference {
        return _REF_IMAGES
    }
    var REF_GAMES:DatabaseReference {
        return _REF_GAMES
    }
    var REF_PROMPTS:DatabaseReference {
        return _REF_PROMPTS
    }
    var REF_RESPONSES:DatabaseReference {
        return  _REF_RESPONSES
    }

    //MARK:- Game

    func createGame(session:Session, completion: @escaping (()->())) {
        var gameKey = REF_GAMES.childByAutoId().key!.stripID()
        var newSession = session

        let scoreboard = addMemberstodictionary(session: session)

        createMemeDeck(gameKey: gameKey) { (deck) in
            self.createPromptDeck(gameKey: gameKey,
                                  completion: {
                                    (prompts) in
                                    //                                    print(prompts.isEmpty, 123456789)
                                    self.REF_GAMES.child(gameKey).updateChildValues(["key":gameKey,
                                                                                     "prompts":prompts,
                                                                                     "round":1,
                                                                                     "scoreboard":scoreboard,
                                                                                     "meme deck":deck,
                                                                                     "sessionID":session.key,
                                                                                     "state":0,
                                                                                     "table": ["InitialValue":["test":""]]]
                                    )
                                    self.REF_SESSIONS.child(session.key.stripID()).updateChildValues(["gameID":gameKey, "isGameActive":true,"moderator":[session.members.randomElement()!.key:session.members.randomElement()!.value]])
                                    newSession.gameID = gameKey
                                    // newSession.moderator = [session.members.randomElement()!.key:session.members.randomElement()!.value]
                                    //TODO:SET RANDOM MODERATOR

                                    self.loadHand(session: newSession) {
                                        print("hand complete")
                                        completion()
                                    }
            })
        }
    }


    func observeGame(session:Session, completion:@escaping ((Game?) -> ())) {
        guard let gameId = session.gameID else { return }
        REF_GAMES.child(gameId).observe(.value) { (datasnapshot) in
            if datasnapshot.exists() {
                let key = datasnapshot.childSnapshot(forPath: "key").value as! String
                let round = datasnapshot.childSnapshot(forPath: "round").value as! Int
                let scoreboard = datasnapshot.childSnapshot(forPath: "scoreboard").value as! [String:[String:Any]]
                let state = datasnapshot.childSnapshot(forPath: "state").value as! Int
                if let table = datasnapshot.childSnapshot(forPath: "table").value as? [String:[String:Any]] {
                    let game = Game(key: key, round: round,scoreboard: scoreboard, table: table, state: state)
                    completion(game)
                } else {
                    let game = Game(key: key, round: round, scoreboard: scoreboard, table: nil, state: state)
                    print("COULD NOT LOAD TABLE", #function)
                    completion(game)
                }
            } else {
                print("COULD NOT FIND GAME")
                completion(nil)
            }
        }
    }
    func observeGameState(gameKey:String, completion:@escaping ((Int) -> ())) {
        REF_GAMES.child(gameKey).child("state").observe(.value) {  (datasnapshot) in
            if datasnapshot.exists() {
                let state = datasnapshot.value as! Int
                completion(state)
            }
        }
    }

    func observeGameRound(gameKey:String, completion:@escaping ((Int) -> ())) {
        REF_GAMES.child(gameKey).child("round").observe(.value) {  (datasnapshot) in
            if datasnapshot.exists() {
                let round = datasnapshot.value as! Int
                completion(round)

            }
        }
    }
    func observeGameTable(gameKey:String, completion:@escaping (([String:[String:Any]]) -> ())) {
        REF_GAMES.child(gameKey).child("table").observe(.value) {  (datasnapshot) in
            if datasnapshot.exists() {
                let table = datasnapshot.value as! [String:[String:Any]]
                completion(table)

            }
        }
    }

    func returnResponses(gameKey:String, completion: @escaping (([MemeCard]) -> ())) {
        var responses:[MemeCard] = []
        REF_GAMES.child(gameKey).child("table").child("responses").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let data = dataSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            print("dataCount = \(data.count)")

            for cardData in data {
                let fileName = cardData.childSnapshot(forPath: "fileName").value as? String
                //                    print(fileName!)
                let fileType = cardData.childSnapshot(forPath: "fileType").value as? String
                let playedBy = cardData.childSnapshot(forPath: "playedBy").value as? String
                let cardKey = cardData.childSnapshot(forPath: "cardKey").value as? String
                let isRevealed = cardData.childSnapshot(forPath: "isRevealed").value as? Bool

                let card = MemeCard(cardKey: cardKey!, fileName: fileName!, fileType: fileType!, playedBy: playedBy, cardType: "meme", isRevealed: isRevealed!)
                //                    print(card)
                responses.append(card)
            }
            if responses.count == 0 {
                print("NO RESPONSeS FOUND")
                completion(responses)
            } else {
                completion(responses)
            }
        }
    }
    func addResponse(card:MemeCard, gameKey:String) {
        REF_GAMES.child(gameKey).child("table").child("responses").updateChildValues([card.cardKey:["playedBy":card.playedBy ?? "", "isRevealed":card.isRevealed, "fileName":card.fileName, "fileType":card.fileType, "cardKey":card.cardKey]])
    }
    func clearResponses(game:Game) {
        REF_GAMES.child(game.key).child("table").child("responses").removeValue()
    }
    func revealResponse(gameKey:String,card:MemeCard) {
        REF_GAMES.child(gameKey).child("table").child("responses").child(card.cardKey).updateChildValues(["isRevealed":true])
    }

    func clearTable(gameKey:String) {
        REF_GAMES.child(gameKey).child("table").removeValue()
    }
    func addWinningResult(card:MemeCard,gameKey:String) {
        REF_GAMES.child(gameKey).updateChildValues(["winning result":["cardKey": card.cardKey, "fileName": card.fileName, "fileType": card.fileType, "playedBy": card.playedBy!, "cardType": "meme", "isRevealed": card.isRevealed]])
    }
    func removeWinningResult(gameKey:String) {
        REF_GAMES.child(gameKey).child("winning result").removeValue()
    }
    func returnWinningResult(gameKey:String,completion:@escaping ((MemeCard?) ->() )) {
        var result:MemeCard!
        REF_GAMES.child(gameKey).child("winning result").observeSingleEvent(of: .value) { (dataSnapshot) in
            if dataSnapshot.exists() {

                let fileName = dataSnapshot.childSnapshot(forPath: "fileName").value as? String
                //                    print(fileName!)
                let fileType = dataSnapshot.childSnapshot(forPath: "fileType").value as? String
                let playedBy = dataSnapshot.childSnapshot(forPath: "playedBy").value as? String
                let cardKey = dataSnapshot.childSnapshot(forPath: "cardKey").value as? String
                let isRevealed = dataSnapshot.childSnapshot(forPath: "isRevealed").value as? Bool

                result = MemeCard(cardKey: cardKey!, fileName: fileName!, fileType: fileType!, playedBy: playedBy, cardType: "meme", isRevealed: isRevealed!)
                completion(result)
            }else {
                completion(nil)
            }
        }
    }
    func observeGameWinningResult(gameKey:String, completion:@escaping ((Int) -> ())) {
        REF_GAMES.child(gameKey).child("state").observe(.value) {  (datasnapshot) in
            if datasnapshot.exists() {
                let state = datasnapshot.value as! Int
                completion(state)

            }
        }
    }
    func incrementState(game:Game) {
        let state = game.state + 1
        REF_GAMES.child(game.key).updateChildValues(["state":state])
    }

    func setStateTo(_ state:Int ,game:Game) {
        REF_GAMES.child(game.key).updateChildValues(["state":state])
    }

    func incrementScore(game:Game, session:Session, userID:String) {
        let scoreboard = game.scoreboard
        var score = scoreboard[userID]!["score"] as! Int
        score = score + 1
        setStateTo(5, game: game)
        REF_SESSIONS.child(session.key).child("members").child(userID).updateChildValues(["score":score])
        REF_GAMES.child(game.key).child("scoreboard").child(userID).updateChildValues(["score":score])
    }

    //MARK:- Hand
    func returnHand(user:String,comletion:@escaping (([MemeCard]) -> ())) {
        var cards:[MemeCard] = []
        print(user, "user test", #function)
        REF_USERS.child(user).child("hand").observeSingleEvent(of: .value) { (snapshot) in
            guard let data = snapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            print("dataCount = \(data.count)")

            for cardData in data {
                let fileName = cardData.childSnapshot(forPath: "fileName").value as? String
                //                    print(fileName!)
                let fileType = cardData.childSnapshot(forPath: "fileType").value as? String
                let playedBy = cardData.childSnapshot(forPath: "playedBy").value as? String
                let cardKey = cardData.childSnapshot(forPath: "cardKey").value as? String

                let card = MemeCard(cardKey: cardKey!, fileName: fileName!, fileType: fileType!, playedBy: playedBy, cardType: "meme", isRevealed: false)
                //                    print(card)
                cards.append(card)
            }
            //                print("completed")
            comletion(cards)
        }
    }

    func loadHand(session:Session, completion:@escaping (() -> ())) {
        let handCount = 5
        guard let user = Auth.auth().currentUser?.uid else {
            return
        }
        guard let gameID = session.gameID else {return}
        REF_GAMES.child(gameID).child("meme deck").observeSingleEvent(of: .value) { (datasnapshot) in
            guard let data = datasnapshot.children.allObjects as? [DataSnapshot?] else {
                return
            }
            var dataArray = data.shuffled()
            var cardDictionary:[String:[String:Any]] = [:]
            if !dataArray.isEmpty {
                for member in session.members {
                    cardDictionary = [:]
                    var memberHand:[MemeCard] = []
                    while memberHand.count < 5 {
                        guard  let cardData = dataArray.removeLast() else {
                            return
                        }
                        let fileName = cardData.childSnapshot(forPath: "fileName").value as? String
                        let fileType = cardData.childSnapshot(forPath: "fileType").value as? String
                        let cardKey = cardData.childSnapshot(forPath: "cardKey").value as? String
                        //TODO: safely unwrap
                        cardDictionary[cardKey!] = ["cardKey": cardKey!, "fileName": fileName!, "fileType": fileType!, "playedBy": user, "cardType": "meme", "isRevealed": false]

                        let card = MemeCard(cardKey: cardKey!, fileName: fileName!, fileType: fileType!, playedBy: user, cardType: "meme", isRevealed: false)
                        memberHand.append(card)
                    }
                    self.REF_USERS.child(member.key).child("hand").removeValue()
                    self.REF_USERS.child(member.key).child("hand").updateChildValues(cardDictionary)
                    print(1)
                    if cardDictionary.count > 0{
                        print("hand loaded on first attempt")
                        completion()
                    } else {
                        print("HAND COULD NOT BE LOADED")
                        let deadline = DispatchTime.now() + 1
                        DispatchQueue.main.asyncAfter(deadline: deadline) {
                            self.loadHand(session: session) {
                                print("SECOND ATTEMPT AT LOADING HAND")
                            }
                        }
                    }

                }
            }
        }
    }
    func removeCardFromHand(cardKey:String) {
        REF_USERS.child(Auth.auth().currentUser!.uid).child("hand").child(cardKey).removeValue()
    }
    func addCardtoHand(gameKey:String,completion: @escaping ((MemeCard) -> ())) {
        let key = REF_GAMES.childByAutoId().key!.stripID()
        var returnedCards:[MemeCard] = []
        REF_GAMES.child(gameKey).child("meme deck").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let data = dataSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            for cardData in data {
                let fileName = cardData.childSnapshot(forPath: "fileName").value as? String
                //                    print(fileName!)
                let fileType = cardData.childSnapshot(forPath: "fileType").value as? String
                let playedBy = cardData.childSnapshot(forPath: "playedBy").value as? String
                let cardKey = cardData.childSnapshot(forPath: "cardKey").value as? String
                //                let isRevealed = cardData.childSnapshot(forPath: "isRevealed").value as? Bool

                let card = MemeCard(cardKey: cardKey!, fileName: fileName!, fileType: fileType!, playedBy: playedBy, cardType: "meme", isRevealed: false)
                //                    print(card)
                returnedCards.append(card)
            }
            if let newCard = returnedCards.randomElement() {
                completion(newCard)
                self.REF_GAMES.child(gameKey).child("meme deck").child(newCard.cardKey).removeValue()

                self.REF_USERS.child(Auth.auth().currentUser!.uid).child("hand").updateChildValues(["\(newCard.cardKey)":["cardKey": newCard.cardKey, "fileName": newCard.fileName, "fileType": newCard.fileType, "playedBy": "", "cardType": "meme", "isRevealed": newCard.isRevealed]])
            } else {
                print("COULD NOT FIND ")
            }
        }
    }

    //MARK:- Prompts

    func createPromptDeck(gameKey:String,completion:@escaping (([String:[String:String]]) -> ())) {
        var result :[String:[String:String]] = [:]
        let queue = DispatchQueue.init(label: "queue")
        loadPromptstringsWithcompletion { (prompts) in
            queue.async(execute: {
                for prompt in prompts {
                    guard let key = self.REF_GAMES.child(gameKey).childByAutoId().key?.stripID() else {
                        //                        print("error  creating key")
                        return
                    }
                    result[key] =  ["prompt":prompt, "playedby":""]
                }
                completion(result)
            })
        }
    }
    func revealPrompt(gameId:String) {
        REF_GAMES.child(gameId).child("table").child("currentPrompt").updateChildValues(["isRevealed":true])
    }
    func addPromptToTable(gameId:String, card:PromptCard) {
        REF_GAMES.child(gameId).child("table").child("currentPrompt").updateChildValues(["cardKey":card.cardKey,"isRevealed":false, "playedBy":Auth.auth().currentUser!.uid,"prompt":card.prompt])
    }

    func returnPromptFromDeck(gameID:String, completion:@escaping ((PromptCard)->())) {
        REF_GAMES.child(gameID).child("prompts").observeSingleEvent(of: .value) { (datasnapshot) in
            guard let prompts = datasnapshot.children.allObjects as? [DataSnapshot] else {
                //                print("Error getting prompt")
                return }

            var shuffledPropmpts = prompts.shuffled()

            if let prompt = shuffledPropmpts.randomElement() {
                let playedBy = prompt.childSnapshot(forPath: "playedBy").value as? String
                let cardPrompt = prompt.childSnapshot(forPath: "prompt").value as? String

                let card = PromptCard(cardKey: prompt.key, prompt: cardPrompt!, playedBy: Auth.auth().currentUser!.displayName!, isRevealed: false)
                completion(card)
            } else {
                print("Error getting prompt")
            }
        }
    }

    func loadPromptstringsWithcompletion(competion:(@escaping ([String]) -> ())) {
        var result:[String] = []
        REF_PROMPTS.observeSingleEvent(of: .value) { (snapshot) in
            guard let data = snapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            for prompt in data {
                let returnedPrompt = prompt.childSnapshot(forPath: "prompt").value as? String
                if let returnedPrompt = returnedPrompt {
                    result.append(returnedPrompt)
                }
            }
            competion(result)
        }
    }

    func createMemeDeck(gameKey:String,completion:@escaping (([String:[String:String]]) -> ())) {
        var result :[String:[String:String]] = [:]
        let queue = DispatchQueue.init(label: "queue")
        loadGifsStringsWithCompletion(competion: { gifs in
            queue.async {
                for gif in gifs {
                    guard let key = self.REF_GAMES.child(gameKey).child("meme-deck").childByAutoId().key?.stripID() else {
                        //                        print("error creating key")
                        return
                    }

                    result[key] = ["cardKey":key, "fileName":gif, "fileType":"gif","playedby":""]
                }
            }
            queue.async(execute: {
                self.loadGifsStringsWithCompletion(competion: { (images) in
                    for image in images {
                        guard let key = self.REF_GAMES.child(gameKey).child("meme-deck").childByAutoId().key?.stripID() else {
                            //                            print("error creating key")
                            return
                        }
                        result[key] = ["cardKey":key, "fileName":image, "fileType":"image","playedby":""]
                    }
                    completion(result)
                })
            })
        })
    }



    //MARK:- Sessions

    func observeSession(session:Session, completion:@escaping ((Session?) -> ())) {
        REF_SESSIONS.child(session.key).observe(.value) { (datasnapshot) in
            if datasnapshot.exists() {
                let host = datasnapshot.childSnapshot(forPath: "host").value as! String
                let hostID = datasnapshot.childSnapshot(forPath: "hostID").value as! String
                let members = datasnapshot.childSnapshot(forPath: "members").value as! [String:[String:Any]]
                let code = datasnapshot.childSnapshot(forPath: "code").value as! String
                let key = datasnapshot.childSnapshot(forPath: "key").value as! String
                let gameID = datasnapshot.childSnapshot(forPath: "gameID").value as! String
                let isActive = datasnapshot.childSnapshot(forPath: "isGameActive").value as! Bool
                let moderator = datasnapshot.childSnapshot(forPath: "moderator").value as? [String:String]
                let session = Session(host: host, hostID: hostID, code: code, members: members, key: key, gameID: gameID, isActive: isActive, moderator: moderator)
                completion(session)
            } else {
                //                print("COULD NOT FIND GAME")
                completion(nil)
            }

        }
    }

    func searchSessionsByCode(code: String, handler: @escaping (_ success:Bool,_ session:Session?) -> ()) {

        REF_SESSIONS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let sessionSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            var found = false
            for session in sessionSnapshot {
                let returedCode = session.childSnapshot(forPath: "code").value as? String

                if returedCode == code {
                    let host = session.childSnapshot(forPath: "host").value as? String
                    let code = session.childSnapshot(forPath: "code").value as? String
                    let hostID = session.childSnapshot(forPath: "hostID").value as? String
                    let members = session.childSnapshot(forPath: "members").value as? [String:[String:Any]]
                    let key = session.childSnapshot(forPath: "key").value as? String
                    let gameID = session.childSnapshot(forPath: "gameID").value as? String
                    let isActive = session.childSnapshot(forPath: "isGameActive").value as! Bool
                    let moderator = session.childSnapshot(forPath: "moderator").value as? [String:String]
                    let newSession = Session(host: host!, hostID: hostID!, code:code! , members: members ?? [:], key:key!, gameID: gameID,  isActive: isActive, moderator: moderator)
                    found = true
                    handler(found,newSession)
                    return
                } else {
                    found = false
                }
            }
            handler(found, nil)
        }
    }
    func swapModerator(session:Session) {
        var members = session.members
        var keys = Array(members.keys)
        print(members.count)
        for mem in members {
            let isModerator = mem.value["isModerator"] as! Bool
            let hasBeenModerator = mem.value["hasBeenModerator"] as? Bool
            if isModerator == true {
                var newMember = mem
                newMember.value["isModerator"] = false
                newMember.value["hasBeenModerator"] = true
                updateMember(session: session, member: newMember)
                members.removeValue(forKey: mem.key)
            }
            if hasBeenModerator != nil {
                if hasBeenModerator! == true {
                    members.removeValue(forKey: mem.key)
                }
            }
        }
        
        if members.count != 0 {
            var newModerator = members.randomElement()
            newModerator!.value["isModerator"] = true
            updateMember(session: session, member: newModerator!)
        } else {

            for member in session.members {
                var updatedMember = member
                updatedMember.value["hasBeenModerator"] = false
                updatedMember.value["isModerator"] = false
                updateMember(session: session, member: updatedMember)
            }
            var newModerator = session.members.randomElement()
            newModerator!.value["isModerator"] = true
            newModerator!.value["hasBeenModerator"] = false
            updateMember(session: session, member: newModerator!)
            //increment score
        }

    }
    //TODO

    func loadModerator(sessionKey:String,completion: @escaping (([String:String]) -> ())) {
        REF_SESSIONS.child(sessionKey).child("moderator").observeSingleEvent(of: .value) { (datasnapshot) in
            guard let moderator = datasnapshot.value as? [String:String] else {
                return
            }
            completion(moderator)
        }
    }

    func updateMember(session:Session,member:(key: String, value: [String : Any])) {
        REF_SESSIONS.child(session.key).child("members").child(member.key).updateChildValues(member.value)
    }

    func createSession(code:String, hostID:String, host:String) {
        var key = REF_SESSIONS.childByAutoId().key!.stripID()

        REF_SESSIONS.child(key).updateChildValues(["code":code, "hostID":hostID, "host":host, "members":["\(Auth.auth().currentUser!.uid)":["name":Auth.auth().currentUser?.displayName!,"score":0,"isModerator":true,"hasBeenModerator":false]], "key":key, "isGameActive":false, "gameID":"", "moderator":[hostID:host]])
    }

    func updateSessionMembers(session:Session, members:[String], completion: @escaping (() -> ())) {
        REF_SESSIONS.child(session.key).updateChildValues(["members" : members])
    }
    //TODO: Test to make sure this works
    func removeMemberFrom(session:Session, memberID:String, completion:@escaping (([String:[String:Any]]) -> ())) {

        var members = session.members
        if session.members.count == 1 {
            REF_SESSIONS.child(session.key).updateChildValues(["members" : []])
            completion([:])
            return
        } else {
            for i in members  {
                if i.key == memberID {

                    members[i.key] = nil
                    REF_SESSIONS.child(session.key).updateChildValues(["members":members])
                    completion(members)
                    return
                }
            }
        }

    }
    func loadLobby(by Code:String, completion: @escaping ((_ session:Session) -> ())) {
        REF_SESSIONS.observe(.value) { (sessionSnapshot) in
            guard let sessionSnapshot = sessionSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            for session in sessionSnapshot {
                if session.childSnapshot(forPath: "code" ).value as? String == Code {
                    let host = session.childSnapshot(forPath: "host").value as? String
                    let hostID = session.childSnapshot(forPath: "hostID").value as? String
                    let code = session.childSnapshot(forPath: "code").value as? String
                    let members = session.childSnapshot(forPath: "members").value as? [String:[String:Any]]
                    let key = session.childSnapshot(forPath: "key").value as? String
                    let gameID = session.childSnapshot(forPath: "gameID").value as? String
                    let isActive = session.childSnapshot(forPath: "isGameActive").value as! Bool
                    let moderator = session.childSnapshot(forPath: "moderator").value as? [String:String]
                    let newSession = Session(host: host!, hostID: hostID!,code:code!, members: members ?? [:], key:key!, gameID: gameID, isActive: isActive, moderator: moderator)
                    completion(newSession)
                }
            }
        }
    }
    func addUserToSession(code:String ,userID:String, displayName:String)  {
        REF_SESSIONS.observeSingleEvent(of: .value) { (sessionSnapshot ) in
            guard let sessionSnapshot = sessionSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            for session in sessionSnapshot {
                if session.childSnapshot(forPath: "code").value as! String == code {
                    var members = session.childSnapshot(forPath: "members").value as! [String:[String:Any]]
                    members[userID] = ["name":Auth.auth().currentUser?.displayName!,"score":0,"isModerator":false, "hasBeenModerator":false]
                    self.REF_SESSIONS.child(session.key).updateChildValues(["members":members])
                }
            }
        }
    }
    func addMemberstodictionary(session:Session) -> [String:[String:Any]]{
        var result:[String:[String:Any]] = [:]
        for member in session.members {
            if session.moderator?.keys.first == member.key {
                result[member.key] = ["name":member.value, "score":0, "isModerator":true]
            } else {
                result[member.key] = ["name":member.value, "score":0, "isModerator":false]
            }
        }
        return result
    }
    //MARK: Login Support

    func createDBUser(uid:String, userData:Dictionary<String,Any>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }

    func returnDisplayName(userID:String, completion: @escaping (String) -> ())  {

        REF_USERS.observeSingleEvent(of: .value, with: {(userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                if user.key == userID {
                    let displayName = user.childSnapshot(forPath:FirebaseUserKeys.fullName).value as? String
                    completion(displayName!)
                    break
                }
            }
        })
    }

    func registerUser(firstName:String, lastName:String, displayName:String, email:String, password:String, completion: @escaping (_ status:Bool,_ error:Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (registrationComplete, error) in
            if error != nil {
                //                print(error)
                completion(false, error)
            } else {
                //                print(Auth.auth().currentUser)
                //                print(registrationComplete)
                completion(true, nil)
            }
        }
    }

    func loginUser(withEmail email:String, andPassword password:String, completion: @escaping (_ status:Bool,_ error:Error?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }

    func searchEmails(forSearchQuery query: String, handler: @escaping (_ emailArray: [String]) -> ()) {
        var emailArray = [String]()

        REF_USERS.observeSingleEvent(of:.value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as? String

                if ((email?.contains(query))!||((email?.capitalized.contains(query)))!) == true  {
                    emailArray.append(email!)
                }
            }
            handler(emailArray)
        }
    }

    func isDuplicateEmail(_ emailString:String, completion: @escaping (Bool) -> ()){

        REF_USERS.observeSingleEvent(of:.value) { (userSnapshot) in
            //            print(userSnapshot)
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {
                //                print("failed")
                return
            }

            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as? String
                //                print(emailString, "\n" , email! , "\n", "-------------_")

                if email!.lowercased() == emailString.lowercased()  {
                    //                    print("isduplicate email is \(true)")
                    completion(true)
                    return
                }
            }
            //            print("isduplicate email is \(false)")
            completion(false)
        }

    }

    //MARK: Image Management

    func uploadImages(_ imageList:[String]) {
        for image in imageList {
            let key = REF_GIFS.childByAutoId().key!.stripID()
            REF_GIFS.child(key).updateChildValues(["fileName":image, "playedBy":""])
        }
    }

    func loadImageStrings() -> [String] {
        var strings:[String] = []
        REF_IMAGES.observeSingleEvent(of: .value) { (data) in
            guard let data = data.children.allObjects as? [DataSnapshot] else {
                return
            }

            for image in data {
                let fileName = image.childSnapshot(forPath: "fileName") as! String
                strings.append(fileName)
            }
        }
        return strings
    }

    func downloadImage(imageName:String, completion: @escaping ((UIImage) -> ()))  {
        let imageRef = "Meme folder/\(imageName)"
        let storage = Storage.storage()

        let imageToDownload = storage.reference(withPath: imageRef)

        imageToDownload.getData(maxSize: 1 * 1024 * 1024, completion: {(data, error) in
            if let error = error {
                print(error)
            } else {
                let image = UIImage(data: data!)
                completion(image!)
            }
        })
    }
    func returnImage(imageName:String) -> Data?  {
        let imageRef = "Meme Folder/\(imageName)"
        let storage = Storage.storage()
        var returnedData:Data? = nil

        let imageToDownload = storage.reference(withPath: imageRef)

        imageToDownload.getData(maxSize: 1 * 2024 * 2024, completion: {(data, error) in
            if let error = error {
                print(error,#function)
            } else {

                returnedData = data!
            }
        })
        return returnedData
    }

    //MARK: Gif Management

    func uploadGifs(_ gifList:[String]) {
        for gif in gifList {
            let key = REF_GIFS.childByAutoId().key!.stripID()
            REF_GIFS.child(key).updateChildValues(["fileName":gif, "playedBy":""])
        }
    }
    func uploadPrompts(_ promptList:[String]) {
        for prompt in promptList {
            let key = REF_PROMPTS.childByAutoId().key!.stripID()
            REF_PROMPTS.child(key).updateChildValues(["playedBy":"","prompt":prompt,"source":"Cards Against Humanity"])
        }
    }
    

    func loadGifsStrings() -> [String] {
        var strings:[String] = []
        REF_GIFS.observeSingleEvent(of: .value) { (data) in
            guard let data = data.children.allObjects as? [DataSnapshot] else {
                return
            }
            for gif in data {
                let fileName = gif.childSnapshot(forPath: "fileName").value as? String
                if let fileName = fileName {
                    strings.append(fileName)
                } else {
                    //                    print("error parsing filename", #function)
                }
            }
        }
        return strings
    }

    func loadGifsStringsWithCompletion(competion:(@escaping ([String]) -> ())){
        var strings:[String] = []
        REF_GIFS.observeSingleEvent(of: .value) { (data) in
            guard let data = data.children.allObjects as? [DataSnapshot] else {
                return
            }

            for gif in data {
                strings.append(gif.childSnapshot(forPath: "fileName").value as! String )
            }
            competion(strings)
        }
    }

    func downloadGif(gifName:String, completion: @escaping ((Data) -> ()))  {
        let imageRef = "Gif Folder/\(gifName)"
        let storage = Storage.storage()
        //        print("Storage" , "\n", storage, #function )
        let gifToDownload = storage.reference(withPath: imageRef)

        gifToDownload.getData(maxSize: 2 * 2024 * 2024, completion: {(data, error) in
            if let error = error {
                print(error)
            } else {

                completion(data!)
            }
        })
    }

    func returnGif(gifName:String) -> Data?  {
        let imageRef = "Gif Folder/\(gifName)"
        let storage = Storage.storage()
        var returnedData:Data? = nil

        let gifToDownload = storage.reference(withPath: imageRef)
        
        gifToDownload.getData(maxSize: 1 * 2024 * 2024, completion: {(data, error) in
            if let error = error {
                print(error)
            } else {

                returnedData = data!
            }
        })
        return returnedData
    }

    //MARK:- Observer Removal
    func removeBaseObservers() {
        REF_BASE.removeAllObservers()
    }

    func removeSessionObservers() {
        REF_SESSIONS.removeAllObservers()
    }

    func removeGameObservers() {
        REF_GAMES.removeAllObservers()
    }
    func removeUserObservers() {
        REF_USERS.removeAllObservers()
    }

}
