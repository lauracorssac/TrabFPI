//
//  ViewController.swift
//  TrabFPI
//
//  Created by Laura Corssac on 07/09/2018.
//  Copyright © 2018 Laura Corssac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageVIew: UIImageView!
    @IBOutlet weak var outImageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    var height: Int!
    var width: Int!
    var pixels: UnsafeMutableBufferPointer<UInt32>!
    let bitsPerComponent = Int(8) //8 bits pra cada cor
    var bytesPerRow: Int!
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    var bitmapInfo: UInt32!
    var rawData: UnsafeMutablePointer<UInt32>!
    
    func save(data: Data?, name: String) {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let imageData = data else {
            print("no image data")
            return
        }
        do {
            try imageData.write(to: urls.first!.appendingPathComponent(name))
            print("imagem salva com sucesso")
        } catch let error {
            print("unable to save", error.localizedDescription)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let outImage = copyImage()
        let data = UIImageJPEGRepresentation(outImage, 1)
        save(data: data, name: "copy.jpeg")
    }
    func configureUI() {
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 3
        textField.layer.borderColor = UIColor.black.cgColor
        textField.delegate = self
        imageVIew.contentMode = .center
        outImageView.contentMode = .center
    }
    func loadInitialImage() {
        let image = UIImage(named: "Gramado_72k")
        height = Int((image?.size.height)!)
        width = Int((image?.size.width)!)
        bytesPerRow = 4 * width // 4 para RGBA
        
        //cada pixel 32 bits. alocamos array de width * height pixels
        rawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        
        bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        let CGPointZero = CGPoint(x: 0, y: 0)
        let rect = CGRect(origin: CGPointZero, size: (image?.size)!)
        
        let imageContext = CGContext(data: rawData,
                                     width: width, height: height,
                                     bitsPerComponent: bitsPerComponent,
                                     bytesPerRow: bytesPerRow,
                                     space: colorSpace,
                                     bitmapInfo: bitmapInfo)
        
        imageContext?.draw(image!.cgImage!, in: rect)
        
        pixels = UnsafeMutableBufferPointer<UInt32>(start: rawData, count: width * height)
        
        let outContext = CGContext(data: pixels.baseAddress,
                                   width: width, height: height,
                                   bitsPerComponent: bitsPerComponent,
                                   bytesPerRow: bytesPerRow,
                                   space: colorSpace,
                                   bitmapInfo:bitmapInfo,releaseCallback: nil,
                                   releaseInfo: nil)
        
        let outImage = UIImage(cgImage: outContext!.makeImage()!)
        self.imageVIew.image = outImage
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadInitialImage()
    }
    @IBAction func flipVerticalButtonPressed(_ sender: UIButton) {
        let rawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        let pixelsCopy = UnsafeMutableBufferPointer<UInt32>(start: rawData, count: width * height)
        for (i, _) in pixelsCopy.enumerated() {
            let line = i / width
            let colunm = i % width
            let sourceColunmIndex = width - 1 - colunm
            let sourceLineIndex = height - 1 - line
            let index = width * sourceLineIndex + sourceColunmIndex
            pixelsCopy[i] = self.pixels[index]
        }
        let outContext = CGContext(data: pixelsCopy.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace,bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
        
        pixels = pixelsCopy
        let outImage = UIImage(cgImage: outContext!.makeImage()!)
        self.outImageView.image = outImage
        let data = UIImageJPEGRepresentation(outImage, 1.0)
        save(data: data, name: "copy_vertical.jpeg")
        //free(self.rawData)
        //self.rawData = rawData
    }
    
    @IBAction func flipHorizontalButtonPressed(_ sender: UIButton) {
        
        let rawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        let pixelsCopy = UnsafeMutableBufferPointer<UInt32>(start: rawData, count: width * height)
        for (i, _) in pixelsCopy.enumerated() {
            let line = i / width
            let colunm = i % width
            let sourceColunmIndex = width - 1 - colunm
            let sourceLineIndex = line
            let index = width * sourceLineIndex + sourceColunmIndex
            pixelsCopy[i] = self.pixels[index]
        }
        let outContext = CGContext(data: pixelsCopy.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace,bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
        
        pixels = pixelsCopy
        let outImage = UIImage(cgImage: outContext!.makeImage()!)
        let data = UIImageJPEGRepresentation(outImage, 1.0)
        save(data: data, name: "copy_horizontal.jpeg")
        self.outImageView.image = outImage
        //free(self.rawData)
        //self.rawData = rawData
        
    }
    
    func copyImage() -> UIImage {
        let rawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        let pixelsCopy = UnsafeMutableBufferPointer<UInt32>(start: rawData, count: width * height)
        for (i, _) in pixelsCopy.enumerated() {
            pixelsCopy[i] = pixels[i]
        }
        let outContext = CGContext(data: pixelsCopy.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace,bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
        
        let outImage = UIImage(cgImage: outContext!.makeImage()!)
        pixels = pixelsCopy
        //free(self.rawData)
        return outImage
    }
    
    
    
    @IBAction func copyButtonPressed(_ sender: Any) {
        
        self.view.endEditing(true)
        self.outImageView.image = copyImage()
    }
    @IBAction func grayScaleButtonPressed(_ sender: UIButton) {
        
        let rawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        let pixelsCopy = UnsafeMutableBufferPointer<UInt32>(start: rawData, count: width * height)
        for (i, _) in pixelsCopy.enumerated() {
            
            let pixel = pixels[i]
        
            let byte0 = UInt8(pixel & 0x000000FF)
            let byte1 = UInt8((pixel & 0x0000FF00) >> 8)
            let byte2 = UInt8((pixel & 0x00FF0000) >> 16)
            let byte3 = UInt8((pixel & 0xFF000000) >> 24) //alpha
            let red = Double(byte0)
            let green = Double(byte1)
            let blue = Double(byte2)
            
            let L = 0.299*red + 0.587*green + 0.114*blue
            let int8 = UInt8.init(L)
            let int32 = UInt32(byte3) << 24 | UInt32(int8) << 16 | UInt32(int8) << 8 | UInt32(int8)
            
            pixelsCopy[i] = int32
        }
        let outContext = CGContext(data: pixelsCopy.baseAddress,
                                   width: width, height: height,
                                   bitsPerComponent: bitsPerComponent,
                                   bytesPerRow: bytesPerRow,
                                   space: colorSpace,
                                   bitmapInfo: bitmapInfo,
                                   releaseCallback: nil,
                                   releaseInfo: nil)
        
        pixels = pixelsCopy
        let outImage = UIImage(cgImage: outContext!.makeImage()!)
        self.outImageView.image = outImage
        
        let data = UIImageJPEGRepresentation(outImage, 1.0)
        save(data: data, name: "copy_gray.jpeg")
        //free(self.rawData)
        //self.rawData = rawData
        
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let _ = textField.text, let number = Int(textField.text!) else {
            return false
        }
        if number > 2 && number <= 256 {
            textField.layer.borderColor = UIColor.black.cgColor
            textField.resignFirstResponder()
            return true
        } else {
            textField.layer.borderColor = UIColor.red.cgColor
            return false
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        guard let shadesNumber = Int(textField.text!) else {
            return
        }
        let rawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        let pixelsCopy = UnsafeMutableBufferPointer<UInt32>(start: rawData, count: width * height)
        for (i, _) in pixelsCopy.enumerated() {
            
            let pixel = pixels[i]
            let byte0 = UInt8(pixel & 0x000000FF)
            let byte3 = UInt8((pixel & 0xFF000000) >> 24) // alpha
            let shade = Int(byte0)
            var newShade: Int
            
            if shadesNumber <= 1 {
                newShade = 255
            } else {
                let intervals = shadesNumber - 1
                let intervalSize = 255 / intervals
                var nearestShade = intervalSize
                let lastBound = 255 - intervalSize
                while nearestShade < shade && nearestShade <= lastBound {
                    nearestShade += intervalSize
                }
                let highDif = abs(nearestShade - shade)
                let lowDif = abs(nearestShade - intervalSize - shade)
                
                if highDif < lowDif {
                    newShade = nearestShade
                } else {
                    newShade = nearestShade - intervalSize
                }
              
            }
            let int8 = UInt8.init(newShade)
            let int32 = UInt32(byte3) << 24 | UInt32(int8) << 16 | UInt32(int8) << 8 | UInt32(int8)
            
            pixelsCopy[i] = int32
        }
        let outContext = CGContext(data: pixelsCopy.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace,bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
        
        let outImage = UIImage(cgImage: outContext!.makeImage()!)
        let data = UIImageJPEGRepresentation(outImage, 1.0)
        save(data: data, name: "copy_gray_\(shadesNumber).jpeg")
        self.outImageView.image = outImage
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}



