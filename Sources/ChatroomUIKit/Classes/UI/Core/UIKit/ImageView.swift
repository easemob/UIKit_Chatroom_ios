//
//  ImageView.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit
import SDWebImage

/// A subclass of `UIImageView` that provides a method for loading an image from a URL.
@objc final public class ImageView: UIImageView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Loads an image from the specified URL and sets it as the image of the image view.
    /// - Parameters:
    ///   - url: The URL of the image to load.
    ///   - placeHolder: An optional placeholder image to display while the image is being loaded.
    public func image(with url: String,placeHolder: UIImage?) {
        self.sd_setImage(with: URL(string: url), placeholderImage: placeHolder, options: .retryFailed, context: nil)
    }

}
