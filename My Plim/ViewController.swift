//
//  ViewController.swift
//  My Plim
//
//  Created by João Costa on 28/02/2019.
//  Copyright © 2019 ipvc.estg. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    //Variables
    var go = false
    //
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    //
    //MARK: Properties
    @IBOutlet weak var lblInsertCredentials: UILabel!
    @IBOutlet weak var inputTxtUserName: UITextField!
    @IBOutlet weak var inputTxtPassword: UITextField!
    @IBOutlet weak var lblLoginWarnings: UILabel!
    //Buttons
    @IBOutlet weak var btnLogIn: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    
    //MARK: Ciclo_Vida
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //
        inputTxtUserName.delegate = self as UITextFieldDelegate
        inputTxtPassword.delegate = self as UITextFieldDelegate
        //
        btnLogIn.setTitle(NSLocalizedString("login.loginButton", comment: ""), for: .normal)
        btnSignUp.setTitle(NSLocalizedString("login.signupButton", comment: ""), for: .normal)
        self.lblInsertCredentials.text = NSLocalizedString("login.insertCredentialsLabel", comment: "")
        //Check if is logged in
        if isLoggedIn(){
            MySingleton.shared.setUsername(username: UserDefaults.standard.value(forKey: "userName") as! String)
            print("I'm already logged as \(MySingleton.shared.getUsername())")
            self.go = true
            self.performSegue(withIdentifier: "gotoHomePage", sender: self.btnLogIn)
        }else{
            print("I've to log in first")
        }
        //TO Delete
        inputTxtUserName.text = "pedro"
        inputTxtPassword.text = "123456"
    }
    //
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Set navigation bar buttom
        navigationItem.title = NSLocalizedString("login.welcomeMessage", comment: "")
        var moreInfoButton = UIButton(type: .system)
        //moreInfoButton = CGRect(x: 0, y: 0, width: 20, height: 20)
        moreInfoButton.setImage(UIImage(named: "information")?.withRenderingMode(.alwaysOriginal), for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreInfoButton)
        moreInfoButton.addTarget(self, action: #selector(ViewController.showMoreInfo), for: .touchUpInside)
        
    }
    @objc func showMoreInfo() {
        performSegue(withIdentifier: "showMoreInfoSegue", sender: Any?.self)
    }
    //MARK: Actions
    @IBAction func clickButtonLogin(_ sender: Any) {
        run_login()
        //self.performSegue(withIdentifier: "gotoHomePage", sender: self.btnLogIn)
    }
    
    @IBAction func clickButtonSignUP(_ sender: Any) {
        self.performSegue(withIdentifier: "gotoSignUp", sender: self.btnSignUp)
    }
    //
    func checkFieldsRequired() -> Bool {
        if inputTxtUserName.text == "" {
            inputTxtUserName.becomeFirstResponder()
            lblLoginWarnings.text = NSLocalizedString("login.usernameMissing", comment: "")
            return false
        }else
            if inputTxtPassword.text == "" {
                inputTxtPassword.becomeFirstResponder()
                lblLoginWarnings.text = NSLocalizedString("login.passwordMissing", comment: "")
                return false
        }
        return true
    }
    //Call login webservice
    func GET_Login() {
        //Call webservice and check login
        //check if username and password match in the database
        //
        let userName = inputTxtUserName.text
        let pass = inputTxtPassword.text
        //the exclamation mark is a sign you give to the compiler telling that you are sure the variables aren't nil
        let urlString = "https://my-plim.com/MyPlim/webservices/slim/api/loginuser/" + userName! + "/"+pass!
        print(urlString)
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data,response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do{
                let response = try JSONDecoder().decode(EntityReturnLogin.self, from: data)
                print("Data:\(data)")
                let jsonBodyString = String(data: data, encoding: .utf8)
                print("JSON String : ", jsonBodyString!)
                DispatchQueue.main.async {
                    //check the status of the json response
                    //if status is true then run the Segue
                    if response.status {
                        MySingleton.shared.setUsername(username: userName ?? "Ups on login")
                        self.saveLoginStatusData()
                        self.go = true
                        self.activityIndicator.stopAnimating()
                        //performSegue = true
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "gotoHomePage", sender: self.btnLogIn)
                        }
                    } else {
                        self.lblLoginWarnings.text = NSLocalizedString("login.wrongCredentials", comment: "")
                        //performSegue = false
                    }
                }
            }catch let jsonError{
                print(jsonError)
            }
            }.resume()
        //return performSegue
    }
    //
    func run_login(){
        startActivityAnimation()
        if checkFieldsRequired() {
            GET_Login()
        }
    }
    //MARK: UITextFieldDelegate
    //the next method is called when the return button is clicked in the keyboard
    //makes the inputPassword has the current focused field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //the next line commented is used to hide the keyboard when return key is pressed
        //textField.resignFirstResponder()
        if inputTxtPassword.isEditing {
            run_login()
            //self.performSegue(withIdentifier: "gotoHomePage", sender: self.btnLogIn)
            inputTxtPassword.endEditing(true)
        }
        if inputTxtUserName.isEditing {
            inputTxtPassword.becomeFirstResponder()
        }
        return true;
    }
    //This method checks if the segue is clear to be performed
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "gotoHomePage" {
            if(go){
                return true
            }
        }
        return false
    }
    //Unwind method
    @IBAction func unwindToLogin(_ sender: UIStoryboardSegue){ self.go = false }
    //This methos can be used in others ViewControllers when a activity bar is required --> Just copy and paste and finally call it
    func startActivityAnimation(){
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.color = UIColor.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    //
    private func saveLoginStatusData(){
        UserDefaults.standard.set(MySingleton.shared.getUsername(), forKey: "userName")
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.synchronize()
        
    }
    //
    fileprivate func isLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
}

