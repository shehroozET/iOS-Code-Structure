//
//  logoutController.swift
//  Snabum
//
//  Created by mac on 06/10/2025.
//
import UIKit

class logoutController : UIViewController {
    
    var onApplyFilters: (( _ filterType : Bool?) -> Void)?
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    @IBAction func noBtnLogout(_ sender: Any) {
        onApplyFilters?(false)
        self.dismiss(animated: true)
    }
    
    @IBAction func yesBtnLogout(_ sender: Any) {
        self.dismiss(animated: true) { 
            self.onApplyFilters?(true)
        }
    }
    
}
