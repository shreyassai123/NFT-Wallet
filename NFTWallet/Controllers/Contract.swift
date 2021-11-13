import Web3
import Web3PromiseKit
import Web3ContractABI
import FirebaseFirestore
import FirebaseAuth


func mintNFT(uri: String)  {
    
    let currentUser = Auth.auth().currentUser
    
    
    Firestore.firestore().collection("users").document(currentUser?.uid ?? "").getDocument(){ response, error in
        if(error != nil){
            print(error?.localizedDescription ?? "error has occurred")
        } else {
            
            let publicKey = response?.data()!["publicKey"] as! String
            let key = response?.data()!["key"] as! String
            let contractAddress = try? EthereumAddress(hex: "0xD4111c45A54a56Cb325C21547f4963B1eebda8Ec", eip55: true)
            let contract = try! web3.eth.Contract(json: contractJsonABI, abiKey: nil, address: contractAddress)
            let myPrivateKey = try? EthereumPrivateKey(hexPrivateKey: key)
            
            do{
                web3.eth.getTransactionCount(address: myPrivateKey!.address, block: try .string("latest")) { response in
                    let nonce = response.result
                    
                    guard let transaction = contract["createToken"]?(uri).createTransaction(nonce: nonce, from: myPrivateKey!.address, value: 0, gas: 1500000, gasPrice: EthereumQuantity(quantity: 200.gwei)) else {
                        return
                    }
                    
                    let signedTx = try! transaction.signX(with: myPrivateKey!)
                    firstly {
                        
                        web3.eth.sendRawTransaction(transaction: signedTx)
                        
                    }.done { txHash in
                    }.catch { error in
                        print(error)
                    }
                }
            } catch {
                print("error has occurred")
            }
        }
        
    }
    
}

