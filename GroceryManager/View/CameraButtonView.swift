//
//  CameraButtonView.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 1/2/20.
//

import SwiftUI

struct CameraButtonView: View {
    @Binding var showActionSheet:Bool
    @Binding var actionSheetMode:UpdateActionSheet
    
    var body: some View {
        Button(action: {
            self.showActionSheet = true
            self.actionSheetMode = .photo
        }) {
            RoundedRectangle(cornerRadius: 30)
                .frame(width: 38, height: 38, alignment: .center)
                .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .frame(width: 36, height: 36, alignment: .center)
                    .foregroundColor(COLOR_GRAY03)
                .overlay(
                    Image(systemName: "camera.fill")
                        .foregroundColor(.black)
                )
            )
        }
    }
}

// MARK: PREVIEW
struct CameraButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CameraButtonView(showActionSheet: .constant(true), actionSheetMode: .constant(.photo))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
