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
    private var _REF_IMAGES = DB_BASE.child("images")

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

    func createDBUser(uid:String, userData:Dictionary<String,Any>) {
        REF_USERS.child(uid).updateChildValues(userData)
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
                    let newSession = Session(host: host!, id: hostID!, code:code! , members: members ?? [], key:key!)
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
            REF_SESSIONS.child(key).updateChildValues(["code":code, "hostID":hostID, "host":host, "members":[Auth.auth().currentUser!.uid], "key":key])
        }
    }
    func removeMemberFrom(session:Session, members:[String], completion: @escaping (() -> ())) {
        REF_SESSIONS.child(session.key).updateChildValues(["members" : members])
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
                    let newSession = Session(host: host!, id: hostID!,code:code!, members: members ?? [], key:key!)
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

    func returnDisplayName(userID:String, completion: @escaping (String) -> ())  {

                REF_USERS.observeSingleEvent(of: .value, with: {(userSnapshot) in
                    guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
                    for user in userSnapshot {
                        if user.key == userID {
                            let displayName = user.childSnapshot(forPath:FirebaseUserKeys.fullName).value as? String
                            completion(displayName!)
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
                let fileName = gif.childSnapshot(forPath: "fileName") as! String
                strings.append(fileName)
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
                print(gif.childSnapshot(forPath: "fileName").value as! String )
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