//
//  SSImagesCell.swift
//  SwiftSelfie
//
//  Created by Justin Wong on 11/14/15.
//  Copyright (c) 2015 TEST. All rights reserved.
//

import Foundation
import UIKit

class SSImagesCell: UICollectionViewCell {
    
    var instagramImage = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        //Add our imageview to the cells view
        addSubview(instagramImage)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //Set image views frame to size of cell
        instagramImage.frame = bounds
    }
}