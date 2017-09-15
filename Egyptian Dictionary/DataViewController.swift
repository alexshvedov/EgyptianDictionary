//
//  DataViewController.swift
//  Egyptian Dictionary
//
//  Created by Alexey Shvedov on 16.08.17.
//  Copyright © 2017 AShvedov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI

protocol DataViewControllerDelegate {
    func shuffle()
}

class DataViewController: UIViewController {

    @IBOutlet weak var dataLabel: UILabel!
    var dataObject: NSDictionary = [:]
    var translationIndex: Int = 0
    
    /*var imageReference0:StorageReference!
    var imageReference1:StorageReference!
    var placeholderImage0:UIImage!
    var placeholderImage1:UIImage!
     */
    var localURL0:URL!
    var localURL1:URL!
 
    var delegate:DataViewControllerDelegate?

    @IBOutlet weak var contentImage: UIImageView!

    @IBAction func button_touch(_ sender: UIButton) {
        self.translationIndex = ((self.translationIndex == 0) ? 1 : 0 )
        //self.contentImage.image = UIImage(named: "\(dataObject)-\(self.translationIndex).jpg")
        
        if (self.translationIndex == 0) {
            //self.contentImage.sd_setImage(with: self.imageReference0, placeholderImage: self.placeholderImage0)
            self.contentImage.image = UIImage(named: localURL0.relativePath)
        } else {
            //self.contentImage.sd_setImage(with: self.imageReference1, placeholderImage: self.placeholderImage1)
            self.contentImage.image = UIImage(named: localURL1.relativePath)
        }
    }
    @IBAction func shuffle_button(_ sender: Any) {
        delegate?.shuffle()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /*
        let storage = Storage.storage()
        
        self.imageReference0 = storage.reference(withPath: (self.dataObject["ImageHiddenFileName"] as? String)!)
        self.imageReference1 = storage.reference(withPath: (self.dataObject["ImageShownFileName"] as? String)!)
        
        self.placeholderImage0 = UIImage(named: (self.dataObject["ImageHiddenFileName"] as? String)!)
        self.placeholderImage1 = UIImage(named: (self.dataObject["ImageShownFileName"] as? String)!)
         */
        self.localURL0 = try! FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent((self.dataObject["ImageHiddenFileName"] as? String)!)
        self.localURL1 = try! FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent((self.dataObject["ImageShownFileName"] as? String)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dataLabel.text = self.dataObject["cardIndex"] as? String
        
        //self.contentImage.sd_setImage(with: self.imageReference0, placeholderImage: self.placeholderImage0)
        
        
        
        self.contentImage.image = UIImage(named: localURL0.relativePath)
    }


}

