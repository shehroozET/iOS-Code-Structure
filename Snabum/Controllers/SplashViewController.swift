//
//  ViewController.swift
//  Snabum
//
//  Created by mac on 29/07/2025.
//

import UIKit

class ViewController: UIViewController {

    var tokenManager = AppManager.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppConfig.shared.environment = .staging
    }
    override func viewWillAppear(_ animated : Bool){
        super.viewWillAppear(animated)
        startTimer()
    }
    
    func startTimer(){
        let main = UIStoryboard(name: "Main", bundle: .none)
        let navcontroller = main.instantiateViewController(withIdentifier: "LoginViewController")
        DispatchQueue.main.asyncAfter(deadline: .now()+4){ [self] in
            let dashboard : UIStoryboard? = UIStoryboard(name: "Main", bundle: .none)
            if let token = tokenManager.token, let uid = tokenManager.uid , let client = tokenManager.client{
                if let controller = dashboard?.instantiateViewController(withIdentifier: "RoundedTabBarController")
                {
                    controller.modalPresentationStyle = .fullScreen
                    AppLogger.general.info("token \(token) ")
                    AppLogger.general.info("uid \(uid) ")
                    AppLogger.general.info("client \(client) ")
                    self.present(controller, animated: true)
                }
                
            }
                self.navigationController?.pushViewController(navcontroller, animated: true)
            
        }
    }


}

