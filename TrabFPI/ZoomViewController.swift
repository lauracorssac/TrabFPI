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

    @IBOutlet weak var smallImageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var constraint: NSLayoutConstraint!
    
    private let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "dog")!
        self.smallImageView.frame.size = image.size
        self.smallImageView.center = view.center
        self.smallImageView.image = image
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapMenu(_:))))
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
    func didSelect(option: MenuOption) {
        var cgImage: CGImage?
        let image = smallImageView.image!.cgImage!
        let kernel = [0.0625, 0.125, 0.0625, 0.125, 0.25, 0.125, 0.0625, 0.125, 0.0625]
        switch option {
        case .zoomIn:
            cgImage = PhotoManager.shared.zoomIn(image: image)
        case .zoomOut:
            cgImage = PhotoManager.shared.zoomOut(image: image, sx: 2, sy: 2)
        case .convolve:
            cgImage = PhotoManager.shared.convolve(image: image, kernel: kernel)
        case .rotateRight:
            cgImage = PhotoManager.shared.rotate(image: image, rotateDirection: .right)
        case .rotateLeft:
            cgImage = PhotoManager.shared.rotate(image: image, rotateDirection: .left)
        }
        if let outImage = cgImage {
            let uiImage = UIImage(cgImage: outImage)
            self.smallImageView.frame.size = uiImage.size
            self.smallImageView.center = view.center
            self.smallImageView.image = uiImage
        }
        animateMenu()
    }
}
