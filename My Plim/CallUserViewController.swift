//
//  CallUserViewController.swift
//  My Plim
//
//  Created by João Costa on 11/04/2019.
//  Copyright © 2019 ipvc.estg. All rights reserved.
//

import UIKit
import MediaPlayer


class CallUserViewController: UIViewController/*, SINCallDelegate */{
    @IBOutlet weak open var remoteUsername: UILabel!
    @IBOutlet weak open var callStateLabel: UILabel!
    @IBOutlet weak open var answerButton: UIButton!
    @IBOutlet weak open var declineButton: UIButton!
    @IBOutlet weak open var endCallButton: UIButton!
    @IBOutlet weak open var remoteVideoView: UIView!
    @IBOutlet weak open var localVideoView: UIView!
    
    open var durationTimer: Timer!
    
    //open var call: SINCall!
    
    //
    var userToCall: String = ""
    var fromUser: String = ""
    //var client: SINClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("Calling -> \(userToCall) from \(fromUser)")
        //
        //_client.call()?.callUserVideo(withId: userToCall)
        //call = client?.call().callUserVideo(withId: userToCall)
        
        
    }
    //
    override func viewWillAppear(_ animated: Bool) {
        //navigationItem.hidesBackButton = true
        navigationItem.titleView = MySingleton.shared.getImageTitle()
        let backItem = UIBarButtonItem()
        backItem.title = "Voltar"
        navigationItem.backBarButtonItem = backItem
    }
    
/*    func videoController() -> SINVideoController? {
        return client?.videoController()
    }
*/
}
