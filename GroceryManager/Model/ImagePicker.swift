//
//  ImagePicker.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 1/2/20.
//

import SwiftUI
import AVFoundation

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var isVisible:Bool
    @Binding var isEnhance:Bool
    @Binding var image:Image?
    @Binding var uiimage:UIImage?
    var sourceType:Int
    
    func makeCoordinator() -> ImagePicker.Coordinator {
        Coordinator(isVisible: $isVisible, isEnhance: $isEnhance, image: $image, uiimage: $uiimage)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let vc = UIImagePickerController()
        vc.allowsEditing = false
        vc.sourceType = sourceType == 1 ? .photoLibrary : .camera
        
        if vc.sourceType == .camera {
            vc.showsCameraControls = true
            let newY = (UIScreen.main.bounds.height - UIScreen.main.bounds.width) / 3
            vc.cameraOverlayView = SquareView(frame: CGRect(x: 0, y: newY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
        }
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = context.coordinator
        return vc
    }
    
    class SquareView: UIView {

        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = UIColor.clear
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func draw(_ rect: CGRect) {
            super.draw(rect)
            if let context = UIGraphicsGetCurrentContext() {
                let clipPath = UIBezierPath(roundedRect: rect, cornerRadius: 10.0).cgPath
                context.setLineWidth(6.0)
                UIColor.green.set()
                context.addPath(clipPath)
                context.closePath()
                context.strokePath()
            }
        }
        
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var isVisible:Bool
        @Binding var isEnhance:Bool
        @Binding var image:Image?
        @Binding var uiimage:UIImage?
        
        init(isVisible: Binding<Bool>, isEnhance: Binding<Bool>, image: Binding<Image?>, uiimage: Binding<UIImage?>){
            _isVisible = isVisible
            _isEnhance = isEnhance
            _image = image
            _uiimage = uiimage
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            let uiimagedata = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            let rImage = ImageProcessing.shared.resizeImage(image: uiimagedata, targetSize: CGSize(width: 300, height: 300))
            let cImage = ImageProcessing.shared.cropToBounds(image: rImage, width: 300, height: 300)
            print("\(isEnhance)")

            uiimage = cImage
            image = Image(uiImage: uiimage!)
            isVisible = false
        }
        
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isVisible = false
        }
        
    }
}
