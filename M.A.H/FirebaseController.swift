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



    //MARK: // Login Support


    func returnDisplayName( completion: @escaping (String) -> ())  {
        if let thisUser = Auth.auth().currentUser {
            REF_USERS.child(thisUser.uid).observeSingleEvent(of: .value, with: {(userSnapshot) in
                guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
                for user in userSnapshot {
                    if user.key ==
                        FirebaseUserKeys.displayName {
                        guard let result = user.value  as? String else {return}
                        completion(result)
                    }
                }
            })
        } else {
            print("cound not load \(#function)")
        }

    }

    func registerUser(firstName:String, lastName:String, displayName:String, completion: @escaping (_ status:Bool,_ error:Error?) -> ()) {

        guard let user = Auth.auth().currentUser else {
            print("user not signed in")
            return }
        let userData = ["provider":user.providerID , "email":user.email!, "firstName": firstName, "fullName": user.displayName, "displayName":displayName] as [String : Any]
        FirebaseController.instance.createDBUser(uid: user.uid, userData: userData)
        completion(true, nil)

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
