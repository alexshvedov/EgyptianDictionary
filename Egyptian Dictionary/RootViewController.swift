//
//  RootViewController.swift
//  Egyptian Dictionary
//
//  Created by Alexey Shvedov on 16.08.17.
//  Copyright © 2017 AShvedov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI

class RootViewController: UIViewController, UIPageViewControllerDelegate, DataViewControllerDelegate {

    var pageViewController: UIPageViewController?
    
    var jsonCardsData = [NSDictionary]()
    
    var downloadCounter: Int = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //ASH: Download json data
        self.loadJSONData()
        
        
    }
    func configurePageViewController() {
        // Configure the page view controller and add it as a child view controller.
        self.pageViewController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        self.pageViewController!.delegate = self
        
        let startingViewController: DataViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        
        //ASH:
        startingViewController.delegate = self
        
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        
        self.pageViewController!.dataSource = self.modelController
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = self.view.bounds
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
        }
        self.pageViewController!.view.frame = pageViewRect
        
        self.pageViewController!.didMove(toParentViewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController(jsonData: self.jsonCardsData)
        }
        return _modelController!
    }

    var _modelController: ModelController? = nil

    // MARK: - UIPageViewController delegate methods

    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        if (orientation == .portrait) || (orientation == .portraitUpsideDown) || (UIDevice.current.userInterfaceIdiom == .phone) {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to true, so set it to false here.
            let currentViewController = self.pageViewController!.viewControllers![0] as! DataViewController
            let viewControllers = [currentViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })

            self.pageViewController!.isDoubleSided = false
            return .min
        }

        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = self.pageViewController!.viewControllers![0] as! DataViewController
        
        
        var viewControllers: [UIViewController]

        let indexOfCurrentViewController = self.modelController.indexOfViewController(currentViewController)
        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
            let nextViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerAfter: currentViewController) as! DataViewController
            
            viewControllers = [currentViewController, nextViewController]
        } else {
            let previousViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerBefore: currentViewController) as! DataViewController
            
            viewControllers = [previousViewController, currentViewController]
        }
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })

        return .mid
    }
    
    //ASH: added pageViewController delegate for delegate for dataViewController
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        //print("completed: \(completed) [0] label: \(String(describing: (pageViewController.viewControllers![0] as! DataViewController).dataLabel.text))")
        (pageViewController.viewControllers![0] as! DataViewController).delegate = self
    }

    func shuffle() {
        //print("RootViewController shuffle")
        self.modelController.shuffle()
        
        let startingViewController: DataViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        
        //ASH:
        startingViewController.delegate = self
        
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })
        
        //self.pageViewController!.dataSource = self.modelController
        
        //self.addChildViewController(self.pageViewController!)
        //self.view.addSubview(self.pageViewController!.view)
        
        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        /*var pageViewRect = self.view.bounds
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
        }
        self.pageViewController!.view.frame = pageViewRect
        */
        //self.pageViewController!.didMove(toParentViewController: self)
    }
    
    //ASH: Loading JSON data
    func loadJSONData() {
        let jsonLocalURL = try! FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("data.json")
        
        
        
        var previousVersion = -1
        
        // get current saved json version
        do {
            let data = try Data(contentsOf: jsonLocalURL)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
            
            previousVersion = (json?["Version"] as? Int) ?? -1
            self.jsonCardsData = json?["Cards"] as? [NSDictionary] ?? []
            
            
            // configure with saved data before loading new json
            self.configurePageViewController()
            
        } catch let error as NSError {
            print("Got previously saved json loading error: \(error)")
        }
        
        let storage = Storage.storage()
        
        //TODO: check if it already downloaded
        
        //let jsonReference = storage.reference(withPath: "dataTest.json")
        let jsonReference = storage.reference(withPath: "data.json")
        /*let jsonLocalURL = try! FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("data.json")*/
        
        
        _ = jsonReference.write(toFile: jsonLocalURL) {
            url, error in
            if let error = error {
                print("JSON download error occured: \(error)")
            } else {
                print("json local file returned url: \(String(describing: url))")
                self.parceJSONData(with: url!, previousVersion: previousVersion)
            }
        }
        /*downloadTask.observe(StorageTaskStatus.progress, handler: {_ in
            print("json load progress")
        })*/
        
        /*jsonReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("JSON download error occured: \(error)")
            } else {
                // Data for "images/island.jpg" is returned
                //print("json local file returned: \(String(describing: data))")
                self.parceJSONData(with: data!)
            }
        }*/
    }
    
    func parceJSONData(with url: URL, previousVersion: Int) {
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
            
            
            // TODO: reload images if version is changed
            self.jsonCardsData = json?["Cards"] as? [NSDictionary] ?? []
            let currentVersion = (json?["Version"] as? Int) ?? -1
            print("previousVersion: \(previousVersion), currentVersion: \(currentVersion)")
            if (currentVersion != previousVersion) {
                self.downloadAllImages()
            }/* else {
                self.configurePageViewController()
            }*/
        } catch let error as NSError {
            print(error)
        }
    }
    
    func downloadAllImages() {
        
        let storage = Storage.storage()
        /*for i in 0..<self.jsonCardsData.count {
            let imageReference0 = storage.reference(withPath: (self.jsonCardsData[i]["ImageHiddenFileName"] as? String)!)
            let imageReference1 = storage.reference(withPath: (self.jsonCardsData[i]["ImageShownFileName"] as? String)!)
            
            let placeholderImage0 = UIImage(named: (self.jsonCardsData[i]["ImageHiddenFileName"] as? String)!)
            let placeholderImage1 = UIImage(named: (self.jsonCardsData[i]["ImageShownFileName"] as? String)!)
            
            let contentImage0 = UIImageView()
            contentImage0.sd_setImage(with: imageReference0, placeholderImage: placeholderImage0)
            let contentImage1 = UIImageView()
            contentImage1.sd_setImage(with: imageReference1, placeholderImage: placeholderImage1)
        }*/
        self.downloadCounter = self.jsonCardsData.count * 2
        for i in 0..<self.jsonCardsData.count {
                let imageReference0 = storage.reference(withPath: (self.jsonCardsData[i]["ImageHiddenFileName"] as? String)!)
            let imageReference1 = storage.reference(withPath: (self.jsonCardsData[i]["ImageShownFileName"] as? String)!)
            
            let localURL0 = try! FileManager.default
                .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent((self.jsonCardsData[i]["ImageHiddenFileName"] as? String)!)
            let localURL1 = try! FileManager.default
                .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent((self.jsonCardsData[i]["ImageShownFileName"] as? String)!)
            
            //let localURL0 = URL(string: (self.jsonCardsData[i]["ImageHiddenFileName"] as? String)!)
            //let localURL1 = URL(string: (self.jsonCardsData[i]["ImageShownFileName"] as? String)!)
            
            //let downloadTask0 = imageReference0.write(toFile: localURL0)
            //let downloadTask1 = imageReference1.write(toFile: localURL1)
            _ = imageReference0.write(toFile: localURL0, completion: {
                url, error in
                if let error = error {
                    print("download image error: \(error)")
                } else {
                    //print("image saved: \(String(describing: url))")
                }
                self.downloadCounter -= 1
                if (self.downloadCounter <= 0) {
                    print("new images downloaded")
                    self._modelController = nil
                    self.configurePageViewController()
                }
            })
            _ = imageReference1.write(toFile: localURL1, completion: {
                url, error in
                if let error = error {
                    print("download image error: \(error)")
                } else {
                    //print("image saved: \(String(describing: url))")
                }
                self.downloadCounter -= 1
                if (self.downloadCounter <= 0) {
                    print("new images downloaded")
                    self._modelController = nil
                    self.configurePageViewController()
                }
            })
        }
    }
    

}

