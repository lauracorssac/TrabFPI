//
//  ZoomViewController.swift
//  TrabFPI
//
//  Created by Laura Corssac on 27/09/2018.
//  Copyright © 2018 Laura Corssac. All rights reserved.
//

import UIKit

enum RotateDirection {
    case left, right
}

class ZoomViewController: UIViewController {

    @IBOutlet weak var smallImageView: UIImageView!
    @IBOutlet weak var zoomedImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "dog")!
        self.smallImageView.frame.size = image.size
        self.smallImageView.center = view.center
        self.smallImageView.image = image
        
    }
    
    @IBAction func zoomOutPressed(_ sender: UIButton) {
        let cgimage = PhotoManager.shared.zoomOut(image: (smallImageView.image!.cgImage)!, sx: 2, sy: 2)
        if let image = cgimage {
            self.zoomedImageView.image = UIImage(cgImage: image)
        }
    }
    
    
    @IBAction func convolvePressed(_ sender: UIButton) {
        let kernel = [0.0625, 0.125, 0.0625, 0.125, 0.25, 0.125, 0.0625, 0.125, 0.0625]
        if let cgImage = PhotoManager.shared.convolve(image: smallImageView.image!.cgImage!, kernel: kernel) {
            let uiImage = UIImage(cgImage: cgImage)
            self.smallImageView.frame.size = uiImage.size
            self.smallImageView.center = view.center
            self.smallImageView.image = uiImage
            
        }
    }
    
    @IBAction func zoom(_ sender: UIButton) {
        let cgimage = PhotoManager.shared.zoomIn(image: smallImageView.image!.cgImage!)
        if let image = cgimage {
            let uiImage = UIImage(cgImage: image)
            self.smallImageView.frame.size = uiImage.size
            self.smallImageView.center = view.center
            self.smallImageView.image = uiImage
        }
    }
   
    @IBAction func rotateLeftPressed(_ sender: UIButton) {
        
        if let cgImage = PhotoManager.shared.rotate(image: smallImageView.image!.cgImage!, rotateDirection: .left) {
            let uiImage = UIImage(cgImage: cgImage)
            
            self.smallImageView.frame.size = uiImage.size
            self.smallImageView.center = view.center
            self.smallImageView.image = uiImage
            
        }
    }
   
    @IBAction func rotateRightPressed(_ sender: UIButton) {
        if let cgImage = PhotoManager.shared.rotate(image: smallImageView.image!.cgImage!, rotateDirection: .right) {
            let uiImage = UIImage(cgImage: cgImage)
            self.smallImageView.frame.size = uiImage.size
            self.smallImageView.center = view.center
            self.smallImageView.image = uiImage
            
        }
    }
}
