//
//  MySingleton.swift
//  My Plim
//
//  Created by João Costa on 10/04/2019.
//  Copyright © 2019 ipvc.estg. All rights reserved.
//

import Foundation
import UIKit

final class MySingleton{
    static let shared = MySingleton()
    //
    var username: String
    
    //
    init() {
        self.username = "Ups"
    }
    
    func getUsername() -> String{
        return self.username
    }
    func setUsername(username: String){
        self.username = username
    }
    
    //Get navigation bar properties
        //Navigation bar image
    public func getImageTitle() -> UIImageView{
        //
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
        imageView.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "aplication_iconWhite")
        imageView.image = image
        return imageView
    }
    public func getButtonLogout() -> UIButton{
        let logoutButton = UIButton(type: .system)
        //logoutButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        logoutButton.setImage(UIImage(named: "logout")?.withRenderingMode(.alwaysOriginal), for: .normal)
        //logoutButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        return logoutButton
    }
    public func getAccountSettingsButton() -> UIButton{
        let accountSettingsButton = UIButton(type: .system)
        //accountSettingsButton.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        //accountSettingsButton.setBackgroundImage(UIImage(named: "accountsettings")?.withRenderingMode(.alwaysOriginal), for: .normal)
        accountSettingsButton.setImage(UIImage(named: "accountsettings")?.withRenderingMode(.alwaysOriginal), for: .normal)
        accountSettingsButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        return accountSettingsButton
    }
    
}
