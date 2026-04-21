//
//  CreateAlbumVC.swift
//  Snabum
//
//  Created by mac on 07/10/2025.
//

import UIKit
import ProgressHUD

class CreateAlbumVC : UIViewController {
    
    var onCreateAlbum: (( _ albumID : Int? , _ albumName : String?) -> Void)?
    
    
    @IBOutlet weak var tf_albumName: UITextField!
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    @IBAction func createAlbum(_ sender: Any) {
        
        if let name = tf_albumName.text?.trimmingCharacters(in: [" "]) {
            if name.isEmpty{
                showToastAlert(message: "Username must not be empty")
                return
            }
            createAlbum(name: name)
        } else {
            showToastAlert(message: "Username must not be empty")
        }
        
    }
    func createAlbum(name : String){
        
        AuthService.createAlbum(albumName: name){ result in
            switch result {
            case .success(let (response, _)):
                if let albumID = response.data?.id{
                    self.dismiss(animated: true) {
                        self.onCreateAlbum!(albumID , name)
                    }
                    
                }
                ProgressHUD.dismiss()
            case .failure(let error):
                
                print("Error:", error.localizedDescription)
                
                switch error {
                case .backendError(let data):
                    do {
                        let decoded = try JSONDecoder().decode(RegistrationResponse.self, from: data)
                        if let messages = decoded.errors?.fullMessages {
                            ProgressHUD.failed(messages.joined(separator: "\n"))
                        } else {
                            ProgressHUD.failed("Something went wrong.")
                        }
                    } catch {
                        ProgressHUD.failed("Failed to parse error.")
                    }
                    
                default:
                    ProgressHUD.failed(error.localizedDescription)
                }
                
            }
        }
    }
   
}
