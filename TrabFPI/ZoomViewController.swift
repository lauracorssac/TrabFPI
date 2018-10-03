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
enum MenuState {
    case hidden, visible
}

class ZoomViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var constraint: NSLayoutConstraint!
    
    var images: [UIImage] = []
    
    private let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
    let originalImageName =  "dog"
    let cellIdentifier = "imageCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapMenu(_:))))
        
        collectionView.dataSource = self
        let image = UIImage(named: originalImageName)!
        images = [image]
        collectionView.reloadData()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
        presentMenuVC()
        
    }
    func animateMenu() {
        self.animator.addAnimations {
            self.constraint.constant = self.constraint.constant == 0 ? 500 : 0
            self.view.layoutIfNeeded()
        }
        self.animator.startAnimation()
    }
    @objc func didTapMenu(_: UIGestureRecognizer) {
       animateMenu()
    }
    func presentMenuVC() {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "menuVC") as! ControlViewController
        viewController.delegate = self
        self.addChildViewController(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
    }
}
extension ZoomViewController: ControlVCDelegate {
    
    func didSelect(option: MenuOption, kernel: [Double], sx: Int, sy: Int, quantization: Int, contrastMultiplier: Double, brightB: Int, sum127: Bool) {
        
        //let image = smallImageView.image!.cgImage!
        
        let image = (self.images.first?.cgImage)!
        var cgImages: [CGImage?] = [image]
        
        let target = (UIImage(named: "dog")?.cgImage!)!
        
        switch option {
        case .zoomIn:
            cgImages = [PhotoManager.shared.zoomIn(image: image)]
        case .zoomOut:
            cgImages = [PhotoManager.shared.zoomOut(image: image, sx: sx, sy: sy)]
        case .convolve:
            cgImages = [PhotoManager.shared.convolve(image: image, kernel: kernel, sum: sum127)]
        case .rotateRight:
            cgImages = [PhotoManager.shared.rotate(image: image, rotateDirection: .right)]
        case .rotateLeft:
            cgImages = [PhotoManager.shared.rotate(image: image, rotateDirection: .left)]
        case .contrast:
            cgImages = [ PhotoManager.shared.contrast(image: image, multiplier: contrastMultiplier)]
        case .negative:
            cgImages = [PhotoManager.shared.negative(image: image)]
        case .brightness:
            cgImages = [PhotoManager.shared.brightness(image: image, b: brightB)]
        case .original:
            cgImages = [UIImage(named: originalImageName)?.cgImage]
        case .histogram:
            let result = PhotoManager.shared.histogram(from: image)
            cgImages.append(result)
        case .equalizedHistogram:
            let results = PhotoManager.shared.makeEqualizedHistogramImage(from: image)
            cgImages.append(contentsOf: results)
        case .matching:
            let result = PhotoManager.shared.makeMatchingHistogramImage(source: image, target: target)
            cgImages.append(result)
            cgImages.append(target)
        case .flipVertical:
            cgImages = [PhotoManager.shared.flipVertical(image: image)]
        case .flipHorizontal:
            cgImages = [PhotoManager.shared.flipHorizontal(image: image)]
        case .grayScale:
            cgImages = [PhotoManager.shared.grayScale(image: image)]
        case .copy:
            cgImages = [PhotoManager.shared.copy(image: image)]
        case .save:
            PhotoManager.shared.save(image: image, name: "copy.jpg")
        case .quantization:
            cgImages = [PhotoManager.shared.quantization(image: image, shadesNumber: quantization)]
        }
        var uiimages: [UIImage] = []
        for cgImage in cgImages {
            if let outImage = cgImage {
                let uiImage = UIImage(cgImage: outImage)
                uiimages.append(uiImage)
            }
        }
        images = uiimages
        collectionView.reloadData()
        animateMenu()
    }
}
extension ZoomViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ImageCollectionViewCell
        cell.configure(with: images[indexPath.row])
        return cell
    }
}

