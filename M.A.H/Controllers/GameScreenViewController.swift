//
//  GameScreenViewController.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 8/6/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit

class GameScreenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate {
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

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = cards.remove(at: sourceIndexPath.item)
        cards.insert(item, at: destinationIndexPath.item)
        print(cards)
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
    fileprivate var longPressGesture: UILongPressGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        cardCollectionView.dragInteractionEnabled = true
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        cardCollectionView.dragDelegate = self

        // Do any additional setup after loading the view.
    }
    var isCardVisible = false

    var cards = ["0","1","2","3","4"]
    
    @IBOutlet var scoreboardButton: UIButton!
    @IBOutlet var drawerBottomConstraint: NSLayoutConstraint!
    @IBOutlet var tableImageView: UIImageView!
    @IBOutlet var promptDeckImageView: UIButton!
    @IBOutlet var memeDeckimageview: UIButton!
    @IBOutlet var cardDrawer: UIView!
    @IBOutlet var cardCollectionView: UICollectionView!

    @IBOutlet var slideUpIndicatorButton: UIButton!
    @IBAction func slideupIndicatorTriggered(_ sender: Any) {
        if !isCardVisible {
            isCardVisible = true
            UIView.animate(withDuration: 0.5) {
                self.drawerBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            }} else {
            isCardVisible = false
                UIView.animate(withDuration: 0.5) {
                    self.drawerBottomConstraint.constant = -280
                    self.view.layoutIfNeeded()

            }

        }
    }
}

