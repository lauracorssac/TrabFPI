//
//  SecondViewController.swift
//  TrabFPI
//
//  Created by Laura Corssac on 23/09/2018.
//  Copyright © 2018 Laura Corssac. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var histogramImageView: UIImageView!
    @IBOutlet weak var bottomImageView: UIImageView!
    
    var height: Int!
    var width: Int!
    var pixels: UnsafeMutableBufferPointer<UInt32>!
    //var grayPixels: UnsafeMutableBufferPointer<UInt8>!
    let bitsPerComponent = Int(8)
    var bytesPerRow: Int!
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    //let colorSpaceGray = CGColorSpaceCreateDeviceGray()
    var bitmapInfo: UInt32!
    //var grayBitMapInfor: UInt32!
    var rawData: UnsafeMutablePointer<UInt32>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInitialImage()
    }
    func makeHistogram() {
        var shadesCount = [Int](repeating: 0, count: 256)
        for pixel in pixels {
            let byte0 = UInt8(pixel & 0x000000FF)
            let shade = Int(byte0)
            shadesCount[shade] += 1
        }
        let maxValue = shadesCount.max()!
        let alpha = Double( 256.0 / Double(maxValue))
        shadesCount = shadesCount.map {
            Int(Double($0) * alpha)
        }
        let rawData = UnsafeMutablePointer<UInt32>.allocate(capacity: 256 * 256)
        let pixelsCopy = UnsafeMutableBufferPointer<UInt32>(start: rawData, count: 256 * 256)
        
        for (i, _) in pixelsCopy.enumerated() {
            let line = i / 256
            let colunm = i % 256
            let oppositeLine = 255 - line
            
            if oppositeLine < shadesCount[colunm] {
                //let color =  UInt32(255) << 24 | UInt32(0)
                pixelsCopy[i] = UInt32(255) << 24 | UInt32(0)
            } else {
                pixelsCopy[i] = 0b1111_1111_1111_1111_1111_1111_1111_1111
            }
            
        }
        let outContext = CGContext(data: pixelsCopy.baseAddress,
                                   width: 256, height: 256,
                                   bitsPerComponent: bitsPerComponent,
                                   bytesPerRow: 256 * 4,
                                   space: colorSpace,
                                   bitmapInfo: bitmapInfo,
                                   releaseCallback: nil,
                                   releaseInfo: nil)
        
        //pixels = pixelsCopy
        let outImage = UIImage(cgImage: outContext!.makeImage()!)
        self.histogramImageView.image = outImage
    }
    
    @IBAction func histogramButtonPressed(_ sender: UIButton) {
        makeHistogram()
        
    }
    func loadInitialImage() {
        let image = UIImage(named: "Gramado_72k")
        height = Int((image?.size.height)!)
        width = Int((image?.size.width)!)
        bytesPerRow = 4 * width // 4 para RGBA
        
        //cada pixel 32 bits. alocamos array de width * height pixels
        rawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        
        bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        //grayBitMapInfor = CGImageAlphaInfo.none.rawValue
        
        
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
        self.bottomImageView.image = outImage
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
            let int8 = UInt8(L)
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
        self.bottomImageView.image = outImage
        
    }
    
    
    
    
}
