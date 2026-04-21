//
//  SharePopUpController.swift
//  Snabum
//
//  Created by mac on 18/02/2026.
//

import UIKit

class SharePopUpController: UIViewController {

    var onShareAlbum: (( _ canEdit : Bool?) -> Void)?
    
    @IBOutlet weak var iv_userSharedTo: UIImageView!
    @IBOutlet weak var lbl_nameShareTo: UILabel!
    @IBOutlet weak var lbl_switch: UILabel!
    @IBOutlet weak var switch_edit_permissions: UISwitch!
    @IBOutlet weak var lbl_title: UILabel!
    var AlbumName : String? = nil
    var userToShareName : String? = nil
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    func setupUI(){
        self.lbl_title.text = "Share"
        if let name = AlbumName
        {
            self.lbl_title.text = "Share : \(name)"
        }
        
        
        self.iv_userSharedTo.image = self.createInitialImage(name: self.userToShareName ?? "A")
    
        
        if let userName = self.userToShareName{
            self.lbl_nameShareTo.text = userName
        }
        
    }

    @IBAction func shareAlbum(_ sender: Any) {
        print(self.switch_edit_permissions.isOn)
        self.onShareAlbum!(switch_edit_permissions.isOn)
        self.dismiss(animated: false)
    }
   

}
