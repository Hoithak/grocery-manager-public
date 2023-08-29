//
//  CalibrateView.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 1/10/20.
//  Copyright © 2020 Pranot Kotchakoon. All rights reserved.
//

import SwiftUI
import Combine

struct CalibrateView: View {
    
    // App variable
    @EnvironmentObject var userData: UserData
    @ObservedObject var iEnhance = ImageProcessing()
    @State var showImagePicker:Bool = false
    @State var isEnhance:Bool = false
    @State var image: Image? = nil
    @State var uiimage: UIImage? = nil
    @State var sourceType:Int = 0
    
    var body: some View {
        NavigationView {
            VStack (spacing: 20) {
                Text("Adjust to eliminate the background")
                    .foregroundColor(COLOR_GRAY01)
                    .font(.headline)
                image?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .foregroundColor(COLOR_GREEN01)

                VStack {
                    Text("Hue: \(iEnhance.hue, specifier: "%.0f")")
                        .foregroundColor(COLOR_GRAY01)
                    Slider(value: $iEnhance.hue, in: 0...360, step: 1)
                    .background(Image("Huebar")
                    .resizable()
                    .frame(height: 20))
                }
                .padding(.horizontal)
                VStack {
                    Text("Distance: \(iEnhance.distance, specifier: "%.3f")")
                        .foregroundColor(COLOR_GRAY01)
                    Slider(value: $iEnhance.distance, in: 0.025...0.4, step: 0.025)
                }
                .padding(.horizontal)
                
                // Sumit button
                HStack(spacing: 10) {

                    Button(action: {
                        let defaults = UserDefaults.standard
                        defaults.set(self.iEnhance.hue, forKey: "hue")
                        defaults.set(self.iEnhance.distance, forKey: "distance")
                    }) {
                        SubmitButtonView(title: "SAVE", image: "square.and.pencil")
                    }
                    .modifier(SubmitButtonModifier())
                }.padding(.top, 30)
                // End sumit button
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(isVisible: self.$showImagePicker, isEnhance: self.$isEnhance, image: self.$image, uiimage: self.$uiimage, sourceType: 0)
            }
            .onAppear {
                self.image = Image(systemName: "photo")
            }

            .navigationBarTitle("Camera Calibration")
            .foregroundColor(COLOR_GREEN01)
        }
    }
}

// MARK: PREVIEW
struct CalibrateView_Previews: PreviewProvider {
    static var previews: some View {
        CalibrateView().environmentObject(UserData())
    }
}
