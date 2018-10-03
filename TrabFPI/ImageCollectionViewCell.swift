//
//  ImageCollectionViewCell.swift
//  TrabFPI
//
//  Created by Laura Corssac on 01/10/2018.
//  Copyright © 2018 Laura Corssac. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let cellImage = image {
            self.imageView.frame.size = cellImage.size
            self.imageView.center = contentView.center
        }
    }
    func configure(with image: UIImage) {
        self.image = image
        self.imageView.frame.size = image.size
        self.imageView.center = contentView.center
        self.imageView.image = image
       
    }
    
}
