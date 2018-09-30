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
        self.smallImageView.image = UIImage(named: "dog")
    }
    
    func rotate(image: UIImage, rotateDirection: RotateDirection) -> UIImage? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        let width = Int(cgImage.width)
        let height = Int(cgImage.height)
        
        let newWidth = height
        let newHeight = width
        
        let rotatedRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height )
        let originalRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        
        let imageContext = CGContext(data: originalRawData,
                                     width: width, height: height,
                                     bitsPerComponent: cgImage.bitsPerComponent,
                                     bytesPerRow: Int(4 * cgImage.width),
                                     space: cgImage.colorSpace!,
                                     bitmapInfo: cgImage.bitmapInfo.rawValue)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        imageContext?.draw(cgImage, in: rect)
        
        let originalPixels = UnsafeMutableBufferPointer<UInt32>(start: originalRawData, count: width * height)
        let rotatedPixels = UnsafeMutableBufferPointer<UInt32>(start: rotatedRawData, count: width * height)
        
        for (i, pixel) in originalPixels.enumerated() {
            let pixel_colunm = i % width
            let pixel_line = Int(i / width)
            
            var dest_line: Int
            var dest_colunm: Int
            
            switch rotateDirection {
            case .left:
                dest_colunm = pixel_line
                dest_line = (newHeight - 1) - pixel_colunm
            case .right:
                dest_line = pixel_colunm
                dest_colunm = (newWidth - 1) - pixel_line
            }
            
            rotatedPixels[newWidth * dest_line + dest_colunm] = pixel
        }
        let outputContext = CGContext(data: rotatedPixels.baseAddress,
                                      width: newWidth, height: newHeight,
                                      bitsPerComponent: cgImage.bitsPerComponent,
                                      bytesPerRow: Int(4 * newWidth),
                                      space: cgImage.colorSpace!,
                                      bitmapInfo: cgImage.bitmapInfo.rawValue)
        
        let outImage = UIImage(cgImage: outputContext!.makeImage()!)
        self.smallImageView.frame = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        self.smallImageView.image = outImage
        return outImage
    }
    
    func average(pixels: [UInt32]) -> UInt32 {
        
        var sumByte0 = 0
        var sumByte1 = 0
        var sumByte2 = 0
        let pixelsCount = pixels.count
        
        for pixel in pixels {
            sumByte0 += Int(UInt8(pixel & 0x000000FF))
            sumByte1 += Int(UInt8((pixel & 0x0000FF00) >> 8))
            sumByte2 += Int(UInt8((pixel & 0x00FF0000) >> 16))
        }
        
        let byte0 = UInt8(sumByte0 / pixelsCount)
        let byte1 = UInt8(sumByte1 / pixelsCount)
        let byte2 = UInt8(sumByte2 / pixelsCount)
        
        let int32 = UInt32(255) << 24 | UInt32(byte2) << 16 | UInt32(byte1) << 8 | UInt32(byte0)
        
        return int32
    }
    
    
    
    

   
    
    func rotate(kernel: [Double]) -> [Double] {
        
        var out = kernel
        let kernelCount = kernel.count
        
        for i in 0..<kernelCount {
            out[kernelCount - 1 - i] = kernel[i]
        }
        return out
    }
    
    func convolve(pixels: [UInt32], kernel: [Double]) -> UInt32 {
        var outDouble = 0.0
        var out = 0
        for i in 0..<pixels.count {
            let byte0 = UInt8(pixels[i] & 0x000000FF)
            outDouble += Double(byte0) * kernel[i]
        }
        out = Int(outDouble)
        if out > 255 {
            out = 255
        }
        if out < 0 {
            out = 0
        }
        let int32 = UInt32(255) << 24 | UInt32(out) << 16 | UInt32(out) << 8 | UInt32(out)
        return int32
    }
    
    func convolve(image: UIImage, kernel: [Double]) -> UIImage? {
        
        let newKernel = rotate(kernel: kernel)
        
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        let width = Int(cgImage.width)
        let height = Int(cgImage.height)
        let dim = width * height
        
        let convolvedRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim )
        let originalRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        
        let imageContext = CGContext(data: originalRawData,
                                     width: width, height: height,
                                     bitsPerComponent: cgImage.bitsPerComponent,
                                     bytesPerRow: Int(4 * cgImage.width),
                                     space: cgImage.colorSpace!,
                                     bitmapInfo: cgImage.bitmapInfo.rawValue)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        imageContext?.draw(cgImage, in: rect)
        
        let originalPixels = UnsafeMutableBufferPointer<UInt32>(start: originalRawData, count: dim)
        let convolvedPixels = UnsafeMutableBufferPointer<UInt32>(start: convolvedRawData, count: dim)
        
        for (i, pixel) in convolvedPixels.enumerated() {
            let colunm = i % width
            let line = Int(i / width)
            
            
            if line != 0 && colunm != 0 && line != (height - 1) && colunm != (width - 1) {
                let boundingPixels = [originalPixels[i - width - 1],
                                      originalPixels[i - width],
                                      originalPixels[i - width + 1],
                                      originalPixels[i],
                                      originalPixels[i + width - 1],
                                      originalPixels[i + width],
                                      originalPixels[i + width + 1]]
                convolvedPixels[i] = convolve(pixels: boundingPixels, kernel: newKernel)
            } else {
                convolvedPixels[i] = pixel
            }
        }
        
        let outputContext = CGContext(data: convolvedPixels.baseAddress,
                                      width: width, height: height,
                                      bitsPerComponent: cgImage.bitsPerComponent,
                                      bytesPerRow: Int(4 * width),
                                      space: cgImage.colorSpace!,
                                      bitmapInfo: cgImage.bitmapInfo.rawValue)
        
        let outImage = UIImage(cgImage: outputContext!.makeImage()!)
        self.smallImageView.image = outImage
        return outImage

    }
    
    
    @IBAction func zoomOutPressed(_ sender: UIButton) {
        let cgimage = PhotoManager.shared.zoomOut(image: (smallImageView.image!.cgImage)!, sx: 2, sy: 2)
        if let image = cgimage {
            self.zoomedImageView.image = UIImage(cgImage: image)
        }
    }
    
    
    @IBAction func convolvePressed(_ sender: UIButton) {
        let kernel = [0.0625, 0.125, 0.0625, 0.125, 0.25, 0.125, 0.0625, 0.125, 0.0625]
        _ = convolve(image: smallImageView.image!, kernel: kernel)
    }
    
    @IBAction func zoom(_ sender: UIButton) {
//        _ = zoomIn(image: self.smallImageView.image!)
    }
   
    @IBAction func rotateLeftPressed(_ sender: UIButton) {
        _ = rotate(image: self.smallImageView.image!, rotateDirection: .left)
    }
   
    @IBAction func rotateRightPressed(_ sender: UIButton) {
        _ = rotate(image: self.smallImageView.image!, rotateDirection: .right)
    }
}
