//
//  CardCollectionViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 1/7/20.
//  Copyright © 2020 Kadeem Palacios. All rights reserved.
//

import UIKit
import Firebase
import AlamofireImage

class CardCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate {

    let columns:CGFloat = 2.5
    let inset:CGFloat = 10.0
    let spacing:CGFloat = 8.0

    @IBOutlet var cardCollectionView: UICollectionView!

        var cards:[MemeCard] = []

        override func viewDidLoad() {
            super.viewDidLoad()
            cardCollectionView =  UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
            let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
            layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
            cardCollectionView.setCollectionViewLayout(layout, animated: true)
            cardCollectionView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
            cardCollectionView.delegate = self
            cardCollectionView.dataSource = self
            cardCollectionView.dragDelegate = self
            cardCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)

            guard let user = Auth.auth().currentUser else {
                return
            }

            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 5)) {
                FirebaseController.instance.returnHand(user: user.uid) { returnedCards in
                    self.cards = returnedCards
                    self.cardCollectionView.reloadData()
                }
            }
                    cardCollectionView.backgroundColor = .red
            view.addSubview(cardCollectionView)
    //        cardCollectionView.translatesAutoresizingMaskIntoConstraints = false
    //        NSLayoutConstraint.activate([
    //            cardCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
    //            cardCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200),
    //            //.constraint(equalTo: view.bottomAnchor),
    //            cardCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -70),
    //            cardCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10)
    //            ])




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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cardCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardCollectionViewCell
        let card = cards[indexPath.row]
        let url = URL(string: card.fileName)!
        var downloadedImage = UIImageView(frame: cell.frame)
        downloadedImage.setGifFromURL(url)
        downloadedImage.backgroundColor = .green

        cell.addSubview(downloadedImage)
       cell.backgroundColor = .black
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {

        return dragItems(for: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        var width:Int!
//        var height:Int!
//        var size:CGSize!
//
//        switch collectionView {
//        case cardCollectionView:
//            width = Int(collectionView.frame.width / columns)
//            height = Int(collectionView.frame.height /
//                2)
//            size = CGSize(width: width, height: height)
//            return size
//        default:
//            print()
//
//        }
        return CGSize(width: 60, height: 40)
    }



}
