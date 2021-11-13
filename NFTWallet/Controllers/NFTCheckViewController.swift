//
//  NFTCheckViewController.swift
//  NFTWallet
//
//  Created by Shreyas Sai on 13/11/21.
//

import UIKit

class NFTCheckViewController: UIViewController {
    
    var nft:[String:Any] = [:]
    var image:UIImage?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = nft["title"] as? String
        descriptionLabel.text = nft["description"] as? String
        artistLabel.text = nft["artist"] as? String
        tokenLabel.text = nft["uri"] as? String
        imageView.image = image
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height+40)
    }

    @IBAction func copyPressed(_ sender: UIButton) {
        UIPasteboard.general.string = nft["uri"] as? String
    }
}
