//
//  NFTCollectionViewController.swift
//  NFTWallet
//
//  Created by Shreyas Sai on 13/11/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

private let reuseIdentifier = "NFTCell"
private let sectionInsets = UIEdgeInsets(
    top: 20.0,
    left: 15.0,
    bottom: 50.0,
    right: 15.0)
private let itemsPerRow: CGFloat = 2

class NFTCollectionViewController: UICollectionViewController {
    
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    var selectedIndex:Int = 0
    var selectedImage:UIImage?
    
    var nfts:[[String : Any]] = []
    
    let alert = UIAlertController(title: nil, message: "Loading NFTs...", preferredStyle: .alert)
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button3 = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadTapped))
        
        self.navigationItem.rightBarButtonItem  = button3
        
        getNFT()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.nfts.count
    }
    
    @IBAction func reloadTapped(_ sender: UIButton) {
        getNFT()
    }
    
    func getNFT(){
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
                self.db.collection("nft").whereField("publicKey", isEqualTo: publicKey).getDocuments() { response, error in
                    if(error != nil){
                        print(error?.localizedDescription)
                    } else {
                        
                        
                        DispatchQueue.main.async {
                            self.nfts.removeAll()
                            for i in response!.documents {
                                self.nfts.append(i.data())
                            }
                            self.collectionView?.reloadData()
                            self.alert.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                
            }
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NFTCollectionViewCell
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.lightGray.cgColor
        
        cell.layer.backgroundColor = UIColor.white.cgColor
        cell.layer.borderColor = UIColor.black.cgColor
        //cell.titleLabel.frame.width = cell.frame.width - 10
        cell.titleLabel.widthAnchor.constraint(equalToConstant: cell.frame.width - 20).isActive = true
        
        cell.titleLabel.text = nfts[indexPath.row]["title"] as? String
        cell.imageView.widthAnchor.constraint(equalToConstant: cell.frame.width).isActive = true
        cell.imageView.heightAnchor.constraint(equalToConstant: cell.frame.height*0.6).isActive = true
        
        let url = URL(string: nfts[indexPath.row]["imageUrl"] as! String)
        let data = try? Data(contentsOf: url!)
        cell.imageView.image = UIImage(data: data!)
        cell.layer.masksToBounds = true
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedIndex = indexPath.row
        let cell = collectionView.cellForItem(at: indexPath) as! NFTCollectionViewCell
        self.selectedImage = cell.imageView.image
        performSegue(withIdentifier: "toNFT", sender: self)
        
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is NFTCheckViewController {
            let vc = segue.destination as? NFTCheckViewController
            vc?.nft = nfts[selectedIndex]
            vc?.image = selectedImage
        }
    }
}

extension NFTCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem*1.125)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return sectionInsets.left
    }
}


