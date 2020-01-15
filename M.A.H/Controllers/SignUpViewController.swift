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
    @IBOutlet var avatar: UIImageView!
    var image:UIImage? = nil

    @IBOutlet var submitBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAvatar()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        self.view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    @objc func dismissView() {
        self.view.endEditing(true)
    }
    func setupAvatar() {
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = avatar.frame.width/2
        avatar.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        avatar.addGestureRecognizer(tapGesture)
    }
    @objc func presentPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error)
        }
    }

    @IBAction func submitTxtField(_ sender: Any) {
        guard let imageSelected = self.image else {
            print("AVATAR is nil")
            return
        }
        guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else {
            return
        }
        submitBtn.isEnabled = false
        let fullName = self.firstNameTxTField.text! + " "
            + self.lastNameTxtField.text!
        FirebaseController.instance.registerUser(firstName: firstNameTxTField.text!, lastName: lastNameTxtField.text!
        , displayName:fullName,  email: emailTxtField.text!, password: passwordTxtField.text! ) { (complete, error) in
            if complete {
                print("successful registration")
                FirebaseController.instance.loginUser(withEmail: self.emailTxtField.text!, andPassword: self.passwordTxtField.text!, completion: { (loginComplete, error) in
                    if loginComplete {
                        let storageRef = Storage.storage().reference(forURL: "gs://m-a-h-43593.appspot.com/")
                        var userData:[String:Any] = [:]

                        let storageProfileRef = storageRef.child("profilePhotos").child(Auth.auth().currentUser!.uid)
                        let metaData = StorageMetadata()
                        metaData.contentType = "image/jpg"
                        storageProfileRef.putData(imageData, metadata: metaData) { (storageMetadata, error) in
                            if error != nil {
                                print(error?.localizedDescription)
                                return
                            }
                            storageProfileRef.downloadURL { (url, error) in
                                if error != nil {
                                    print(error?.localizedDescription)
                                    return
                                }


                                userData["profilePhotoURL"] = url?.absoluteString
                                userData["email"] = self.emailTxtField.text!
                                userData["firstName"] = self.firstNameTxTField.text!

                                userData["fullName"] = fullName
                                FirebaseController.instance.createDBUser(uid: Auth.auth().currentUser!.uid.stripID(), userData: userData)
                                 print("user saved to database")
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let navigationController:UINavigationController =  UINavigationController()
                                let rootViewController:UIViewController = storyboard.instantiateViewController(withIdentifier: "StartGame")
                                navigationController.viewControllers = [rootViewController]
                                self.view.window?.rootViewController = navigationController
                                self.view.window?.makeKeyAndVisible()
                            }

                        }
                        //self.performSegue(withIdentifier: "toStartGame", sender: self)


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
                })

            } else {
                self.submitBtn.isEnabled = true
                print(error)
            }
        }
    }

}

extension SignUpViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = imageSelected
            avatar.image = imageSelected
        }
        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = imageOriginal
            avatar.image = imageOriginal
        }

        picker.dismiss(animated: true, completion: nil)

    }
}
