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
    
    
    var height: Int!
    var width: Int!
    var pixels: UnsafeMutableBufferPointer<UInt32>!
    let bitsPerComponent = Int(8) //8 bits pra cada cor
    var bytesPerRow: Int!
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    var bitmapInfo: UInt32!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "gigio.png")
        height = Int((image?.size.height)!)
        width = Int((image?.size.width)!)
        bytesPerRow = 4 * width // 4 para RGBA
   
        //cada pixel 32 bits. alocamos array de width * height pixels
        let rawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        
        bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        let CGPointZero = CGPoint(x: 0, y: 0)
        let rect = CGRect(origin: CGPointZero, size: (image?.size)!)

        let imageContext = CGContext(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        
        imageContext?.draw(image!.cgImage!, in: rect)
        
        pixels = UnsafeMutableBufferPointer<UInt32>(start: rawData, count: width * height)
        
        let outContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent,bytesPerRow: bytesPerRow,space: colorSpace,bitmapInfo: bitmapInfo,releaseCallback: nil,releaseInfo: nil)
        
        
        let outImage = UIImage(cgImage: outContext!.makeImage()!)
        self.imageVIew.image = outImage
  
    }
    @IBAction func buttonPressed(_ sender: UIButton) {
        let rawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        let pixelsCopy = UnsafeMutableBufferPointer<UInt32>(start: rawData, count: width * height)
        for (i, _) in pixels.enumerated() {
            let line = i / width
            let colunm = i % width
            let sourceColunmIndex = width - 1 - colunm
            let sourceLineIndex = height - 1 - line
            let index = width * sourceLineIndex + sourceColunmIndex
            pixelsCopy[i] = self.pixels[index]
        }
        let outContext = CGContext(data: pixelsCopy.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace,bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
        
        
        let outImage = UIImage(cgImage: outContext!.makeImage()!)
        self.outImageView.image = outImage
        

    }
}





