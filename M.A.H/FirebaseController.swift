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
    let gifs = ["MERYL STREEP YES.gif", "CardiBIHateThat.gif", "ImIntoThat.gif", "SusConceited.gif", "OKURRRRRR.gif", "Waka_Okay...gif", "ImSorryWHAT.gif", "WoooooordCardiB.gif", "ObamaPoints.gif", "kenanFaceThanos.gif", "StephCurrySMH.gif", "WendyWiliamsStare.gif", "BlackhousewivesofatlantaWHOSAIDTHAT.gif", "UNIMPRESSED NEIL DEGRASSE.gif", "JudgingJustinT.gif", "INCREDULOUS COME ON.gif", "StanleyEyeRoll.gif", "spideyPoints.gif", "NickYoungWTF.gif", "annoyedObama.gif", "STOP IT MICHAEL JORDAN.gif", "HardenEyeRoll.gif", "ThinkAboutIt.gif"]




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
        for gif in gifs {
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
