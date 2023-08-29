//
//  DBconfView.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 12/7/19.
//

import SwiftUI
import Combine

struct AppSettingView: View {
    
    // Declaration
    @EnvironmentObject var userData: UserData
    @State var host_address: String = ""
    @State var db_name: String = ""
    @State var db_username: String = ""
    @State var db_password: String = ""
    @State var woo_address: String = ""
    @State var woo_key: String = ""
    @State var woo_secret: String = ""
    @State private var testStatus = ""
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isAlert = false
    @State private var isValidated = false
    
    var body: some View {
        
        ZStack {
            
            // Main view
            VStack(alignment: .leading, spacing: 10) {
                
                Spacer()
                
                HStack {
                    // Header
                    Text("Setting")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(COLOR_BLACK01)
                        .padding(.top, 50)
                    
                    // Icon
                    Image(systemName: "externaldrive.connected.to.line.below.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30, height: 30)
                        .foregroundColor(COLOR_GRAY01)
                        .padding(.top, 50)
                        .padding(.leading, 15)
                }
                
                // Subheader
                Text("Setup all database configulation parameters")
                    .font(.subheadline)
                    .foregroundColor(COLOR_GRAY01)
                
                // Input
                HStack {
                    Spacer()
                    VStack{
                        TextInputTypeA(value: $host_address, topic: "Host IP", width: 320, inputWidth: 160)
                        TextInputTypeA(value: $db_name, topic: "DB Name", width: 320, inputWidth: 160)
                        TextInputTypeA(value: $db_username, topic: "DB Username", width: 320, inputWidth: 160)
                        SecureInputTypeA(value: $db_password, topic: "DB Password", width: 320, inputWidth: 160)
                        TextInputTypeA(value: $woo_address, topic: "Woo Enpoint", width: 320, inputWidth: 160)
                        SecureInputTypeA(value: $woo_key, topic: "Woo Key", width: 320, inputWidth: 160)
                        SecureInputTypeA(value: $woo_secret, topic: "Woo Secret", width: 320, inputWidth: 160)
                    }
                    Spacer()
                }
                .padding(.top, 30)
                
                // Button
                HStack {
                    Spacer()
                    ButtonStyleA(text: "Save", icon: "square.and.arrow.down", clicked: self.saveConfigulation)
                        .modifier(SubmitButtonModifier())
                    Spacer()
                }.padding(.top, 40)
                
                Spacer()
            }
            .modifier(MainPanelModifier())
            .edgesIgnoringSafeArea(.top)

            .alert(isPresented: $isAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Ok")){
                    if isValidated {
                        self.userData.ACTIVE_SCREEN = .welcome
                        self.userData.TABBAR_PRESENT = false
                    }
                })
            }
            
            // Loading view
            if userData.LOADING_SCREEN_PRESENT {
                LoadingView()
            }
        }
        
        // Load configuration
        .onAppear {
            self.loadConfiguration()
        }
    }
    
    // MARK: [ Load local configuration ]
    func loadConfiguration() {
        let defaults = UserDefaults.standard
        host_address = defaults.string(forKey: "host_address") ?? host_address
        db_name = defaults.string(forKey: "db_name") ?? db_name
        db_username = defaults.string(forKey: "db_username") ?? db_username
        db_password = defaults.string(forKey: "db_password") ?? db_password
        woo_address = defaults.string(forKey: "woo_address") ?? woo_address
        woo_key = defaults.string(forKey: "woo_key") ?? woo_key
        woo_secret = defaults.string(forKey: "woo_secret") ?? woo_secret
    }
    
    
    // MARK: [ Save configuration ]
    func saveConfigulation() {
        // Show loading view
        self.userData.LOADING_SCREEN_PRESENT = true
        
        // Save configuration to default property
        let defaults = UserDefaults.standard
        defaults.set(self.host_address, forKey: "host_address")
        defaults.set(self.db_name, forKey: "db_name")
        defaults.set(self.db_username, forKey: "db_username")
        defaults.set(self.db_password, forKey: "db_password")
        defaults.set(self.woo_address, forKey: "woo_address")
        defaults.set(self.woo_key, forKey: "woo_key")
        defaults.set(self.woo_secret, forKey: "woo_secret")
        
        DatabaseService.shared.setDatabaseParameters()
        DatabaseService.shared.checkConnection() { result in
            if result == "Connect success !!!" {
                self.alertTitle = "Save"
                self.alertMessage = "Successfully !!!"
                self.isValidated = true
            }
            else {
                self.alertTitle = "Cannot connect to database"
                self.alertMessage = "Please contact admin"
            }
        }
        
        // Hide loding view
        DispatchQueue.main.async {
            self.userData.LOADING_SCREEN_PRESENT = false
            self.isAlert = true
        }
    }
        
}

// MARK: PREVIEW
struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        AppSettingView().environmentObject(UserData())
    }
}
