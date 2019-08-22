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

    func revealPrompt(gameId:String) {
REF_GAMES.child(gameID).child("")
    }

    func returnPromptFromDeck(gameID:String, completion:@escaping ((PromptCard)->())) {
        REF_GAMES.child(gameID).child("prompts").observeSingleEvent(of: .value) { (datasnapshot) in
            guard let prompts = datasnapshot.children.allObjects as? [DataSnapshot] else {
                print("Error getting prompt")
                return }
            
            var shuffledPropmpts = prompts.shuffled()

            if let prompt = shuffledPropmpts.randomElement() {
                let playedBy = prompt.childSnapshot(forPath: "playedBy").value as? String
                let cardPrompt = prompt.childSnapshot(forPath: "prompt").value as? String

                let card = PromptCard(cardKey: prompt.key, prompt: cardPrompt!, playedBy: playedBy, isRevealed: false)
                completion(card)
            } else {
                print("Error getting prompt")
            }

        }
    }
    func loadModerator(gameKey:String,completion: @escaping ((String) -> ())) {

        REF_GAMES.child(gameKey).child("moderator").observeSingleEvent(of: .value) { (datasnapshot) in
            guard let moderator = datasnapshot.value as? String else {
                return
            }
            completion(moderator)
        }

    }

    //MARK:- Games

    func createGame(session:Session, completion: @escaping (()->())) {
        let gameKey = REF_GAMES.childByAutoId().key!
        let scoreboard = addMemberstodictionary(session: session)

        createMemeDeck(gameKey: gameKey) { (deck) in
            self.createPromptDeck(gameKey: gameKey,
                                  completion: {
                                    (prompts) in
                                    self.REF_GAMES.child(gameKey).updateChildValues(["key":gameKey,
                                                                                     "prompts":prompts,
                                                                                     "moderator":session.members.randomElement()!,
                                                                                     "round":1, "scoreboard":scoreboard,
                                                                                     "meme deck":deck,
                                                                                     "sessionID":session.key]
                                    )
                                    self._REF_SESSIONS.child(session.key).updateChildValues(["gameID":gameKey, "state":0])
                                    self.loadHand(session: session)
                                    completion()
            })
        }
    }
    func returnHand(comletion:@escaping (([MemeCard]) -> ())) {
        var cards:[MemeCard] = []
        guard let user = Auth.auth().currentUser?.uid  else {
            return
        }
        DispatchQueue.main.async {
            self.REF_USERS.child(user).child("hand").observeSingleEvent(of: .value) { (snapshot) in
                guard let data = snapshot.children.allObjects as? [DataSnapshot] else {
                    return
                }
                for cardData in data {
                    let fileName = cardData.childSnapshot(forPath: "fileName").value as? String
                    let fileType = cardData.childSnapshot(forPath: "fileType").value as? String
                    let playedBy = cardData.childSnapshot(forPath: "playedBy").value as? String
                    let cardKey = cardData.childSnapshot(forPath: "cardKey").value as? String

                    let card = MemeCard(cardKey: cardKey!, fileName: fileName!, fileType: fileType!, playedBy: playedBy, cardType: "meme", isRevealed: false)
                    print(card)
                    cards.append(card)
                }
                print("completed")
                comletion(cards)
            }
        }
        DispatchQueue.main.async {

        }





    }

    func loadHand(session:Session) {
        let handCount = 5
        REF_GAMES.child(session.gameID!).child("meme deck").observeSingleEvent(of: .value) { (datasnapshot) in
            guard let data = datasnapshot.children.allObjects as? [DataSnapshot?] else {
                return
            }
            var dataArray = data.shuffled()
            var cardDictionary:[String:[String:Any]] = [:]
            if !dataArray.isEmpty {
                for member in session.members {
                    var memberHand:[MemeCard] = []
                    while memberHand.count < 5 {
                        guard  let cardData = dataArray.removeLast() else {
                            return
                        }
                        let fileName = cardData.childSnapshot(forPath: "fileName").value as? String
                        let fileType = cardData.childSnapshot(forPath: "fileType").value as? String
                        let playedBy = cardData.childSnapshot(forPath: "playedBy").value as? String
                        let cardKey = cardData.childSnapshot(forPath: "cardKey").value as? String

                        cardDictionary[cardKey!] = ["cardKey": cardKey!, "fileName": fileName!, "fileType": fileType!, "playedBy": playedBy, "cardType": "meme", "isRevealed": false]

                        let card = MemeCard(cardKey: cardKey!, fileName: fileName!, fileType: fileType!, playedBy: playedBy, cardType: "meme", isRevealed: false)
                        memberHand.append(card)
                    }
                    self.REF_USERS.child(member).child("hand").removeValue()
                    self.REF_USERS.child(member).child("hand").updateChildValues(cardDictionary)
                }
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
                    guard let key = self.REF_GAMES.child(gameKey).childByAutoId().key else {
                        print("error  creating key")
                        return
                    }
                    result[key] =  ["prompt":prompt, "playedby":""]
                }
                completion(result)
            })
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
                    guard let key = self.REF_GAMES.child(gameKey).child("meme-deck").childByAutoId().key else {
                        print("error creating key")
                        return
                    }

                    result[key] = ["cardKey":key, "fileName":gif, "fileType":"gif","playedby":""]
                }
            }
            queue.async(execute: {
                self.loadGifsStringsWithCompletion(competion: { (images) in
                    for image in images {
                        guard let key = self.REF_GAMES.child(gameKey).child("meme-deck").childByAutoId().key else {
                            print("error creating key")
                            return
                        }
                        result[key] = ["cardKey":key, "fileName":image, "fileType":"image","playedby":""]
                    }
                    completion(result)
                })
            })
        })
    }

    func addMemberstodictionary(session:Session) -> [String:Int] {
        var result:[String:Int] = [:]
        for member in session.members {
            result[member] = 0
        }
        return result
    }
    //MARK:- Sessions
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
                    let members = session.childSnapshot(forPath: "members").value as? [String]
                    let key = session.childSnapshot(forPath: "key").value as? String
                    let gameID = session.childSnapshot(forPath: "gameID").value as? String
                    let newSession = Session(host: host!, id: hostID!, code:code! , members: members ?? [], key:key!, gameID: gameID, state: 0)
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

    func createSession(code:String, hostID:String, host:String) {
        if let key = REF_SESSIONS.childByAutoId().key {
            REF_SESSIONS.child(key).updateChildValues(["code":code, "hostID":hostID, "host":host, "members":[Auth.auth().currentUser!.uid], "key":key, "isGameActive":false, "gameID":"", "state":0])
        }
    }
    func updateSessionMembers(session:Session, members:[String], completion: @escaping (() -> ())) {
        REF_SESSIONS.child(session.key).updateChildValues(["members" : members])
    }
    func removeMemberFrom(session:Session, memberID:String, completion:@escaping (([String]) -> ())) {

        var members = session.members
        if session.members.count == 1 {
            REF_SESSIONS.child(session.key).updateChildValues(["members" : []])
            completion([])
            return
        } else {
            for i in 0..<members.count   {
                if members[i] == memberID {

                    members.remove(at: i)
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
                    let members = session.childSnapshot(forPath: "members").value as? [String]
                    let key = session.childSnapshot(forPath: "key").value as? String
                    let gameID = session.childSnapshot(forPath: "gameID").value as? String
                    let newSession = Session(host: host!, id: hostID!,code:code!, members: members ?? [], key:key!, gameID: gameID, state: 0)
                    completion(newSession)
                }
            }
        }
    }
    func addUserToSession(code:String ,userID:String)  {
        REF_SESSIONS.observeSingleEvent(of: .value) { (sessionSnapshot ) in
            guard let sessionSnapshot = sessionSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            for session in sessionSnapshot {
                if session.childSnapshot(forPath: "code").value as! String == code {
                    var members = session.childSnapshot(forPath: "members").value as! [String]
                    members.append(userID)
                    self.REF_SESSIONS.child(session.key).updateChildValues(["members":members])
                }
            }
        }
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
                print(error)
                completion(false, error)
            } else {
                print(Auth.auth().currentUser)
                print(registrationComplete)
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
            print(userSnapshot)
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {
                print("failed")
                return
            }

            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as? String
                print(emailString, "\n" , email! , "\n", "-------------_")

                if email!.lowercased() == emailString.lowercased()  {
                    print("isduplicate email is \(true)")
                    completion(true)
                    return
                }
            }
            print("isduplicate email is \(false)")
            completion(false)
        }

    }

    //MARK: Image Management

    func uploadImages(_ imageList:[String]) {
        for image in imageList {
            REF_GIFS.childByAutoId().updateChildValues(["fileName":image, "playedBy":""])
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
                // Uh-oh, an error occurred!
                print(error)
            } else {

                returnedData = data!
            }
        })
        return returnedData
    }

    //MARK: Gif Management

    func uploadGifs(_ gifList:[String]) {
        for gif in gifList {
            REF_GIFS.childByAutoId().updateChildValues(["fileName":gif, "playedBy":""])
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
                    print("error parsing filename", #function)
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

        let gifToDownload = storage.reference(withPath: imageRef)

        gifToDownload.getData(maxSize: 1 * 2024 * 2024, completion: {(data, error) in
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
                // Uh-oh, an error occurred!
                print(error)
            } else {

                returnedData = data!
            }
        })
        return returnedData
    }

}
