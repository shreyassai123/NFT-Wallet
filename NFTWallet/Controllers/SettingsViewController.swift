//
//  SettingsViewController.swift
//  NFTWallet
//
//  Created by Shreyas Sai on 13/11/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn



class SettingsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    let currentUser = Auth.auth().currentUser
    var publicAddress:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: currentUser?.photoURL?.absoluteString ?? "" )
        let data = try? Data(contentsOf: url!)
        imageView.image = UIImage(data: data!)
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        
        nameLabel.text = currentUser?.displayName
        emailLabel.text = currentUser?.email
        
        Firestore.firestore().collection("users").document(self.currentUser?.uid ?? "").getDocument(){ response, error in
            if(error != nil){
                print(error?.localizedDescription)
            } else {
                self.publicAddress = response?.data()!["publicKey"] as! String
                do{
                    DispatchQueue.main.async {
                        self.addressLabel.text = self.publicAddress
                    }
                    
                }
                
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        
    }
    
    @IBAction func copyPressed(_ sender: UIButton) {
        if(publicAddress != ""){
            UIPasteboard.general.string = publicAddress
        }
    }
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signOut()
        do {
            try Auth.auth().signOut()
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            
        } catch let error as NSError {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
}
