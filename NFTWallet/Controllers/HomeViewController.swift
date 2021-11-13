//
//  HomeViewController.swift
//  NFTWallet
//
//  Created by Shreyas Sai on 11/11/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Web3

class HomeViewController: UIViewController {
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    
    
    var balance = "0 ETH"
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var checkNFTButton: UIButton!
    
    let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button1 = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        let button2 = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), style: .plain, target: self, action: #selector(settingTapped))
        let button3 = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadTapped))
        
        self.navigationItem.rightBarButtonItems  = [button1, button3]
        self.navigationItem.leftBarButtonItem = button2
        
        checkNFTButton.backgroundColor = .clear
        checkNFTButton.layer.cornerRadius = 5
        checkNFTButton.layer.borderWidth = 1
        checkNFTButton.layer.borderColor = UIColor.black.cgColor
        getBalance()
    }
    
    func getBalance(){
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        self.db.collection("users").document(self.currentUser?.uid ?? "").getDocument(){ response, error in
            if(error != nil){
                print(error?.localizedDescription)
            } else {
                let publicKey = response?.data()!["publicKey"] as! String
                do{
                    try? web3.eth.getBalance(address: try EthereumAddress(hex: publicKey, eip55: true), block: try .string("latest")){ response in
                        
                        let bal = Double(response.result!.quantity)/pow(Double(10), 18)
                        self.balance = String(bal) + " ETH"
                        DispatchQueue.main.async {
                            self.balanceLabel.text = self.balance
                            self.alert.dismiss(animated: true, completion: nil)
                        }
                        
                    }
                } catch {
                    print("Error occured")
                }
                
            }
            
        }
    }
    
    @IBAction func addTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toCreate", sender: self)
    }
    @IBAction func settingTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toSettings", sender: self)
    }
    @IBAction func reloadTapped(_ sender: UIButton) {
        getBalance()
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
