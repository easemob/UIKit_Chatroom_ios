//
//  GiftsBarrageList.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit


@objc public protocol IGiftsBarrageListDrive {
    /// Refresh the UI after receiving the gift
    /// - Parameter gift: GiftEntityProtocol
    func receiveGift(gift: GiftEntityProtocol)
}

/// A protocol that defines optional methods for transforming animations in the GiftsBarrageList.
@objc public protocol GiftsBarrageListTransformAnimationDataSource: NSObjectProtocol {
    
    /// An optional method that returns the row height for the GiftsBarrageList.
    @objc optional func rowHeight() -> CGFloat
    
    /// An optional method that returns the zoom scale for the x-axis of the GiftsBarrageList.
    @objc optional func zoomScaleX() -> CGFloat
    
    /// An optional method that returns the zoom scale for the y-axis of the GiftsBarrageList.
    @objc optional func zoomScaleY() -> CGFloat
}

@objc open class GiftsBarrageList: UIView {
    
    public var dataSource: GiftsBarrageListTransformAnimationDataSource?
    
    public var gifts = [GiftEntityProtocol]() {
        didSet {
            if self.gifts.count > 0 {
                DispatchQueue.main.async {
                    self.cellAnimation()
                }
            }
        }
    }

    private var lastOffsetY = CGFloat(0)

    public lazy var giftList: UITableView = {
        UITableView(frame: CGRect(x: 5, y: 0, width: self.frame.width - 20, height: self.frame.height), style: .plain).tableFooterView(UIView()).separatorStyle(.none).showsVerticalScrollIndicator(false).showsHorizontalScrollIndicator(false).delegate(self).dataSource(self).backgroundColor(.clear).isUserInteractionEnabled(false)
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        CAGradientLayer().startPoint(CGPoint(x: 0, y: 0)).endPoint(CGPoint(x: 0, y: 0.1)).colors([UIColor.clear.withAlphaComponent(0).cgColor, UIColor.clear.withAlphaComponent(1).cgColor]).locations([NSNumber(0), NSNumber(1)]).rasterizationScale(UIScreen.main.scale).frame(self.blurView.frame)
    }()
    
    private lazy var blurView: UIView = {
        UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)).backgroundColor(.clear)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// Init method.
    /// - Parameters:
    ///   - frame: Layout coordinates
    ///   - source: GiftsBarrageListDataSource
    @objc public convenience init(frame: CGRect, source: GiftsBarrageListTransformAnimationDataSource? = nil) {
        self.init(frame: frame)
        self.dataSource = source
        self.backgroundColor = .clear
        self.addSubViews([self.blurView,self.giftList])
        self.giftList.isScrollEnabled = false
        self.giftList.isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        consoleLogInfo("deinit \(self.swiftClassName ?? "")", type: .debug)
    }
}


extension GiftsBarrageList: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.gifts.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.dataSource?.rowHeight?() ?? 58
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        cell.alpha = 0
        cell.isUserInteractionEnabled = false
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(with: ComponentsRegister.shared.GiftBarragesViewCell, reuseIdentifier: "GiftBarrageCell")
        if cell == nil {
            cell = ComponentsRegister.shared.GiftBarragesViewCell.init(style: .default, reuseIdentifier: "GiftBarrageCell")
        }
        if let entity = self.gifts[safe: indexPath.row] {
            cell?.refresh(item: entity)
        }
        return cell ?? GiftBarrageCell()
    }

    internal func cellAnimation() {
        DispatchQueue.main.async {
            self.alpha = 1
            self.isHidden = false
            self.giftList.reloadData()
            var indexPath = IndexPath(row: 0, section: 0)
            if self.gifts.count >= 2 {
                indexPath = IndexPath(row: self.gifts.count - 2, section: 0)
            }
            if self.gifts.count > 1 {
                let cell = self.giftList.cellForRow(at: indexPath) as? GiftBarrageCell
                UIView.animate(withDuration: 0.3) {
                    cell?.alpha = 0.75
                    cell?.contentView.transform = CGAffineTransform(scaleX: self.dataSource?.zoomScaleX?() ?? 0.75, y: self.dataSource?.zoomScaleY?() ?? 0.75)
                    self.giftList.scrollToRow(at: IndexPath(row: self.gifts.count - 1, section: 0), at: .top, animated: false)
                } completion: { finished in
                    if finished {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            UIView.animate(withDuration: 0.3, delay: 1, options: .curveEaseInOut) {
                                self.alpha = 0
                                self.isHidden = true
                            } completion: { _ in
                                self.gifts.removeAll()
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    UIView.animate(withDuration: 0.3, delay: 1, options: .curveEaseInOut) {
                        self.alpha = 0
                        self.isHidden = true
                    } completion: { _ in
                        self.gifts.removeAll()
                    }
                }
            }
        }
    }
}

extension GiftsBarrageList: GiftsBarrageListTransformAnimationDataSource {
    public func rowHeight() -> CGFloat {
        58
    }
    
    public func zoomScaleX() -> CGFloat {
        0.75
    }
    
    public func zoomScaleY() -> CGFloat {
        0.75
    }
}

extension GiftsBarrageList: IGiftsBarrageListDrive {
    public func receiveGift(gift: GiftEntityProtocol) {
        self.gifts.append(gift)
    }
}
