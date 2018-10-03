//
//  ControlViewController.swift
//  TrabFPI
//
//  Created by Laura Corssac on 30/09/2018.
//  Copyright © 2018 Laura Corssac. All rights reserved.
//

import UIKit


enum MenuOption {
    case zoomIn, zoomOut, convolve, rotateRight, rotateLeft, contrast, negative, brightness, original, histogram, equalizedHistogram, matching, flipVertical, flipHorizontal, grayScale, copy, save, quantization
}

protocol ControlVCDelegate: class {
    func didSelect(option: MenuOption, kernel: [Double], sx: Int, sy: Int, quantization: Int, contrastMultiplier: Double, brightB: Int, sum127: Bool)
}
extension ControlVCDelegate {
    func didSelect(option: MenuOption, kernel: [Double] = [], sx: Int = 0, sy: Int = 0, quantization: Int = 0, contrastMultiplier: Double = 0.0, brightB: Int = 0, sum127: Bool = true) {
        return didSelect(option: option, kernel: kernel, sx: sx, sy: sy, quantization: quantization, contrastMultiplier: contrastMultiplier, brightB: brightB, sum127: sum127)
    }
}

class ControlViewController: UIViewController {
   
    @IBOutlet weak var shadesNumberTextField: UITextField!
    @IBOutlet weak var kernelTextStackView: UIStackView!
    @IBOutlet weak var sxTextField: UITextField!
    @IBOutlet weak var syTextField: UITextField!
    @IBOutlet weak var contrastTextField: UITextField!
    @IBOutlet weak var brightnessTextField: UITextField!
    
    weak var delegate: ControlVCDelegate?
    let gaussianKernel = [0.0625, 0.125, 0.0625, 0.125, 0.25, 0.125, 0.0625, 0.125, 0.0625 ]
    let passaAltaKernel: [Double] =  [-1, -1, -1, -1, 8, -1, -1, -1, -1 ]
    
    func makeStackRed() {
        
        for view in kernelTextStackView.arrangedSubviews {
            let stack = view as! UIStackView
            for textFieldView in stack.arrangedSubviews {
                let textField = textFieldView as! UITextField
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1.2
            }
        }
    }
    
    func fillStackView(with kernel: [Double]) {
        for j in 0..<3 {
            let stack = kernelTextStackView.arrangedSubviews[j] as! UIStackView
            for i in 0..<3{
                let textField = stack.arrangedSubviews[i] as! UITextField
                textField.text = "\(kernel[ 3*j + i])"
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for view in kernelTextStackView.arrangedSubviews {
            let stack = view as! UIStackView
            for textFieldView in stack.arrangedSubviews {
                let textField = textFieldView as! UITextField
                textField.delegate = self
            }
        }
        shadesNumberTextField.delegate = self
        sxTextField.delegate = self
        syTextField.delegate = self
        contrastTextField.delegate = self
        brightnessTextField.delegate = self
       
    }
    
    @IBAction func histogramPressed(_ sender: UIButton) {
        delegate?.didSelect(option: .histogram)
    }
    @IBAction func matchingPressed(_ sender: UIButton) {
        delegate?.didSelect(option: .matching)
    }
    @IBAction func equalizePressed(_ sender: UIButton) {
        delegate?.didSelect(option: .equalizedHistogram)
    }
    @IBAction func originalPressed(_ sender: UIButton) {
         delegate?.didSelect(option: .original)
    }
    @IBAction func brightnessPressed(_ sender: UIButton) {
        if let _  = brightnessTextField.text, let b = Int(brightnessTextField.text!) {
            delegate?.didSelect(option: .brightness, brightB: b)
        }
    }
    @IBAction func contrastPressed(_ sender: UIButton) {
        if let _  = contrastTextField.text, let c = Double(contrastTextField.text!) {
            delegate?.didSelect(option: .contrast, contrastMultiplier: c)
        }
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
        
        var kernel: [Double] = []
        for view in kernelTextStackView.arrangedSubviews {
            let subStackView = view as! UIStackView
            for textFieldView in subStackView.arrangedSubviews {
                let textField = textFieldView as! UITextField
                if textField.text != nil {
                    if let double = Double(textField.text!) {
                         kernel.append(double)
                    } else {
                        makeStackRed()
                    }
                } else {
                    makeStackRed()
                }
            }
        }
        if kernel == gaussianKernel || kernel == passaAltaKernel {
            delegate?.didSelect(option: .convolve, kernel: kernel, sum127: false)
        } else {
            delegate?.didSelect(option: .convolve, kernel: kernel, sum127: true)
        }
       
    }
    @IBAction func zoomOutPressed(_ sender: UIButton) {
         if let _ = syTextField.text, let _ = sxTextField.text, let intSx = Int( sxTextField.text!), let intSy = Int( syTextField.text!) {
            delegate?.didSelect(option: .zoomOut, sx: intSx, sy: intSy)
            
        }
    }
    @IBAction func negativePressed(_ sender: UIButton) {
        delegate?.didSelect(option: .negative)
    }
    @IBAction func flipVerticalPressed(_ sender: UIButton) {
        delegate?.didSelect(option: .flipVertical)
    }
    @IBAction func flipHorizontalPressed(_ sender: UIButton) {
        delegate?.didSelect(option: .flipHorizontal)
    }
    @IBAction func savePressed(_ sender: UIButton) {
        delegate?.didSelect(option: .save)
    }
    @IBAction func grayScalePressed(_ sender: UIButton) {
        delegate?.didSelect(option: .grayScale)
    }
    @IBAction func copyPressed(_ sender: UIButton) {
        delegate?.didSelect(option: .copy)
    }
    @IBAction func quantizationPressed(_ sender: UIButton) {
        if let _ = shadesNumberTextField.text, let intQuant = Int( shadesNumberTextField.text!) {
             delegate?.didSelect(option: .quantization, quantization: intQuant )
        }
    }
    @IBAction func sobelHyPressed(_ sender: UIButton) {
        fillStackView(with: [-1, -2, -1, 0, 0, 0, 1, 2, 1])
    }
    @IBAction func sobelHxPressed(_ sender: UIButton) {
        fillStackView(with: [-1, 0, 1, -2, 0, 2, -1, 0, 1 ])
    }
    @IBAction func prewittHxHyPressed(_ sender: UIButton) {
        fillStackView(with: [-1, -1, -1, 0, 0, 0, 1, 1, 1])
    }
    @IBAction func prewittHxPressed(_ sender: UIButton) {
        fillStackView(with: [-1, 0, 1, -1, 0, 1, -1, 0, 1 ])
    }
    @IBAction func passaAltaPressed(_ sender: UIButton) {
        fillStackView(with: [-1, -1, -1, -1, 8, -1, -1, -1, -1 ])
    }
    @IBAction func lapacianoPressed(_ sender: UIButton) {
        fillStackView(with: [0, -1, 0, -1, 4, -1, 0, -1, 0])
    }
    @IBAction func gaussianoPressed(_ sender: UIButton) {
        fillStackView(with: [0.0625, 0.125, 0.0625, 0.125, 0.25, 0.125, 0.0625, 0.125, 0.0625 ])
    }
    
}
extension ControlViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
