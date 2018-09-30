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
                zoomedPixels[index] = int32
                
            } else {
                
                
                let int32 = [zoomedPixels[index + newWidth], zoomedPixels[index - newWidth]].average()
                zoomedPixels[index] = int32
                
                if colunm != newWidth - 1 {
                    
                    let int32 = [zoomedPixels[(index + 1) + newWidth + 1],
                                 zoomedPixels[(index + 1) + newWidth - 1],
                                 zoomedPixels[(index + 1) - newWidth + 1],
                                 zoomedPixels[(index + 1) - newWidth - 1]].average()
                    
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
        originalRawData.deallocate()
        return context.makeImage()

    }
    func rotate(image: CGImage, rotateDirection: RotateDirection) -> CGImage? {
       
        let width = image.width
        let height = image.height
        
        let newWidth = height
        let newHeight = width
        
        let rotatedRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height )
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
                                      bitsPerComponent: image.bitsPerComponent,
                                      bytesPerRow: Int(4 * newWidth),
                                      space: image.colorSpace!,
                                      bitmapInfo: image.bitmapInfo.rawValue)
        
        guard let context = outputContext else {
            return nil
            
        }
        originalRawData.deallocate()
        
        return context.makeImage()
        
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
    
    func convolve(image: CGImage, kernel: [Double]) -> CGImage? {
        
        let newKernel = rotate(kernel: kernel)
        
        let width = image.width
        let height = image.height
        let dim = width * height
        
        let convolvedRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim )
        let originalRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        
        let imageContext = CGContext(data: originalRawData,
                                     width: width, height: height,
                                     bitsPerComponent: image.bitsPerComponent,
                                     bytesPerRow: Int(4 * image.width),
                                     space: image.colorSpace!,
                                     bitmapInfo: image.bitmapInfo.rawValue)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        imageContext?.draw(image, in: rect)
        
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
                                      bitsPerComponent: image.bitsPerComponent,
                                      bytesPerRow: Int(4 * width),
                                      space: image.colorSpace!,
                                      bitmapInfo: image.bitmapInfo.rawValue)
        
        guard let context = outputContext else {
            return nil
        }
        originalPixels.deallocate()
        return context.makeImage()
        
    }
    
}
