//
//  UsersTableViewCell.swift
//  My Plim
//
//  Created by João Costa on 08/04/2019.
//  Copyright © 2019 ipvc.estg. All rights reserved.
//

import UIKit

protocol UserTableViewCellDelegate {
    func didClickCallUser(username: String)
    func didClickFavorite(username: String)
    func didClickBlockUser(username: String)
}

class UsersTableViewCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    //@IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var favoritosBtnReference: UIButton!
    //
    var userItem: EntityUser!
    var delegate: UserTableViewCellDelegate?
    
    //
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    //
    func setUser(user: EntityUser){
        self.userItem = user
        self.nameLabel.text = user.nome
        if(self.ageLabel != nil){
            self.ageLabel.text = String(user.idade) + " anos"
        }
        //self.locationLabel.text = user.location
        let url = URL(string: user.foto)
        if(url != nil){
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    self.photoImageView.image = UIImage(data: data!)
                }
            }
            self.photoImageView.contentMode = UIView.ContentMode.scaleAspectFit
        }else{
            let image = UIImage(named: "nopicture")
            self.photoImageView.image = image
            self.photoImageView.contentMode = UIView.ContentMode.center
        }
        if user.favorito{
            if(favoritosBtnReference != nil){
                favoritosBtnReference.setImage(UIImage(named: "heartfull")?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }else{
            if(favoritosBtnReference != nil){
                favoritosBtnReference.setImage(UIImage(named: "heart")?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }
    //MARK: Actions
    @IBAction func callUserClicked(_ sender: Any) {
        delegate?.didClickCallUser(username: self.userItem.username)
    }
    @IBAction func favoritesClicked(_ sender: Any) {
        delegate?.didClickFavorite(username: self.userItem.id)
    }
    @IBAction func blockUserClicked(_ sender: Any) {
        delegate?.didClickBlockUser(username: self.userItem.id)
    }
    
    
}
