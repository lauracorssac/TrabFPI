import Foundation
import UIKit

class PhotoManager {
    
    static let shared = PhotoManager()
    private init() { }
    
    func zoomOut(image: CGImage, sx: Int, sy: Int) -> CGImage? {
        
        let width = Int(image.width)
        let height = Int(image.height)
        
        let dimX = Int( ceil(Double(width) / Double(sx) ))
        let dimY = Int( ceil(Double(height) / Double(sy)))
        let dim = dimX * dimY
        
        let originalRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        let zoomedRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim )
        
        let imageContext = CGContext(data: originalRawData,
                                     width: width, height: height,
                                     bitsPerComponent: image.bitsPerComponent,
                                     bytesPerRow: Int(4 * image.width),
                                     space: image.colorSpace!,
                                     bitmapInfo: image.bitmapInfo.rawValue)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        imageContext?.draw(image, in: rect)
        
        let originalPixels = UnsafeMutableBufferPointer<UInt32>(start: originalRawData, count: width * height)
        let zoomedPixels = UnsafeMutableBufferPointer<UInt32>(start: zoomedRawData, count: dim)
        
        for l in 0..<dimY {
            
            let initial = l * width * sy
            
            let line = Int(initial / width)
            
            let newRy = (line + sy <= height) ? sy : (height - line)
            
            for c in 0..<dimX {
                
                let upperLeftIndex = initial + c * sx
                let colunm = upperLeftIndex % width
                let newRx = (colunm + sx <= width) ? sx : (width - colunm)
                
                var pixelsToSum: [UInt32] = []
                for i in 0..<newRy {
                    let start = upperLeftIndex + width * i
                    let end = start + newRx - 1
                    pixelsToSum.append(contentsOf: originalPixels[start...end])
                    
                }
                
                zoomedPixels[dimX * l + c] = pixelsToSum.average()
            }
            
        }
        
        let outputContext = CGContext(data: zoomedPixels.baseAddress,
                                      width: dimX, height: dimY,
                                      bitsPerComponent: image.bitsPerComponent,
                                      bytesPerRow: Int(4 * dimX),
                                      space: image.colorSpace!,
                                      bitmapInfo: image.bitmapInfo.rawValue)
        
        guard let context = outputContext else {
            return nil
        }
        return context.makeImage()
        
    }
    
    func zoomIn(image: CGImage) -> CGImage? {
        
        let width = Int(image.width)
        let height = Int(image.height)
        
        let newWidth = (width + width - 1)
        let newHeight = (height + height - 1)
        
        let zoomedPixelsCount = newWidth * newHeight
        
        let zoomedRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: zoomedPixelsCount )
        let originalRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        
        let imageContext = CGContext(data: originalRawData,
                                     width: width, height: height,
                                     bitsPerComponent: image.bitsPerComponent,
                                     bytesPerRow: Int(4 * image.width),
                                     space: image.colorSpace!,
                                     bitmapInfo: image.bitmapInfo.rawValue)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        imageContext?.draw(image, in: rect)
        
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
                
                let int32 = [zoomedPixels[index - 1], zoomedPixels[index + 1]].average()
                
//                let byte0 = UInt8( (Int(UInt8(zoomedPixels[index - 1] & 0x000000FF)) + Int(UInt8(zoomedPixels[index + 1] & 0x000000FF))) / 2)
//                let byte1 = UInt8( (Int( UInt8( (zoomedPixels[index - 1] & 0x0000FF00) >> 8) ) + Int( UInt8( (zoomedPixels[index + 1] & 0x0000FF00) >> 8) )) / 2 )
//                let byte2 = UInt8((Int(UInt8((zoomedPixels[index - 1] & 0x00FF0000) >> 16)) + Int(UInt8((zoomedPixels[index + 1] & 0x00FF0000) >> 16))) / 2)
//                let byte3 = UInt8((zoomedPixels[index - 1] & 0xFF000000) >> 24) //alpha
                
                //let int32 = UInt32(byte3) << 24 | UInt32(byte2) << 16 | UInt32(byte1) << 8 | UInt32(byte0)
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
                                      bitsPerComponent: image.bitsPerComponent,
                                      bytesPerRow: Int(4 * newWidth),
                                      space: image.colorSpace!,
                                      bitmapInfo: image.bitmapInfo.rawValue)
        
        guard let context = outputContext else {
            return nil
        }
        
        return context.makeImage()

    }
    
}
