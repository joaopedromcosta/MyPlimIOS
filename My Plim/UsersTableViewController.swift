//
//  UsersTableViewController.swift
//  My Plim
//
//  Created by João Costa on 09/04/2019.
//  Copyright © 2019 ipvc.estg. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController {
    //MARK: Properties
    //var client: SINClient?
    //
    var userArray = [EntityUser]()
    @IBOutlet var tableviewReference: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableviewReference.rowHeight = UITableView.automaticDimension
        tableviewReference.estimatedRowHeight = 150
        //
        self.tableviewReference.refreshControl?.addTarget(self, action: #selector(UsersTableViewController.refreshUsers), for: UIControl.Event.valueChanged)
        //
        loadUsersFromDB()
    }
    //
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Navigation bar customization
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.titleView = MySingleton.shared.getImageTitle()
        let buttonLogout = MySingleton.shared.getButtonLogout()
        let buttonAccountSets = MySingleton.shared.getAccountSettingsButton()
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonLogout)
        self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: buttonAccountSets)
        buttonLogout.addTarget(self, action: #selector(UsersTableViewController.logoutAction(_:)), for: .touchUpInside)
        //->END
        //
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
        return userArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UsersTableViewCell", for: indexPath) as? UsersTableViewCell else{
            fatalError("The dequeued cell is not an instance of UsersTableViewCell.")
        }
        if userArray.isEmpty {
            let emptyListCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "NoDataCell")
            emptyListCell.textLabel?.text = NSLocalizedString("userTable.noUsers", comment: "")
            return emptyListCell
        }
        cell.setUser(user: userArray[indexPath.row])
        cell.delegate = self
        // Configure the cell...
        return cell
    }
    //Logout action -> When logout icon is pressed this function is executed
    @IBAction func logoutAction(_ sender:UIButton!){
        let alert = UIAlertController(title: NSLocalizedString("logout.alertTitle", comment: ""), message: NSLocalizedString("logout.alertMessage", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("confirmationstring.yes", comment: ""), style: .destructive, handler: { action in
            print("Running logout")
            //Destroy UserDefaults and MySingleton Data
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            UserDefaults.standard.set("", forKey: "userName")
            UserDefaults.standard.synchronize()
            MySingleton.shared.setUsername(username: "")
            //Go to login page
            self.performSegue(withIdentifier: "runLogoutUnwindSegue", sender: self)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("confirmationstring.no", comment: ""), style: .default, handler: { action in
            print("Stoping logout")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
//Cell actions extension
extension UsersTableViewController: UserTableViewCellDelegate{
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "callUserSegue"{
            let destVC = segue.destination as! CallUserViewController
            destVC.userToCall = (sender as? String)!
            destVC.fromUser = MySingleton.shared.getUsername()
            //destVC.client = self.client
        }
    }
    //Buttons clicked methods
    func didClickCallUser(username: String) {        
        self.performSegue(withIdentifier: "callUserSegue", sender: username)
    }
    
    func didClickFavorite(username: String) {
        var mensagem = ""
        var adicionar = false
        userArray.forEach(){ tmp in
            if tmp.id == username{
                if tmp.favorito{
                    //É favorito...deve se remover
                    adicionar = false
                    mensagem = "Remover \(tmp.nome) dos Favoritos?"
                }else{
                    //Não é favorito...deve se adicionar
                    adicionar = true
                    mensagem = "Adicionar \(tmp.nome) aos Favoritos?"
                }
            }
        }
        if adicionar{
            self.changeFavoritos(user: username, api: "favoritouser")
            print("Adicionar dos favoritos")
        }else{
            self.changeFavoritos(user: username, api: "desmarcarfavoritouser")
            print("Remover dos favoritos")
        }
    }
    
    func didClickBlockUser(username: String) {
        let alert = UIAlertController(title: "Bloquear Utilizador", message: "De certeza que pretende bloquear este utilizador?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("confirmationstring.yes", comment: ""), style: .destructive, handler: { action in
            print("Changing favorito")
            //Add to favoritos or remove from there
            //
            //Executar mudanca na BD
            self.bloquear(user: username)
            print("Remover dos bloqueados")
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("confirmationstring.no", comment: ""), style: .default, handler: { action in
            print("Stoping changing blocked")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
//Webservices Extension
extension UsersTableViewController{
    func loadUsersFromDB(){
        print("Hello my friend: ", MySingleton.shared.getUsername())
        let webServiceStringURL = "https://my-plim.com/MyPlim/webservices/slim/api/listausers/"+MySingleton.shared.getUsername()
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
                            user1.favorito = arrayUsers[index].favorito!
                            user1.idade = arrayUsers[index].idade
                            self.userArray.append(user1)
                        }
                        print("Reloading favorites table...")
                        self.tableviewReference.reloadData()
                    }catch let jsonErr{
                        print("JSON decode error: ", jsonErr)
                    }
                }
            }
        }.resume()
    }
    //Adicionar a favoritos
    func changeFavoritos(user: String, api: String){
        print("URL a testar: https://my-plim.com/MyPlim/webservices/slim/api/\(api)")
        var request = URLRequest(url: URL(string: "https://my-plim.com/MyPlim/webservices/slim/api/\(api)")!)
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
    //Bloquear utilizador
    func bloquear(user:String){
        var request = URLRequest(url: URL(string: "https://my-plim.com/MyPlim/webservices/slim/api/bloqueadouser")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do{
            let dados = EntityBloqueado(username: MySingleton.shared.getUsername(), bloqueado: user)
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
//Sinch client configs ->
extension UsersTableViewController/*: SINClientDelegate*/ {
    //Create instance of sinch client
    /*func initSinchClient(withUserId userId: String?) {
        if client == nil {
            client = Sinch.client(withApplicationKey: SinchSingleton.shared.app_Key, applicationSecret: SinchSingleton.shared.appSecret, environmentHost: SinchSingleton.shared.host, userId: MySingleton.shared.getUsername())
            client?.delegate = self
            client?.setSupportCalling(true)
            client?.enableManagedPushNotifications()
            client?.start()
            client?.startListeningOnActiveConnection()
        }
    }
    //Delegate functions
    func clientDidStart(_ client: SINClient!) {
        print("Sinch client started successfully (version: \(Sinch.version() ?? "Error"))")
    }
    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("Sinch client error: \(error?.localizedDescription ?? "")")
    }*/
}
//Struct for the JSON return
struct Users: Decodable {
    let nome: String?
    let username: String?
    let id: String?
    let foto: String?
    let favorito: Bool?
    let idade:Int
}

struct RequestFormat: Decodable {
    let status: Bool
    let DATA: [Users]
}
