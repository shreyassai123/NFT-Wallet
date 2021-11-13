//
//  CreateNFTViewController.swift
//  NFTWallet
//
//  Created by Shreyas Sai on 11/11/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Web3
import Web3PromiseKit

class CreateNFTViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var artistField: UITextField!
    var imagePicker: ImagePicker!
    
    let alert = UIAlertController(title: nil, message: "Minting NFT...", preferredStyle: .alert)
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height+40)
        
    }
    
    
    @IBAction func uploadPressed(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    func uploadImageToIPFS(image: UIImage, artist:String, title:String, description: String) {
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        getBase64Image(image: image) { base64Image in
            let boundary = "Boundary-\(UUID().uuidString)"
            
            var request = URLRequest(url: URL(string: "https://ipfs.infura.io:5001/api/v0/add")!)
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            var body = ""
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"image\""
            body += "\r\n\r\n\(base64Image ?? "")\r\n"
            body += "--\(boundary)--\r\n"
            let postData = body.data(using: .utf8)
            
            request.httpBody = postData
            
            // ...
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    self.alert.dismiss(animated: true, completion: nil)
                    print("failed with error: \(error)")
                    return
                }
                guard let response = response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                          print("server error")
                          self.alert.dismiss(animated: true, completion: nil)
                          self.showAlert(title: "Server Error", message: "An error has occurred.")
                          return
                      }
                if let mimeType = response.mimeType, mimeType == "application/json", let data = data, let dataString = String(data: data, encoding: .utf8) {
                    let parsedResult: [String: AnyObject]
                    do {
                        parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
                        let imageUrl = "https://ipfs.infura.io/ipfs/"+(parsedResult["Hash"] as? String ?? "")
                        print(imageUrl)
                        
                        let nft = NFTModel(artist: artist, title: title, description: description, url: imageUrl)
                        
                        
                        let jsonEncoder = JSONEncoder()
                        let jsonData = try jsonEncoder.encode(nft)
                        let json = String(data: jsonData, encoding: String.Encoding.utf8)
                        
                        let boundary = "Boundary-\(UUID().uuidString)"
                        var request = URLRequest(url: URL(string: "https://ipfs.infura.io:5001/api/v0/add")!)
                        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                        request.httpMethod = "POST"
                        var body = ""
                        body += "--\(boundary)\r\n"
                        body += "Content-Disposition:form-data; name=\"json\""
                        body += "\r\n\r\n\(json ?? "")\r\n"
                        body += "--\(boundary)--\r\n"
                        let postData = body.data(using: .utf8)
                        
                        request.httpBody = postData
                        
                        
                        URLSession.shared.dataTask(with: request) { data, response, error in
                            if let error = error {
                                print("failed with error: \(error)")
                                self.alert.dismiss(animated: true, completion: nil)
                                self.showAlert(title: "Error", message: "An error has occurred.")
                                return
                            }
                            guard let response = response as? HTTPURLResponse,
                                  (200...299).contains(response.statusCode) else {
                                      print("server error")
                                      self.alert.dismiss(animated: true, completion: nil)
                                      self.showAlert(title: "Server Error", message: "An error has occurred.")
                                      return
                                  }
                            if let mimeType = response.mimeType, mimeType == "application/json", let data = data, let dataString = String(data: data, encoding: .utf8) {
                                
                                let parsedResult: [String: AnyObject]
                                do {
                                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
                                    let nftUrl = "https://ipfs.infura.io/ipfs/"+(parsedResult["Hash"] as? String ?? "")
                                    
                                    
                                    if let data = image.pngData() {
                                        FirebaseStorageManager().uploadImageData(data: data, serverFileName: NSUUID().uuidString+".png") { (isSuccess, url) in
                                            self.db.collection("users").document(self.currentUser?.uid ?? "").getDocument(){ response, error in
                                                if(error != nil){
                                                    print(error?.localizedDescription)
                                                } else {
                                                    let publicKey = response?.data()!["publicKey"] as! String
                                                    let key = response?.data()!["key"] as! String
                                                    let contract = try! web3.eth.Contract(json: contractJsonABI, abiKey: nil, address: contractAddress)
                                                    let myPrivateKey = try? EthereumPrivateKey(hexPrivateKey: key)
                                                    
                                                    do{
                                                        web3.eth.getTransactionCount(address: myPrivateKey!.address, block: try .string("latest")) { response in
                                                            let nonce = response.result
                                                            
                                                            guard let transaction = contract["createToken"]?(nftUrl).createTransaction(nonce: nonce, from: myPrivateKey!.address, value: 0, gas: 1500000, gasPrice: EthereumQuantity(quantity: 200.gwei)) else {
                                                                print("error")
                                                                self.alert.dismiss(animated: true, completion: nil)
                                                                self.showAlert(title: "Error", message: "An error has occurred.")
                                                                return
                                                            }
                                                            
                                                            let signedTx = try! transaction.signX(with: myPrivateKey!)
                                                            firstly {
                                                                
                                                                web3.eth.sendRawTransaction(transaction: signedTx)
                                                                
                                                            }.done { txHash in
                                                                self.db.collection("nft").addDocument(data: [
                                                                    "publicKey": publicKey,
                                                                    "title": title,
                                                                    "description": description,
                                                                    "artist": artist,
                                                                    "imageUrl": url,
                                                                    "uri": nftUrl
                                                                ])
                                                                { error in
                                                                    if(error == nil){
                                                                        self.navigationController?.popViewController(animated: true)
                                                                        self.alert.dismiss(animated: true, completion: nil)
                                                                    } else {
                                                                        self.alert.dismiss(animated: true, completion: nil)
                                                                        self.showAlert(title: "Error", message: "An error has occurred.")
                                                                    }
                                                                }
                                                                
                                                            }.catch { error in
                                                                print(error)
                                                                self.alert.dismiss(animated: true, completion: nil)
                                                                self.showAlert(title: "Transaction Error", message: error.localizedDescription)
                                                            }
                                                        }
                                                    } catch {
                                                        self.alert.dismiss(animated: true, completion: nil)
                                                        self.showAlert(title: "Error", message: "An error has occurred.")
                                                    }
                                                    
                                                    
                                                }
                                                
                                            }
                                        }
                                    }
                                    
                                    
                                    
                                } catch {
                                    print("Error has occured")
                                    self.showAlert(title: "Error", message: "An error has occurred.")
                                }
                                
                            }
                        }.resume()
                    } catch {
                        print("Error has occured")
                        self.showAlert(title: "Error", message: "An error has occurred.")
                    }
                }
            }.resume()
        }
    }
    
    func getBase64Image(image: UIImage, complete: @escaping (String?) -> ()) {
        DispatchQueue.main.async {
            let imageData = image.pngData()
            let base64Image = imageData?.base64EncodedString(options: .lineLength64Characters)
            complete(base64Image)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    @IBAction func mintPressed(_ sender: UIButton) {
        if(titleField.text != "" && descriptionField.text != "" && artistField.text != "" && imageView.image != nil){
            
            let alert = UIAlertController(title: "Are you sure you want to mint the NFT?", message: "This will incure gas charges.", preferredStyle: UIAlertController.Style.actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
                self.uploadImageToIPFS(image: self.imageView.image!, artist: self.artistField.text!, title: self.titleField.text!, description: self.descriptionField.text!)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Invalid Data", message: "Enter all fields", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension CreateNFTViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        self.imageView.image = image
        self.imageView.backgroundColor = .white
    }
    
}

extension EthereumTransaction {
    func signX(with privateKey: EthereumPrivateKey, chainId: Int = chainId) throws -> EthereumSignedTransaction {
        guard let nonce = nonce, let gasPrice = gasPrice, let gasLimit = gas, let value = value else {
            throw EthereumSignedTransaction.Error.transactionInvalid
        }
        
        let rlp = RLPItem(
            nonce: nonce,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            to: to,
            data: data,
            chainId: UInt(chainId)
        )
        
        let rawRlp = try RLPEncoder().encode(rlp)
        
        guard let signedTransaction = try? privateKey.sign(message: rawRlp) else { throw EthereumSignedTransaction.Error.transactionInvalid }
        
        let v: BigUInt
        if chainId == 0 {
            v = BigUInt(signedTransaction.v) + BigUInt(27)
        } else {
            let sigV = BigUInt(signedTransaction.v)
            let big27 = BigUInt(27)
            let chainIdCalc = (BigUInt(chainId) * BigUInt(2) + BigUInt(8))
            v = sigV + big27 + chainIdCalc
        }
        
        return EthereumSignedTransaction(
            nonce: nonce,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            to: to,
            value: value,
            data: data,
            v: EthereumQuantity(quantity: v),
            r: EthereumQuantity(quantity: BigUInt(signedTransaction.r)),
            s: EthereumQuantity(quantity: BigUInt(signedTransaction.s)),
            chainId: EthereumQuantity(quantity: BigUInt(chainId))
        )
    }
    
}

extension RLPItem {
    init(
        nonce: EthereumQuantity,
        gasPrice: EthereumQuantity,
        gasLimit: EthereumQuantity,
        to: EthereumAddress?,
        data: EthereumData,
        chainId: UInt
    ) {
        self = .array(
            .bigUInt(nonce.quantity),
            .bigUInt(gasPrice.quantity),
            .bigUInt(gasLimit.quantity),
            .bytes(to?.rawAddress ?? Bytes()),
            .string(""),
            .bytes(data.bytes),
            .init(integerLiteral: chainId),
            .init(integerLiteral: 0),
            .init(integerLiteral: 0)
        )
    }
}


