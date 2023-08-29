//
//  ImageProcessing.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 1/12/20.
//

import SwiftUI
import Combine

class ImageProcessing: ObservableObject {
    //  This class is under development
    
    static var shared = ImageProcessing()
    
    @Published var hue:Double = 246
    @Published var distance:CGFloat = 0.20
    //var orgimage:UIImage
    let context = CIContext()
    let defaults = UserDefaults.standard
    
    init() {
        //self.orgimage = orgimage
        //self.uiimage = orgimage
        if let savedHue = Double(self.defaults.string(forKey: "hue") ?? "") {
            self.hue = savedHue
        }
        if let savedDistance = Float(self.defaults.string(forKey: "distance") ?? "") {
            self.distance = CGFloat(savedDistance)
        }
    }

    /*
    func process(uiimage: UIImage)->Image? {
        let minHue = CGFloat(self.hue/360) - self.distance
        let maxHue = CGFloat(self.hue/360) + self.distance
        let invertHue = (minHue < 0 || maxHue > 1) ? true:false
        
        guard let currentImage = CIImage(image: uiimage) else { return nil }
        let chromaCIFilter = chromaKeyFilter(fromHue: minHue, toHue: maxHue, invert: invertHue)
        chromaCIFilter?.setValue(currentImage, forKey: kCIInputImageKey)
        if let outputImage = chromaCIFilter?.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                let tmp = UIImage(cgImage: cgimg)
                return Image(uiImage: tmp)
            }
        }
        return nil
    }
    */
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        let contextSize: CGSize = contextImage.size

        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)

        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }

        //let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
        let rect = CGRect(origin: CGPoint(x: posX,y : posY), size: CGSize(width: cgwidth, height: cgheight))

        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        return image
    }

    func getHue(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat {
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        var hue: CGFloat = 0
        color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return hue
    }

    /*
    func chromaKeyFilter(fromHue: CGFloat, toHue: CGFloat, invert: Bool) -> CIFilter? {
        // 1
        let size = 64
        var cubeRGB = [Float]()
            
        // 2
        for z in 0 ..< size {
            let blue = CGFloat(z) / CGFloat(size-1)
            for y in 0 ..< size {
                let green = CGFloat(y) / CGFloat(size-1)
                for x in 0 ..< size {
                    let red = CGFloat(x) / CGFloat(size-1)
                        
                    // 3
                    let hue = getHue(red: red, green: green, blue: blue)
                    var alpha: CGFloat = 0
                    if !invert {
                        alpha = (hue >= fromHue && hue <= toHue) ? 0: 1
                    }
                    else {
                        if (fromHue < 0) {
                            alpha = (hue < toHue || hue > 1+fromHue) ? 0:1
                        }
                        else if (toHue > 1) {
                            alpha = (hue > fromHue || hue < 1-fromHue) ? 0:1
                        }
                    }
                    // 4
                    cubeRGB.append(Float(red * alpha))
                    cubeRGB.append(Float(green * alpha))
                    cubeRGB.append(Float(blue * alpha))
                    cubeRGB.append(Float(alpha))
                }
            }
        }

        let data = Data(buffer: UnsafeBufferPointer(start: &cubeRGB, count: cubeRGB.count))
        let colorCubeFilter = CIFilter(name: "CIColorCube", parameters: ["inputCubeDimension": size, "inputCubeData": data])
        return colorCubeFilter
    }
     */
    
}
