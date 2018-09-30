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
        self.smallImageView.image = UIImage(named: "small")
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
    
    

    func zoomIn(image: UIImage) -> UIImage? {
        
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        let width = Int(cgImage.width)
        let height = Int(cgImage.height)
        
        let newWidth = (width + width - 1)
        let newHeight = (height + height - 1)
        
        let zoomedPixelsCount = newWidth * newHeight
        
        let zoomedRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: zoomedPixelsCount )
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
        let zoomedPixels = UnsafeMutableBufferPointer<UInt32>(start: zoomedRawData, count: zoomedPixelsCount)
        
        for (i, _) in zoomedPixels.enumerated() { zoomedPixels[i] = 0 }
        
        for (i, pixel) in originalPixels.enumerated() {
            let pixel_colunm = i % width
            let pixel_line = Int(i / width)
            let dest_line = 2 * pixel_line
            let dest_colunm = 2 * pixel_colunm
            zoomedPixels[newWidth * dest_line + dest_colunm] = pixel
        }
        for index in stride(from: 1, to: zoomedPixelsCount, by: 2) {
            let line = Int(index / newWidth)
            let colunm = index % newWidth
            if line % 2 == 0 {
            
                let byte0 = UInt8( (Int(UInt8(zoomedPixels[index - 1] & 0x000000FF)) + Int(UInt8(zoomedPixels[index + 1] & 0x000000FF))) / 2)
                let byte1 = UInt8( (Int( UInt8( (zoomedPixels[index - 1] & 0x0000FF00) >> 8) ) + Int( UInt8( (zoomedPixels[index + 1] & 0x0000FF00) >> 8) )) / 2 )
                let byte2 = UInt8((Int(UInt8((zoomedPixels[index - 1] & 0x00FF0000) >> 16)) + Int(UInt8((zoomedPixels[index + 1] & 0x00FF0000) >> 16))) / 2)
                let byte3 = UInt8((zoomedPixels[index - 1] & 0xFF000000) >> 24) //alpha
                
                let int32 = UInt32(byte3) << 24 | UInt32(byte2) << 16 | UInt32(byte1) << 8 | UInt32(byte0)
                zoomedPixels[index] = int32
                
            } else {
                
                let byte0 = UInt8( (Int(UInt8(zoomedPixels[index - newWidth] & 0x000000FF)) + Int(UInt8(zoomedPixels[index + newWidth] & 0x000000FF))) / 2)
                let byte1 = UInt8( (Int( UInt8( (zoomedPixels[index - newWidth] & 0x0000FF00) >> 8) ) + Int( UInt8( (zoomedPixels[index + newWidth] & 0x0000FF00) >> 8) )) / 2 )
                let byte2 = UInt8((Int(UInt8((zoomedPixels[index - newWidth] & 0x00FF0000) >> 16)) + Int(UInt8((zoomedPixels[index + newWidth] & 0x00FF0000) >> 16))) / 2)
                let byte3 = UInt8((zoomedPixels[index - newWidth] & 0xFF000000) >> 24) //alpha
                
                let int32 = UInt32(byte3) << 24 | UInt32(byte2) << 16 | UInt32(byte1) << 8 | UInt32(byte0)
                zoomedPixels[index] = int32
                
                if colunm != newWidth - 1 {
                    
                    
                    let byte0 = UInt8(
                        (Int(UInt8(zoomedPixels[(index + 1) + newWidth + 1] & 0x000000FF)) +
                        Int(UInt8(zoomedPixels[(index + 1) + newWidth - 1] & 0x000000FF)) +
                        Int(UInt8(zoomedPixels[(index + 1) - newWidth + 1] & 0x000000FF)) +
                        Int(UInt8(zoomedPixels[(index + 1) - newWidth - 1] & 0x000000FF))) / 4)
                    
                    let byte1 = UInt8(
                        (Int(UInt8((zoomedPixels[(index + 1) + newWidth + 1] & 0x0000FF00) >> 8)) +
                            Int(UInt8((zoomedPixels[(index + 1) + newWidth - 1] & 0x0000FF00) >> 8)) +
                            Int(UInt8((zoomedPixels[(index + 1) - newWidth + 1] & 0x0000FF00) >> 8)) +
                            Int(UInt8((zoomedPixels[(index + 1) - newWidth - 1] & 0x0000FF00) >> 8))) / 4)
                    
                    let byte2 = UInt8(
                        (Int(UInt8((zoomedPixels[(index + 1) + newWidth + 1] & 0x00FF0000) >> 16)) +
                            Int(UInt8((zoomedPixels[(index + 1) + newWidth - 1] & 0x00FF0000) >> 16)) +
                            Int(UInt8((zoomedPixels[(index + 1) - newWidth + 1] & 0x00FF0000) >> 16)) +
                            Int(UInt8((zoomedPixels[(index + 1) - newWidth - 1] & 0x00FF0000) >> 16))) / 4)
                    
                    
                    let byte3 = UInt8((zoomedPixels[index - newWidth] & 0xFF000000) >> 24) //alpha
                    let int32 = UInt32(byte3) << 24 | UInt32(byte2) << 16 | UInt32(byte1) << 8 | UInt32(byte0)
                    
                    zoomedPixels[index + 1] = UInt32(int32)
                }
            }
        }
        
        let outputContext = CGContext(data: zoomedPixels.baseAddress,
                                      width: newWidth, height: newHeight,
                                      bitsPerComponent: cgImage.bitsPerComponent,
                                      bytesPerRow: Int(4 * newWidth),
                                      space: cgImage.colorSpace!,
                                      bitmapInfo: cgImage.bitmapInfo.rawValue)
        
        let outImage = UIImage(cgImage: outputContext!.makeImage()!)
        self.zoomedImageView.image = outImage
        return outImage
        
    }
    @IBAction func zoom(_ sender: UIButton) {
        _ = zoomIn(image: self.smallImageView.image!)
    }
   
    @IBAction func rotateLeftPressed(_ sender: UIButton) {
        _ = rotate(image: self.smallImageView.image!, rotateDirection: .left)
    }
   
    @IBAction func rotateRightPressed(_ sender: UIButton) {
        _ = rotate(image: self.smallImageView.image!, rotateDirection: .right)
    }
}
