//
//  CreateFolder.swift
//  Snabum
//
//  Created by mac on 07/10/2025.
//

import UIKit
import ProgressHUD

class CreateFolderVC : UIViewController {
    
    var onCreateFolder: (( _ folderID : Int? , _ folderName : String?) -> Void)?
   
    @IBOutlet weak var tf_description: UITextField!
    @IBOutlet weak var tf_folderName: UITextField!
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    @IBAction func createFolder(_ sender: Any) {
        createFolder(name : tf_folderName.text ?? "" , description : tf_description.text ?? "")
//        onCreateFolder!(0,"folder name")
    }
    func createFolder( name : String , description : String){
        
        AuthService.createFolder(folderName: name, description: description){ result in
            switch result {
            case .success(let (response, _)):
                if let albumID = response.data?.id{
                    self.dismiss(animated: true) {
                        self.onCreateFolder!(albumID , name)
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
