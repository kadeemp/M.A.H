//
//  SignUpViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 7/25/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController: UIViewController {

    @IBOutlet var emailTxtField: UITextField!
    @IBOutlet var passwordTxtField: UITextField!
    @IBOutlet var firstNameTxTField: UITextField!
    @IBOutlet var lastNameTxtField: UITextField!
//    @IBOutlet var avatar: UIImageView!
//    var image:UIImage? = nil

    @IBOutlet var submitBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        //setupAvatar()
        // Do any additional setup after loading the view.
        let tapG = UITapGestureRecognizer(target: self, action: #selector(dismissKey))
        self.view.addGestureRecognizer(tapG)

    }
    @objc func dismissKey() {
        self.view.endEditing(true)
    }
//    func setupAvatar() {
//        avatar.clipsToBounds = true
//        avatar.layer.cornerRadius = avatar.frame.width/2
//        avatar.isUserInteractionEnabled = true
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
//        avatar.addGestureRecognizer(tapGesture)
//    }
//    @objc func presentPicker() {
//        let picker = UIImagePickerController()
//        picker.sourceType = .photoLibrary
//        picker.allowsEditing = true
//        picker.delegate = self
//        self.present(picker, animated: true, completion: nil)
//    }
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error)
        }
    }

    @IBAction func submitTxtField(_ sender: Any) {
        //        guard  else {
        //            print("AVATAR is nil")
        //            return
        //        }
        submitBtn.isEnabled = false
        let fullName = self.firstNameTxTField.text! + " "
            + self.lastNameTxtField.text!
//        if avatar.image != nil {
//            let imageSelected = self.image
//            let imageData = imageSelected!.jpegData(compressionQuality: 0.4)
//            FirebaseController.instance.registerUser(firstName: firstNameTxTField.text!, lastName: lastNameTxtField.text!
//            , displayName:fullName,  email: emailTxtField.text!, password: passwordTxtField.text! ) { (complete, error) in
//                if complete {
//                    print("successful registration")
//                    FirebaseController.instance.loginUser(withEmail: self.emailTxtField.text!, andPassword: self.passwordTxtField.text!, completion: { (loginComplete, error) in
//                        if loginComplete {
//                            let storageRef = Storage.storage().reference(forURL: "gs://m-a-h-43593.appspot.com/")
//                            var userData:[String:Any] = [:]
//
//                            let storageProfileRef = storageRef.child("profilePhotos").child(Auth.auth().currentUser!.uid)
//                            let metaData = StorageMetadata()
//                            metaData.contentType = "image/jpg"
//                            storageProfileRef.putData(imageData!, metadata: metaData) { (storageMetadata, error) in
//                                if error != nil {
//                                    print(error?.localizedDescription)
//                                    return
//                                }
//                                storageProfileRef.downloadURL { (url, error) in
//                                    if error != nil {
//                                        print(error?.localizedDescription)
//                                        return
//                                    }
//                                    userData["profilePhotoURL"] = url?.absoluteString
//                                    userData["email"] = self.emailTxtField.text!
//                                    userData["firstName"] = self.firstNameTxTField.text!
//                                    userData["fullName"] = fullName
//                                    FirebaseController.instance.createDBUser(uid: Auth.auth().currentUser!.uid.stripID(), userData: userData)
//                                    print("user saved to database")
//                                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
//                                    changeRequest?.displayName = self.firstNameTxTField.text!
//
//                                    changeRequest?.photoURL =  URL(string: url!.absoluteString)
//                                    changeRequest?.commitChanges(completion: { (error) in
//                                        if error != nil {
//                                            print(error)
//                                            print("error commiting profile changes")
//                                        }
//                                    })
//                                    AppDelegate.shared.loadMainScreen(window: AppDelegate.shared.window!)
//                                }
//                            }
//                        }
//                    })
//
//                    } else {
//                        print("Error signing user in during registration")
//                        print("\(error?.localizedDescription)")
//                    }
//                }
//        } else {
            FirebaseController.instance.registerUser(firstName: firstNameTxTField.text!, lastName: lastNameTxtField.text!
               , displayName:fullName,  email: emailTxtField.text!, password: passwordTxtField.text! ) { (complete, error) in
                   if complete {
                       print("successful registration")
                       FirebaseController.instance.loginUser(withEmail: self.emailTxtField.text!, andPassword: self.passwordTxtField.text!, completion: { (loginComplete, error) in
                           if loginComplete {
                               var userData:[String:Any] = [:]
                            userData["email"] = self.emailTxtField.text!
                            userData["firstName"] = self.firstNameTxTField.text!
                            userData["fullName"] = fullName
                            FirebaseController.instance.createDBUser(uid: Auth.auth().currentUser!.uid.stripID(), userData: userData)
                            print("user saved to database")
                            AppDelegate.shared.loadMainScreen(window: AppDelegate.shared.window!)
                           }
                       })
                           let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                           changeRequest?.displayName = fullName
                           changeRequest?.commitChanges(completion: { (error) in
                               if error != nil {
                                   print(error)
                                   print("error commiting profile changes")
                               }
                           })
                       } else {
                           print("Error signing user in during registration")
                           print("\(error?.localizedDescription)")
                       }
                   }
//                self.submitBtn.isEnabled = true0..

//            }
        }
    }



//extension SignUpViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
//            image = imageSelected
//            avatar.image = imageSelected
//        }
//        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            image = imageOriginal
//            avatar.image = imageOriginal
//        }
//
//        picker.dismiss(animated: true, completion: nil)
//
//    }
//}
