//
//  BlockedTableViewController.swift
//  My Plim
//
//  Created by João Costa on 06/06/2019.
//  Copyright © 2019 ipvc.estg. All rights reserved.
//

import UIKit

class BlockedTableViewController: UITableViewController {
    var userArray = [EntityUser]()
    @IBOutlet var tableViewReference: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        tableViewReference.rowHeight = UITableView.automaticDimension
        tableViewReference.estimatedRowHeight = 150
        //
        self.tableViewReference.refreshControl?.addTarget(self, action: #selector(BlockedTableViewController.refreshUsers), for: UIControl.Event.valueChanged)
        //
        loadUsersFromDB()
    }
    @objc func refreshUsers(){
        userArray.removeAll()
        loadUsersFromDB()
        self.refreshControl?.endRefreshing()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
            emptyListCell.textLabel?.text = NSLocalizedString("blockedTable.noBlocked", comment: "")
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
extension BlockedTableViewController: UserTableViewCellDelegate{
    //Buttons clicked methods
    func didClickCallUser(username: String) {
        //
    }
    
    func didClickFavorite(username: String) {
        //
    }
    
    func didClickBlockUser(username: String) {
        let alert = UIAlertController(title: "Desbloquear Utilizador", message: "De certeza que pretende desbloquear este utilizador?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("confirmationstring.yes", comment: ""), style: .destructive, handler: { action in
            print("Changing favorito")
            //Add to favoritos or remove from there
            //
            self.removerBloqueio(userID: username)
            print("Remover dos bloqueados")
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("confirmationstring.no", comment: ""), style: .default, handler: { action in
            print("Stoping changing blocked")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
//Webservices Extensio
extension BlockedTableViewController{
    func loadUsersFromDB(){
        print("Hello my friend: ", MySingleton.shared.getUsername())
        let webServiceStringURL = "https://my-plim.com/MyPlim/webservices/slim/api/listabloqueados/"+MySingleton.shared.getUsername()
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
                            user1.foto = urlFoto+arrayUsers[index].foto!
                            user1.username = arrayUsers[index].username!
                            user1.id = arrayUsers[index].id!
                            self.userArray.append(user1)
                        }
                        print("Reloading blocked table...")
                        self.tableViewReference.reloadData()
                    }catch let jsonErr{
                        print("JSON decode error: ", jsonErr)
                        self.userArray.removeAll()
                        self.tableViewReference.reloadData()
                    }
                }
            }
        }.resume()
    }
    //
    func removerBloqueio(userID: String){
        var request = URLRequest(url: URL(string: "https://my-plim.com/MyPlim/webservices/slim/api/desbloquearuser")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do{
            let dados = EntityBloqueado(username: MySingleton.shared.getUsername(), bloqueado: userID)
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
            print("Tamanho do array: ", self.userArray.count)
            self.userArray.removeAll()
            self.loadUsersFromDB()
        }
        task.resume()
    }
    
}


