//
//  GiftsView.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit

/// GiftsView event actions delegate
@objc public protocol GiftsViewActionEventsDelegate: NSObjectProtocol {
    
    /// Send button click
    /// - Parameter item: `GiftEntityProtocol`
    func onGiftSendClick(item: GiftEntityProtocol)
    
    /// Select a gift item.
    /// - Parameter item: `GiftEntityProtocol`
    func onGiftSelected(item: GiftEntityProtocol)
}

@objcMembers open class GiftsView: UIView {
        
    lazy private var eventHandlers: NSHashTable<GiftsViewActionEventsDelegate> = NSHashTable<GiftsViewActionEventsDelegate>.weakObjects()
    
    /// Add UI action handler.
    /// - Parameter actionHandler: ``GiftsViewActionEventsDelegate``
    public func addActionHandler(actionHandler: GiftsViewActionEventsDelegate) {
        if self.eventHandlers.contains(actionHandler) {
            return
        }
        self.eventHandlers.add(actionHandler)
    }

    /// Remove UI action handler.
    /// - Parameter actionHandler: ``GiftsViewActionEventsDelegate``
    public func removeEventHandler(actionHandler: GiftsViewActionEventsDelegate) {
        self.eventHandlers.remove(actionHandler)
    }

    var gifts = [GiftEntityProtocol]()

    lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (self.frame.width - 30) / 4.0, height: (110 / 84.0) * (self.frame.width - 30) / 4.0)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }()

    lazy var giftList: UICollectionView = {
        UICollectionView(frame: CGRect(x: 15, y: 0, width: self.frame.width - 30, height: Appearance.giftDialogContainerConstraintsSize.height-60-BottomBarHeight), collectionViewLayout: self.flowLayout).registerCell(ComponentsRegister.shared.GiftsCell.self, forCellReuseIdentifier: "GiftEntityCell").delegate(self).dataSource(self).showsHorizontalScrollIndicator(false).backgroundColor(.clear).showsVerticalScrollIndicator(false)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// Gifts view init method.
    /// - Parameters:
    ///   - frame: frame
    ///   - gifts: Conform ``GiftEntityProtocol`` class instance array.
    @objc required public convenience init(frame: CGRect, gifts: [GiftEntityProtocol]) {
        self.init(frame: frame)
        self.gifts = gifts
        self.giftList.bounces = false
        self.addSubViews([self.giftList])
        self.backgroundColor = .clear
        self.giftList.isScrollEnabled = true
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        consoleLogInfo("deinit \(self.swiftClassName ?? "")", type: .debug)
    }
}

extension GiftsView: UICollectionViewDelegate,UICollectionViewDataSource,GiftEntityCellActionEvents {
    public func onSendClicked(item: GiftEntityProtocol) {        
        for handler in self.eventHandlers.allObjects {
            handler.onGiftSendClick(item: item)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.gifts.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: ComponentsRegister.shared.GiftsCell, for: indexPath, reuseIdentifier: "GiftEntityCell")
        cell.refresh(item: self.gifts[safe: indexPath.row])
        cell.eventsDelegate = self
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        self.gifts.forEach { $0.selected = false }
        if let gift = self.gifts[safe: indexPath.row] {
            gift.selected = true
            for handler in self.eventHandlers.allObjects {
                handler.onGiftSelected(item: gift)
            }
        }
        self.giftList.reloadData()
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        super.hitTest(point, with: event)
    }

}


extension UICollectionView {
    /// Dequeues a UICollectionView Cell with a generic type and indexPath
    /// - Parameters:
    ///   - type: A generic cell type
    ///   - indexPath: The indexPath of the row in the UICollectionView
    /// - Returns: A Cell from the type passed through
    func dequeueReusableCell<Cell: UICollectionViewCell>(with type: Cell.Type, for indexPath: IndexPath, reuseIdentifier: String) -> Cell {
        dequeueReusableCell(withReuseIdentifier: reuseIdentifier , for: indexPath) as! Cell
    }
}
