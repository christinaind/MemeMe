//
//  SentMemesDetailScene.swift
//  MemeMeV1
//
//  Created by Ramaiah  Indudhara on 8/31/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import Foundation
import UIKit

// MARK: SentMemesDetailViewController

// This class is used to provide the info for a specific meme when clicked on in the table view or collection view
class SentMemesDetailViewController: UIViewController {
    
    // MARK: Properties
    
    var meme = Meme()
    
    // MARK: Outlets
    
    @IBOutlet weak var imageView: UIImageView!
   
    @IBOutlet weak var editButton: UIButton!
    
    // MARK: Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        self.imageView!.image = meme.memedImage
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
}
