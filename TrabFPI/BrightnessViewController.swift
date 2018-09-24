//
//  BrightnessViewController.swift
//  TrabFPI
//
//  Created by Laura Corssac on 23/09/2018.
//  Copyright © 2018 Laura Corssac. All rights reserved.
//

import UIKit

class BrightnessViewController: UIViewController {
    
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var bottomImageView: UIImageView!
    
    var height: Int!
    var width: Int!
    var pixels: UnsafeMutableBufferPointer<UInt32>!
    let bitsPerComponent = Int(8)
    var bytesPerRow: Int!
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    var bitmapInfo: UInt32!
    var rawData: UnsafeMutablePointer<UInt32>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInitialImage()
    }
    func loadInitialImage() {
        let image = UIImage(named: "Gramado_72k")
        height = Int((image?.size.height)!)
        width = Int((image?.size.width)!)
        bytesPerRow = 4 * width // 4 para RGBA
        
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
                                   bitmapInfo: bitmapInfo, releaseCallback: nil,
                                   releaseInfo: nil)
        
        let outImage = UIImage(cgImage: outContext!.makeImage()!)
        self.topImageView.image = outImage
    }

    @IBAction func brightButtonPressed(_ sender: UIButton) {
        let b = -50
        let rawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        let pixelsCopy = UnsafeMutableBufferPointer<UInt32>(start: rawData, count: width * height)
        for (i, _) in pixelsCopy.enumerated() {
           
            let pixel = pixels[i]
            
            let byte0 = UInt8(pixel & 0x000000FF)
            let byte1 = UInt8((pixel & 0x0000FF00) >> 8)
            let byte2 = UInt8((pixel & 0x00FF0000) >> 16)
            let byte3 = UInt8((pixel & 0xFF000000) >> 24) //alpha
            let red = Int(byte0) + b
            let green = Int(byte1) + b
            let blue = Int(byte2) + b
            
            let colors = [red, green, blue].map { color -> UInt8 in
                if color < 0 {
                    return UInt8(0)
                }
                if color > 255 {
                    return UInt8(255)
                }
                return UInt8(color)
            }
            
            let int32 = UInt32(byte3) << 24 | UInt32(colors[2]) << 16 | UInt32(colors[1]) << 8 | UInt32(colors[0])
            pixelsCopy[i] = int32
        }
        let outContext = CGContext(data: pixelsCopy.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace,bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
        
        let outImage = UIImage(cgImage: outContext!.makeImage()!)
        self.bottomImageView.image = outImage
        
    }
    

}
