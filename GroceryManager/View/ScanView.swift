//
//  BarcodeView.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 1/4/20.
//

import SwiftUI

struct ScanView: View {
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        VStack{
            Barcode(supportBarcode: [.ean8, .ean13, .upce, .code128, .code93, .code39])
                .interval(delay: 5.0) //Event will trigger every 5 seconds
                .found {
                    print($0)
                    self.userData.PRODUCT_CODE = $0
                    switch userData.SCAN_MODE {
                    case .read_mode:
                        userData.ACTIVE_SCREEN = .info
                    case .update_mode:
                        userData.ACTIVE_SCREEN = .update
                    }
            }
        }
        .onAppear {
            self.userData.PRODUCT_LOADED = false
        }
    }
    
}

// MARK: PREVIEW
struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
