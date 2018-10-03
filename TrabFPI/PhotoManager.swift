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
    
    func convolve(pixels: [UInt32], kernel: [Double], sum: Bool) -> UInt32 {
        var outDouble = 0.0
        var out = 0
        for i in 0..<pixels.count {
            let byte0 = UInt8(pixels[i] & 0x000000FF)
            outDouble += Double(byte0) * kernel[i]
        }
        out = Int(outDouble)
        if sum {
            out = out + 127
        }
        if out > 255 {
            out = 255
        }
        if out < 0 {
            out = 0
        }
        let int32 = UInt32(255) << 24 | UInt32(out) << 16 | UInt32(out) << 8 | UInt32(out)
        return int32
    }
    
    func convolve(image: CGImage, kernel: [Double], sum: Bool) -> CGImage? {
        
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
                convolvedPixels[i] = convolve(pixels: boundingPixels, kernel: newKernel, sum: sum)
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
    func negative(image: CGImage) -> CGImage? {
        
        let width = image.width
        let height = image.height
        let dim = width * height
        
        let outputRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        let originalRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        
        let imageContext = CGContext(data: originalRawData,
                                     width: width, height: height,
                                     bitsPerComponent: image.bitsPerComponent,
                                     bytesPerRow: Int(4 * width),
                                     space: image.colorSpace!,
                                     bitmapInfo: image.bitmapInfo.rawValue)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        imageContext?.draw(image, in: rect)
        
        let pixels =  UnsafeMutableBufferPointer<UInt32>(start: originalRawData, count: dim)
        let outPixels = UnsafeMutableBufferPointer<UInt32>(start: outputRawData, count: dim)
        
        for (i, _) in outPixels.enumerated() {
            
            let pixel = pixels[i]
            
            let byte0 = UInt8(pixel & 0x000000FF)
            let byte1 = UInt8((pixel & 0x0000FF00) >> 8)
            let byte2 = UInt8((pixel & 0x00FF0000) >> 16)
            let byte3 = UInt8((pixel & 0xFF000000) >> 24) //alpha
            
            let constant = UInt8(255)
            let red = constant - byte0
            let green = constant - byte1
            let blue = constant - byte2
            
            let int32 = UInt32(byte3) << 24 | UInt32(blue) << 16 | UInt32(green) << 8 | UInt32(red)
            
            outPixels[i] = int32
        }
        let outContext = CGContext(data: outPixels.baseAddress,
                                   width: width, height: height,
                                   bitsPerComponent: image.bitsPerComponent,
                                   bytesPerRow: image.bytesPerRow,
                                   space: image.colorSpace!,
                                   bitmapInfo: image.bitmapInfo.rawValue)
        
        guard let context = outContext else {
            return nil
        }
        return context.makeImage()
        
    }
    func contrast(image: CGImage, multiplier: Double) -> CGImage? {
        
        let width = image.width
        let height = image.height
        let dim = width * height
        
        let outputRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        let originalRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        
        let imageContext = CGContext(data: originalRawData,
                                     width: width, height: height,
                                     bitsPerComponent: image.bitsPerComponent,
                                     bytesPerRow: Int(4 * width),
                                     space: image.colorSpace!,
                                     bitmapInfo: image.bitmapInfo.rawValue)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        imageContext?.draw(image, in: rect)
        
        let pixels =  UnsafeMutableBufferPointer<UInt32>(start: originalRawData, count: dim)
        let outPixels = UnsafeMutableBufferPointer<UInt32>(start: outputRawData, count: dim)
        
        for (i, _) in outPixels.enumerated() {
            
            let pixel = pixels[i]
            
            let byte0 = UInt8(pixel & 0x000000FF)
            let byte1 = UInt8((pixel & 0x0000FF00) >> 8)
            let byte2 = UInt8((pixel & 0x00FF0000) >> 16)
            let byte3 = UInt8((pixel & 0xFF000000) >> 24) //alpha
            let red = Double(byte0) * multiplier
            let green = Double(byte1) * multiplier
            let blue = Double(byte2) * multiplier
            
            let colors = [red, green, blue].map { color -> UInt8 in
                if color > 255 {
                    return UInt8(255)
                }
                return UInt8(color)
            }
            
            let int32 = UInt32(byte3) << 24 | UInt32(colors[2]) << 16 | UInt32(colors[1]) << 8 | UInt32(colors[0])
            outPixels[i] = int32
        }
        let outContext = CGContext(data: outPixels.baseAddress,
                                   width: width, height: height,
                                   bitsPerComponent: image.bitsPerComponent,
                                   bytesPerRow: image.bytesPerRow,
                                   space: image.colorSpace!,
                                   bitmapInfo: image.bitmapInfo.rawValue)
        
        guard let context = outContext else {
            return nil
        }
        return context.makeImage()
    }
    func brightness(image: CGImage, b: Int) -> CGImage? {
        
        let width = image.width
        let height = image.height
        let dim = width * height
        
        let outputRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        let originalRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        
        let imageContext = CGContext(data: originalRawData,
                                     width: width, height: height,
                                     bitsPerComponent: image.bitsPerComponent,
                                     bytesPerRow: Int(4 * width),
                                     space: image.colorSpace!,
                                     bitmapInfo: image.bitmapInfo.rawValue)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        imageContext?.draw(image, in: rect)
        
        let pixels =  UnsafeMutableBufferPointer<UInt32>(start: originalRawData, count: dim)
        let outPixels = UnsafeMutableBufferPointer<UInt32>(start: outputRawData, count: dim)
        
        for (i, _) in outPixels.enumerated() {
            
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
            outPixels[i] = int32
        }
        let outContext = CGContext(data: outPixels.baseAddress,
                                   width: width, height: height,
                                   bitsPerComponent: image.bitsPerComponent,
                                   bytesPerRow: image.bytesPerRow,
                                   space: image.colorSpace!,
                                   bitmapInfo: image.bitmapInfo.rawValue)
        
        guard let context = outContext else {
            return nil
        }
        return context.makeImage()
       
    }
    // MARK: - Histogram
    
    func histogram(from image: CGImage) -> CGImage? {
        
        let width = image.width
        let height = image.height
        let dim = width * height
        
        let rawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        let imageContext = CGContext(data: rawData,
                                     width: width, height: height,
                                     bitsPerComponent: image.bitsPerComponent,
                                     bytesPerRow: image.bytesPerRow,
                                     space: image.colorSpace!,
                                     bitmapInfo: image.bitmapInfo.rawValue)

        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        imageContext?.draw(image, in: rect)
        let pixels = UnsafeMutableBufferPointer<UInt32>(start: rawData, count: dim)
        
        let histogram = getOriginalHistogram(from: pixels)
        return makeImage(from: histogram)
        
    }
    
    
    func makeImage(from histogram: [Int]) -> CGImage? {
        
        let maxValue = histogram.max()!
        let alpha = Double( 256.0 / Double(maxValue))
        let normalizedHistogram = histogram.map {
            Int(Double($0) * alpha)
        }
        let rawData = UnsafeMutablePointer<UInt32>.allocate(capacity: 256 * 256)
        let pixelsCopy = UnsafeMutableBufferPointer<UInt32>(start: rawData, count: 256 * 256)
        
        for (i, _) in pixelsCopy.enumerated() {
            let line = i / 256
            let colunm = i % 256
            let oppositeLine = 255 - line
            
            if oppositeLine < normalizedHistogram[colunm] {
                //let color =  UInt32(255) << 24 | UInt32(0)
                pixelsCopy[i] = UInt32(255) << 24 | UInt32(0)
            } else {
                pixelsCopy[i] = 0b1111_1111_1111_1111_1111_1111_1111_1111
            }
            
        }
        let outContext = CGContext(data: pixelsCopy.baseAddress,
                                   width: 256, height: 256,
                                   bitsPerComponent: 8,
                                   bytesPerRow: 256 * 4,
                                   space: CGColorSpaceCreateDeviceRGB(),
                                   bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = outContext else {
            return nil
        }
        return context.makeImage()
        
    }
    
    func getOriginalHistogram(from pixels: UnsafeMutableBufferPointer<UInt32>) -> [Int] {
        
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
    func getEqualizedHistogram(from histogram: [Int], pixelsNumber: Int) -> [Int] {
        
        var cumHistogram = [Double](repeating: 0.0, count: histogram.count)
        
        let alpha = 255.0 / Double(pixelsNumber)
        cumHistogram[0] = alpha * Double(histogram[0])
        
        for i in 1..<histogram.count {
            cumHistogram[i] =  cumHistogram[i - 1] + Double(histogram[i]) * alpha
        }
        
        let equalizedHistogram = cumHistogram.map { Int($0) }
        return equalizedHistogram
    }
    
    func makeEqualizedHistogramImage(from image: CGImage) -> [CGImage?] {
        
        let width = image.width
        let height = image.height
        let dim = width * height
        
        //let equalizedHistogram = getEqualizedHistogram(from: getOriginalHistogram(from: image))
        
        let outputRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        let originalRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        
        let imageContext = CGContext(data: originalRawData,
                                     width: width, height: height,
                                     bitsPerComponent: image.bitsPerComponent,
                                     bytesPerRow: Int(4 * width),
                                     space: image.colorSpace!,
                                     bitmapInfo: image.bitmapInfo.rawValue)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        imageContext?.draw(image, in: rect)
        
        let pixels =  UnsafeMutableBufferPointer<UInt32>(start: originalRawData, count: dim)
        let outPixels = UnsafeMutableBufferPointer<UInt32>(start: outputRawData, count: dim)
        
        let originalHistogram = getOriginalHistogram(from: pixels)
        let equalizedHistogram = getEqualizedHistogram(from: originalHistogram, pixelsNumber: dim)
        let equalizedGraphic = makeImage(from: equalizedHistogram)
        
        for (i, _) in outPixels.enumerated() {
            
            let pixel = pixels[i]
            
            let byte0 = UInt8(pixel & 0x000000FF)
            let byte1 = UInt8((pixel & 0x0000FF00) >> 8)
            let byte2 = UInt8((pixel & 0x00FF0000) >> 16)
            let byte3 = UInt8((pixel & 0xFF000000) >> 24) //alpha
            
            let newRed = UInt8(equalizedHistogram[Int(byte0)])
            let newGreen = UInt8(equalizedHistogram[Int(byte1)])
            let newBlue = UInt8(equalizedHistogram[Int(byte2)])
            
            
            let int32 = UInt32(byte3) << 24 | UInt32(newBlue) << 16 | UInt32(newGreen) << 8 | UInt32(newRed)
            
            outPixels[i] = int32
        }
        let outContext = CGContext(data: outPixels.baseAddress,
                                   width: width, height: height,
                                   bitsPerComponent: image.bitsPerComponent,
                                   bytesPerRow: image.bytesPerRow,
                                   space: image.colorSpace!,
                                   bitmapInfo: image.bitmapInfo.rawValue)
        
        guard let context = outContext else {
            return []
        }
        
        return [context.makeImage(), equalizedGraphic]
        
    }
    func getMatchingHistogram(sourceHistogram: [Int], targetHistogram: [Int]) -> [Int] {
        
        var matchingHistogram = [Int](repeating: 0, count: sourceHistogram.count)
        
        for i in 0..<sourceHistogram.count {
            let shade  = sourceHistogram[i]
            var nearestValue = targetHistogram.first!
            for targetShade in targetHistogram {
                if abs(targetShade - shade) < abs(nearestValue - shade) {
                    nearestValue = targetShade
                }
            }
            matchingHistogram[i] = nearestValue
        }
        
        return matchingHistogram
    }
    func makeMatchingHistogramImage(source: CGImage, target: CGImage) -> CGImage? {
        
        let width = source.width
        let height = source.height
        let dim = width * height
        
        let targetWidth = target.width
        let targetHeight = target.height
        let targetDim = targetWidth * targetHeight
        
        
        let matchingRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        let sourceRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        let targetRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: targetDim)
        
        let sourceContext = CGContext(data: sourceRawData,
                                     width: width, height: height,
                                     bitsPerComponent: source.bitsPerComponent,
                                     bytesPerRow: 4 * width,
                                     space: source.colorSpace!,
                                     bitmapInfo: source.bitmapInfo.rawValue)
        
        let sourceRect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        sourceContext?.draw(source, in: sourceRect)
        
        let targetContext = CGContext(data: targetRawData,
                                     width: targetWidth, height: targetHeight,
                                     bitsPerComponent: target.bitsPerComponent,
                                     bytesPerRow: 4 * targetWidth,
                                     space: target.colorSpace!,
                                     bitmapInfo: target.bitmapInfo.rawValue)
        
        let targetRect = CGRect(origin: .zero, size: CGSize(width: targetWidth, height: targetHeight))
        targetContext?.draw(target, in: targetRect)
        
        let originalPixels = UnsafeMutableBufferPointer<UInt32>(start: sourceRawData, count: dim)
        let matchingPixels = UnsafeMutableBufferPointer<UInt32>(start: matchingRawData, count: dim)
        let targetPixels = UnsafeMutableBufferPointer<UInt32>(start: targetRawData, count: targetDim)
        
        let sourceHistogram = getEqualizedHistogram(from: getOriginalHistogram(from: originalPixels), pixelsNumber: dim)
        let targetHistogram = getEqualizedHistogram(from: getOriginalHistogram(from: targetPixels), pixelsNumber: targetDim)
        let matchingHistogram = getMatchingHistogram(sourceHistogram: sourceHistogram, targetHistogram: targetHistogram)
        
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
                                      bitsPerComponent: source.bitsPerComponent,
                                      bytesPerRow: 4 * width,
                                      space: source.colorSpace!,
                                      bitmapInfo: source.bitmapInfo.rawValue)
        
        guard let context = outputContext else {
            return nil
        }
        
        return context.makeImage()
    }
    
    //MARK:- First Part
    
    func flipVertical(image: CGImage) -> CGImage? {
        
        let width = image.width
        let height = image.height
        let dim = width * height
        
        let originalRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        let outputRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        
        let originalContext = CGContext(data: originalRawData,
                                      width: width, height: height,
                                      bitsPerComponent: image.bitsPerComponent,
                                      bytesPerRow: 4 * width,
                                      space: image.colorSpace!,
                                      bitmapInfo: image.bitmapInfo.rawValue)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        originalContext?.draw(image, in: rect)
        
        let originalPixels = UnsafeMutableBufferPointer<UInt32>(start: originalRawData, count: dim)
        let outputPixels = UnsafeMutableBufferPointer<UInt32>(start: outputRawData, count: dim)
        
        for (i, _) in outputPixels.enumerated() {
            let line = i / width
            let colunm = i % width
            let sourceColunmIndex = width - 1 - colunm
            let sourceLineIndex = height - 1 - line
            let index = width * sourceLineIndex + sourceColunmIndex
            outputPixels[i] = originalPixels[index]
        }

        let outputContext = CGContext(data: outputPixels.baseAddress,
                                      width: width, height: height,
                                      bitsPerComponent: image.bitsPerComponent,
                                      bytesPerRow: 4 * width,
                                      space: image.colorSpace!,
                                      bitmapInfo: image.bitmapInfo.rawValue)
        
        
        guard let context = outputContext else {
            return nil
        }
        return context.makeImage()
    }
    
    func flipHorizontal(image: CGImage) -> CGImage? {
        
        let width = image.width
        let height = image.height
        let dim = width * height
        
        let originalRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        let outputRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        
        let originalContext = CGContext(data: originalRawData,
                                        width: width, height: height,
                                        bitsPerComponent: image.bitsPerComponent,
                                        bytesPerRow: 4 * width,
                                        space: image.colorSpace!,
                                        bitmapInfo: image.bitmapInfo.rawValue)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        originalContext?.draw(image, in: rect)
        
        let originalPixels = UnsafeMutableBufferPointer<UInt32>(start: originalRawData, count: dim)
        let outputPixels = UnsafeMutableBufferPointer<UInt32>(start: outputRawData, count: dim)
        
        for (i, _) in outputPixels.enumerated() {
            let line = i / width
            let colunm = i % width
            let sourceColunmIndex = width - 1 - colunm
            let sourceLineIndex = line
            let index = width * sourceLineIndex + sourceColunmIndex
            outputPixels[i] = originalPixels[index]
        }
        
        let outputContext = CGContext(data: outputPixels.baseAddress,
                                      width: width, height: height,
                                      bitsPerComponent: image.bitsPerComponent,
                                      bytesPerRow: 4 * width,
                                      space: image.colorSpace!,
                                      bitmapInfo: image.bitmapInfo.rawValue)
        
        
        guard let context = outputContext else {
            return nil
        }
        return context.makeImage()
    }
    
    func grayScale(image: CGImage) -> CGImage? {
        
        let width = image.width
        let height = image.height
        let dim = width * height
        
        let originalRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        let outputRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        
        let originalContext = CGContext(data: originalRawData,
                                        width: width, height: height,
                                        bitsPerComponent: image.bitsPerComponent,
                                        bytesPerRow: 4 * width,
                                        space: image.colorSpace!,
                                        bitmapInfo: image.bitmapInfo.rawValue)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        originalContext?.draw(image, in: rect)
        
        let originalPixels = UnsafeMutableBufferPointer<UInt32>(start: originalRawData, count: dim)
        let outputPixels = UnsafeMutableBufferPointer<UInt32>(start: outputRawData, count: dim)
        
        for (i, _) in outputPixels.enumerated() {
            
            let pixel = originalPixels[i]
            
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
            
            outputPixels[i] = int32
        }
        
        
        let outputContext = CGContext(data: outputPixels.baseAddress,
                                      width: width, height: height,
                                      bitsPerComponent: image.bitsPerComponent,
                                      bytesPerRow: 4 * width,
                                      space: image.colorSpace!,
                                      bitmapInfo: image.bitmapInfo.rawValue)
        
        
        guard let context = outputContext else {
            return nil
        }
        return context.makeImage()
        
    }
    
    func quantization(image: CGImage, shadesNumber: Int) -> CGImage? {
        
        let width = image.width
        let height = image.height
        let dim = width * height
        
        let originalRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        let outputRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        
        let originalContext = CGContext(data: originalRawData,
                                        width: width, height: height,
                                        bitsPerComponent: image.bitsPerComponent,
                                        bytesPerRow: 4 * width,
                                        space: image.colorSpace!,
                                        bitmapInfo: image.bitmapInfo.rawValue)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        originalContext?.draw(image, in: rect)
        
        let originalPixels = UnsafeMutableBufferPointer<UInt32>(start: originalRawData, count: dim)
        let outputPixels = UnsafeMutableBufferPointer<UInt32>(start: outputRawData, count: dim)
        
        for (i, _) in outputPixels.enumerated() {
            
            let pixel = originalPixels[i]
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
            
            outputPixels[i] = int32
        }
        
        
        let outputContext = CGContext(data: outputPixels.baseAddress,
                                      width: width, height: height,
                                      bitsPerComponent: image.bitsPerComponent,
                                      bytesPerRow: 4 * width,
                                      space: image.colorSpace!,
                                      bitmapInfo: image.bitmapInfo.rawValue)
        
        
        guard let context = outputContext else {
            return nil
        }
        return context.makeImage()
        
    }
    
    func copy(image: CGImage) -> CGImage? {
        
        let width = image.width
        let height = image.height
        let dim = width * height
        
        let originalRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        let outputRawData = UnsafeMutablePointer<UInt32>.allocate(capacity: dim)
        
        let originalContext = CGContext(data: originalRawData,
                                        width: width, height: height,
                                        bitsPerComponent: image.bitsPerComponent,
                                        bytesPerRow: 4 * width,
                                        space: image.colorSpace!,
                                        bitmapInfo: image.bitmapInfo.rawValue)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        originalContext?.draw(image, in: rect)
        
        let originalPixels = UnsafeMutableBufferPointer<UInt32>(start: originalRawData, count: dim)
        let outputPixels = UnsafeMutableBufferPointer<UInt32>(start: outputRawData, count: dim)
        
        for (i, _) in outputPixels.enumerated() {
            outputPixels[i] = originalPixels[i]
        }
        
        
        let outputContext = CGContext(data: outputPixels.baseAddress,
                                      width: width, height: height,
                                      bitsPerComponent: image.bitsPerComponent,
                                      bytesPerRow: 4 * width,
                                      space: image.colorSpace!,
                                      bitmapInfo: image.bitmapInfo.rawValue)
        
        
        guard let context = outputContext else {
            return nil
        }
        return context.makeImage()
        
    }
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
    
    func save(image: CGImage, name: String) {
        
        let uiImage = UIImage(cgImage: image)
        let data = UIImageJPEGRepresentation(uiImage, 1)
        save(data: data, name: name)
    }
    
    
}
