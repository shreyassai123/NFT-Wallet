# NFT Wallet
NFT Wallet is an open source NFT Minting app made entirely on Swift. It uses Firebase to manage the backend and the [ERC-721](https://ethereum.org/en/developers/docs/standards/tokens/erc-721/) smart contract is hosted on the [Ropsten testnet](https://ropsten.etherscan.io/).

The contract Address is ```0xD4111c45A54a56Cb325C21547f4963B1eebda8Ec```

A custom chain can be used instead of ropsten by changing the RPC URL and Chain ID in the ```Constants.swift``` file.


# Installation Steps

Frist, go to the directory through the terminal and do ```pod init``` followed by ```pod install```

Then, add Firebase to the project by following: https://firebase.google.com/docs/ios/setup
Make sure Google Sign In, and Firestore are enabled on your Firebase Project.
Then take the ```REVERSED_CLIENT_ID``` key from the ```GoogleService-Info.plist``` that was downloaded while setting up firebase and add it by expanding **URL Types** under the **Info** tab from the **Targets** section in Xcode.

Finally, get an [Infura](https://infura.io/) API Key and add it in the ```Constants.swift``` file.

![xcode_infotab_url_type_values](https://user-images.githubusercontent.com/28078556/141632037-da85591c-3f92-431d-9409-64c68f50f1c6.png)

Once all these steps are completed, you can go ahead and run the app!

# Screenshots

Home                       |  Minting                  |  Viewing Minted NFTs
:-------------------------:|:-------------------------:|:-------------------------
![Home](https://user-images.githubusercontent.com/28078556/141640515-1423d4e2-44bb-4e34-a9ae-4e70a21edb02.png)  |  ![Minting](https://user-images.githubusercontent.com/28078556/141640756-aaa3a436-f27a-4384-b70d-f5dba79cbd4c.png)  | ![Viewing](https://user-images.githubusercontent.com/28078556/141641008-46720c4d-db82-42b8-8a59-2027787c6876.png)
