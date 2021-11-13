//
//  ViewController.swift
//  NFTWallet
//
//  Created by Shreyas Sai on 11/11/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import Web3
import Geth
import BlockChainKit


class ViewController: UIViewController, GIDSignInDelegate {
    @IBOutlet weak var googleButton: UIButton!
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let auth = user.authentication else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        Auth.auth().signIn(with: credentials) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Login Successful.")
                
                let currentUser = Auth.auth().currentUser
                let d = Firestore.firestore().collection("users").document(currentUser?.uid ?? "")
                d.getDocument(){ response, error in
                    
                    if(response!.exists){
                        self.performSegue(withIdentifier: "toHome", sender:  self)
                    } else {
                        let mnemonic = Mnemonic.create()
                        let seed = Mnemonic.createSeed(mnemonic).toHexString()
                        let node = HDNode(seed: Data(seed.utf8))
                        let BIP32RootKey = node.ethPrivateKey
                        let privateKey = try! EthereumPrivateKey(hexPrivateKey: BIP32RootKey)
                        
                        let db = Firestore.firestore()
                        db.collection("users").document(currentUser?.uid ?? "").setData(["mnemonic": mnemonic, "key": BIP32RootKey, "publicKey": privateKey.publicKey.address.hex(eip55: true), "uid": currentUser?.uid])
                        d.getDocument(){ response, error in
                            if(error != nil || response!.exists) {
                                print("error has occurred")
                            } else {
                                self.performSegue(withIdentifier: "toHome", sender: self)
                            }
                        }
                    }
                    
                }
                
                
                
                
                
                
                
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        googleButton.backgroundColor = .clear
        googleButton.layer.cornerRadius = 5
        googleButton.layer.borderWidth = 1
        googleButton.layer.borderColor = UIColor.black.cgColor
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        
        
        
    }
    
    
    @IBAction func googleSignInPressed(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signIn()
        
        
    }
    
    func checkDocument(collection: String, document: String)-> Bool{
        let db = Firestore.firestore()
        let docRef = db.collection(collection).document(document)
        var check:Bool = false;
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                _ = document.data().map(String.init(describing:)) ?? "nil"
                check = true
            } else {
                check  = false
            }
        }
        return check
    }
    
}

