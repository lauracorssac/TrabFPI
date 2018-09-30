//
//  ControlViewController.swift
//  TrabFPI
//
//  Created by Laura Corssac on 30/09/2018.
//  Copyright © 2018 Laura Corssac. All rights reserved.
//

import UIKit


enum MenuOption {
    case zoomIn, zoomOut, convolve, rotateRight, rotateLeft
}

protocol ControlVCDelegate: class {
    func didSelect(option: MenuOption)
}

class ControlViewController: UIViewController {
    
    weak var delegate: ControlVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    @IBAction func rotateLeftPressed(_ sender: UIButton) {
        delegate?.didSelect(option: .rotateLeft)
    }
    @IBAction func rotateRightPressed(_ sender: UIButton) {
        delegate?.didSelect(option: .rotateRight)
    }
    @IBAction func zoomInPressed(_ sender: UIButton) {
        delegate?.didSelect(option: .zoomIn)
    }
    @IBAction func convolvePressed(_ sender: UIButton) {
        delegate?.didSelect(option: .convolve)
    }
    @IBAction func zoomOutPressed(_ sender: UIButton) {
        delegate?.didSelect(option: .zoomOut)
    }
    
}
