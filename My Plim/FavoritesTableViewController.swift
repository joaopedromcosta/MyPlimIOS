//
//  FavoritesTableViewController.swift
//  My Plim
//
//  Created by João Costa on 11/04/2019.
//  Copyright © 2019 ipvc.estg. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController {
    //MARK: Properties
    var userArray = [EntityUser]()
    @IBOutlet var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 150
        //
        self.tableview.refreshControl?.addTarget(self, action: #selector(FavoritesTableViewController.refreshUsers), for: UIControl.Event.valueChanged)
        //
        loadUsersFromDB()
    }
    @objc func refreshUsers(){
        userArray.removeAll()
        loadUsersFromDB()
        self.refreshControl?.endRefreshing()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(userArray.isEmpty){
            return 1
        }else{
            return userArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        if userArray.isEmpty {
            let emptyListCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "NoDataCell")
            emptyListCell.textLabel?.text = NSLocalizedString("favoritesTable.noFavorites", comment: "")
            emptyListCell.textLabel?.font = UIFont(name:"Arial", size:20)
            return emptyListCell
        }else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UsersTableViewCell", for: indexPath) as? UsersTableViewCell else{
                fatalError("The dequeued cell is not an instance of UsersTableViewCell.")
            }
            cell.setUser(user: userArray[indexPath.row])
            cell.delegate = self
            return cell
        }
    }
}

//Cell actions extension
extension FavoritesTableViewController: UserTableViewCellDelegate{
    //
    //Buttons clicked methods
    func didClickCallUser(username: String) {
        //self.performSegue(withIdentifier: "callUserSegue", sender: username)
    }
    
    func didClickFavorite(username: String) {
        let alert = UIAlertController(title: "Remover Favorito", message: "De certeza que pretende remover dos favoritos?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("confirmationstring.yes", comment: ""), style: .destructive, handler: { action in
            print("Changing favorito")
            //Add to favoritos or remove from there
            //
            self.removerFavoritos(user: username)
            print("Remover dos favoritos")
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("confirmationstring.no", comment: ""), style: .default, handler: { action in
            print("Stoping changing favorito")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func didClickBlockUser(username: String) {
        //Do nothing
    }
}
//Webservices Extensio
extension FavoritesTableViewController{
    func loadUsersFromDB(){
        print("Hello my friend: ", MySingleton.shared.getUsername())
        let webServiceStringURL = "https://my-plim.com/MyPlim/webservices/slim/api/listafavoritos/"+MySingleton.shared.getUsername()
        guard let url = URL.init(string: webServiceStringURL) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            //Check for errors
            if(err != nil){
                print("Error in request: \(String(describing: err))")
            }
            //check for status 200 ok
            if let httpresponse = response as? HTTPURLResponse {
                if httpresponse.statusCode != 200{
                    print("Bad request!")
                    return
                }else{
                    print("Request status code: \(httpresponse.statusCode)")
                }
            }
            //
            if let data = data{
                DispatchQueue.main.async {
                    do{
                        let usersRequest = try JSONDecoder().decode(RequestFormat.self, from: data)
                        let urlFoto = "https://my-plim.com/MyPlim/web/uploads/fotos/"
                        let arrayUsers = usersRequest.DATA
                        var user1:EntityUser
                        let arraySize = arrayUsers.count-1
                        for index in 0...arraySize{
                            user1 = EntityUser()
                            user1.nome = arrayUsers[index].nome!
                            user1.location = ""
                            user1.foto = urlFoto+arrayUsers[index].foto!//eaf29f2f94e7a19ef73198d4b16a387b.png
                            user1.username = arrayUsers[index].username!
                            user1.id = arrayUsers[index].id!
                            user1.favorito = true
                            user1.idade = arrayUsers[index].idade
                            self.userArray.append(user1)
                        }
                        print("Reloading favorites table...")
                        self.tableview.reloadData()
                    }catch let jsonErr{
                        print("JSON decode error: ", jsonErr)
                        self.userArray.removeAll()
                        self.tableview.reloadData()
                    }
                }
            }
        }.resume()
    }
    //
    //remover a favoritos
    func removerFavoritos(user: String){
        var request = URLRequest(url: URL(string: "https://my-plim.com/MyPlim/webservices/slim/api/desmarcarfavoritouser")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do{
            let dados = EntityFavorito(username: MySingleton.shared.getUsername(), favorito: user)
            let jsonBody = try JSONEncoder().encode(dados)
            request.httpBody = jsonBody
            print("JSON body: ", String(bytes: jsonBody, encoding: .utf8)!)
        }catch {
            print("Erro na preparação dos dados")
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
            //Check for errors
            if(err != nil){
                print("Error in request: \(String(describing: err))")
            }
            //check for status 200 ok
            if let httpresponse = response as? HTTPURLResponse {
                if httpresponse.statusCode != 200{
                    print("Bad request!")
                    return
                }else{
                    print("Request status code: \(httpresponse.statusCode)")
                }
            }
            //
            self.userArray.removeAll()
            self.loadUsersFromDB()
        }
        task.resume()
    }
    //
    private func callReloadTable(){
        self.tableview.reloadData()
    }
}
