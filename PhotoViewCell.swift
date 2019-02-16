//
//  PhotoViewCell.swift
//  Final Project
//
//  Created by Malak Bassam on 2/16/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class PhotoViewCell: UICollectionViewCell {
  
    
    var imageUrl: String = ""
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}
