//
//  WelcomeView.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 12/9/19.
//

import SwiftUI

struct WelcomeView: View {
    
    @EnvironmentObject var userData: UserData
    @State private var displayStatus = "Connecting to database . . ."
    @State private var alertMessage = ""
    @State private var isAlert = false
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack {
                Image("logo-green")
                    .resizable()
                    .frame(width: 150, height: 150)
                Text("Grocery Manager")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(COLOR_GRAY01)
                    .padding(.bottom, 1)
                Text("version \(UIApplication.appVersion ?? "unknown")")
                    .foregroundColor(COLOR_BLACK01)
                    .padding(.bottom, 100)
            }

            VStack() {
                Spacer()
                Text(displayStatus)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(COLOR_GREEN01)
                .padding(.bottom, 150)
            }
        }
        .onAppear {
            self.loadTablesFromDatabaseAndAssignToGlobal()
        }
        .alert(isPresented: $isAlert) {
            Alert(title: Text("Cannot connect to database"), message: Text(alertMessage), dismissButton: .default(Text("Setting")){
                self.userData.ACTIVE_SCREEN = .setting
            })
        }
    }
    
    func loadTablesFromDatabaseAndAssignToGlobal() {
        DatabaseService.shared.checkConnection() { result in
            if result == "Connect success !!!" {
                self.displayStatus = result
                self.isAlert = false
                sleep(2)
                
                DatabaseService.shared.getCategoryTable { categories in
                    DispatchQueue.main.async {
                        self.userData.CATEGORY = categories
                    }
                }

                DatabaseService.shared.getTaxTable { taxes in
                    DispatchQueue.main.async {
                        self.userData.TAX = taxes
                    }
                }

                DispatchQueue.main.async {
                    self.userData.ACTIVE_SCREEN = .home
                    self.userData.TABBAR_PRESENT = true
                }
                
            } else {
                self.alertMessage = result
                self.isAlert = true
            }
        }
        
    }
    
}

// MARK: PREVEIW
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView().environmentObject(UserData())
    }
}
