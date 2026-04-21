//
//  NotificationsViewController.swift
//  Snabum
//
//  Created by mac on 09/10/2025.
//

import UIKit

class NotificationsViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated : Bool){
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell") as! NotificationTableViewCell
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath : IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension NotificationsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
