import Foundation
import UIKit

typealias Pixel = UInt32

extension Sequence where Iterator.Element == Pixel {
    
}

extension Array where Element == Pixel {
   
    func average() -> UInt32 {
        
        var sumByte0 = 0
        var sumByte1 = 0
        var sumByte2 = 0
        let pixelsCount = self.count
        
        for pixel in self {
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
}
