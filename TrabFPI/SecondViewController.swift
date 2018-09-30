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
    
    func getOriginalHistogram(from image: UIImage) -> [Int] {
        
        let rawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        let imageContext = CGContext(data: rawData,
                                     width: width, height: height,
                                     bitsPerComponent: bitsPerComponent,
                                     bytesPerRow: bytesPerRow,
                                     space: colorSpace,
                                     bitmapInfo: bitmapInfo)
        
        let rect = CGRect(origin: .zero, size: image.size)
        imageContext?.draw(image.cgImage!, in: rect)
        pixels = UnsafeMutableBufferPointer<UInt32>(start: rawData, count: width * height)
        
        var shadesCount = [Int](repeating: 0, count: 256)
        for pixel in pixels {
            let byte0 = UInt8(pixel & 0x000000FF)
            let byte1 = UInt8((pixel & 0x0000FF00) >> 8)
            let byte2 = UInt8((pixel & 0x00FF0000) >> 16)
            //let byte3 = UInt8((pixel & 0xFF000000) >> 24) //alpha
            
            let red = Double(byte0)
            let green = Double(byte1)
            let blue = Double(byte2)
            
            let L = 0.299*red + 0.587*green + 0.114*blue
            let shade = Int(L)
            shadesCount[shade] += 1
        }
        return shadesCount
    }
    
    func makeHistogram() {
       
        var shadesCount =  getOriginalHistogram(from: bottomImageView.image!)
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
        
        self.bottomImageView.image = convertToGrayScale(image: bottomImageView.image!)
        
    }
    
    func getEqualizedHistogram(from histogram: [Int]) -> [Int] {
        
        var cumHistogram = [Double](repeating: 0.0, count: histogram.count)
        
        let alpha = 255.0 / Double(width * height)
        cumHistogram[0] = alpha * Double(histogram[0])
        
        for i in 1..<histogram.count {
            cumHistogram[i] =  cumHistogram[i - 1] + Double(histogram[i]) * alpha
        }
        
        let equalizedHistogram = cumHistogram.map { Int($0) }
        return equalizedHistogram
    }
    
    func equalizeHistogram(from image: UIImage) -> UIImage {
        
        let equalizedHistogram = getEqualizedHistogram(from: getOriginalHistogram(from: image))
        
        let rawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        let pixelsCopy = UnsafeMutableBufferPointer<UInt32>(start: rawData, count: width * height)
        for (i, _) in pixelsCopy.enumerated() {
            
            let pixel = pixels[i]
            
            let byte0 = UInt8(pixel & 0x000000FF)
            let byte1 = UInt8((pixel & 0x0000FF00) >> 8)
            let byte2 = UInt8((pixel & 0x00FF0000) >> 16)
            let byte3 = UInt8((pixel & 0xFF000000) >> 24) //alpha
            
            let newRed = UInt8(equalizedHistogram[Int(byte0)])
            let newGreen = UInt8(equalizedHistogram[Int(byte1)])
            let newBlue = UInt8(equalizedHistogram[Int(byte2)])
            
           
            let int32 = UInt32(byte3) << 24 | UInt32(newBlue) << 16 | UInt32(newGreen) << 8 | UInt32(newRed)
            
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
        return outImage
    }
    
    @IBAction func equalizationButtonPressed(_ sender: UIButton) {
        
        self.histogramImageView.image = equalizeHistogram(from: bottomImageView.image!)
    }
    
    func convertToGrayScale(image: UIImage) -> UIImage {
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
        return UIImage(cgImage: outContext!.makeImage()!)
    }
    
    func histogramMatching(sourceHistogram: [Int], targetHistogram: [Int]) -> [Int] {
        
        var matchingHistogram = [Int](repeating: 0, count: sourceHistogram.count)
        
        for i in 0..<sourceHistogram.count {
            let shade  = sourceHistogram[i]
            var nearestValue = -shade
            for targetShade in targetHistogram {
                if abs(targetShade - shade) < abs(nearestValue - shade) {
                    nearestValue = targetShade
                }
            }
            matchingHistogram[i] = nearestValue
        }
        
        return matchingHistogram
    }
    @IBAction func matchingButtonPressed(_ sender: UIButton) {
        let sourceImage = convertToGrayScale(image: UIImage(named: "Gramado_22k")!)
        let targetImage = convertToGrayScale(image: UIImage(named: "Gramado_22k")!)
        let sourceHistogram = getEqualizedHistogram(from: getOriginalHistogram(from: sourceImage))
        let targetHistogram = getEqualizedHistogram(from: getOriginalHistogram(from: targetImage))
        let matchingHistogram = histogramMatching(sourceHistogram: sourceHistogram, targetHistogram: targetHistogram)
        
        let width = Int(sourceImage.size.width)
        let height = Int(sourceImage.size.height)
        
        let matchingRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        let originalRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        
        let imageContext = CGContext(data: originalRawData,
                                     width: width, height: height,
                                     bitsPerComponent: bitsPerComponent,
                                     bytesPerRow: Int(4 * sourceImage.size.width),
                                     space: colorSpace,
                                     bitmapInfo: bitmapInfo)
        
        let rect = CGRect(origin: .zero, size: sourceImage.size)
        imageContext?.draw(sourceImage.cgImage!, in: rect)
        
        let originalPixels = UnsafeMutableBufferPointer<UInt32>(start: originalRawData, count: width * height)
        let matchingPixels = UnsafeMutableBufferPointer<UInt32>(start: matchingRawData, count: width * height)
        
        for (i,_) in matchingPixels.enumerated() {
            let pixel = originalPixels[i]
            let byte0 = UInt8(pixel & 0x000000FF)
            let shade = Int(byte0)
            let int8 = matchingHistogram[shade]
            let int32 = UInt32(255) << 24 | UInt32(int8) << 16 | UInt32(int8) << 8 | UInt32(int8)
            matchingPixels[i] = int32
        }
        
        let outputContext = CGContext(data: matchingPixels.baseAddress,
                                     width: width, height: height,
                                     bitsPerComponent: bitsPerComponent,
                                     bytesPerRow: Int(4 * sourceImage.size.width),
                                     space: colorSpace,
                                     bitmapInfo: bitmapInfo)
        
        self.bottomImageView.image = UIImage(cgImage: outputContext!.makeImage()!)
        
    }
    
}
