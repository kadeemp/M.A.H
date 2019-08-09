//
//  GameScreenViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 8/6/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit

class GameScreenViewController: UIViewController{
    var isCardVisible = false

    var cards = ["0","1","2","3","4"]
    
    @IBOutlet var tableHolderView: UIView!
    @IBOutlet var scoreboardButton: UIButton!
    @IBOutlet var drawerBottomConstraint: NSLayoutConstraint!
    @IBOutlet var tableImageView: UIImageView!
    @IBOutlet var promptDeckImageView: UIButton!
    @IBOutlet var memeDeckimageview: UIButton!
    @IBOutlet var cardDrawer: UIView!
    @IBOutlet var cardCollectionView: UICollectionView!
    @IBOutlet var slideUpIndicatorButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        cardCollectionView.dragInteractionEnabled = true
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        cardCollectionView.dragDelegate = self
        cardCollectionView.dropDelegate = self

        let dropI = UIDropInteraction(delegate: self)
        self.tableHolderView.addInteraction(dropI)

    }

    @IBAction func slideupIndicatorTriggered(_ sender: Any) {
        if !isCardVisible {
            isCardVisible = true
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5) {
                    self.drawerBottomConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }}} else {
                    self.isCardVisible = false
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.5) {
                            self.drawerBottomConstraint.constant = -280
                            self.view.layoutIfNeeded()
                        }
                    }
            }

        }
    }


extension GameScreenViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate, UICollectionViewDropDelegate , UIDropInteractionDelegate {

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {

    }

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {

        return dragItems(for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cardCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.orange
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }


    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {

        let pet = cards[indexPath.row]

        let itemProvider = NSItemProvider()
        itemProvider.registerDataRepresentation(forTypeIdentifier: "public.text", visibility: .all) { completion in

            let data = pet.data(using: .utf8)
            completion(data, nil)
            return nil

        }

        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = pet
        return [dragItem]

    }
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        //
        print("dropped")
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        print("\(session.location(in: self.view))")

        return UIDropProposal(operation: .move)
    }
}

