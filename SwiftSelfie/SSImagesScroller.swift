//
//  SSImagesScroller.swift
//  SwiftSelfie
//
//  Created by Justin Wong on 11/14/15.
//  Copyright (c) 2015 TEST. All rights reserved.
//

import Foundation
import UIKit

//Protocol for communicating between class that communicates to instagram, and presenting class, aka self
protocol SSSessionDelegate {
    func acquiredImageURLs(arrImageURLs : NSArray)
    func acquiredImage(data : NSData, index: Int)
}

class SSImagesScroller: UICollectionViewController, SSSessionDelegate {
    
    //Variables for holding image data and flag for when downloading instagram media data
    var arrImageTuple : [(url: String, igImage: UIImage)] = []
    var isGettingImages : Bool!
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Get instance of instagram web service handler, toggle getting images, and get initial images to display
        SSInstagramSession.sharedInstance.delegate = self
        isGettingImages = true
        SSInstagramSession.sharedInstance.getImageURLs()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImageTuple.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //Dequeue a cell and set its image to nil to be updated with new image
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellIdentifier", forIndexPath: indexPath) as! SSImagesCell
        cell.instagramImage.image = nil
        
        //Get values from current tuple of interest, and act accordingly
        let (url, image) = arrImageTuple[indexPath.row]
        if image.size.width == 0 {
            SSInstagramSession.sharedInstance.getImage(url, index: indexPath.row)
        }
        else {
            cell.instagramImage.image = image
        }
        
        return cell
    }
    
    func collectionView( collectionView: UICollectionView,  layout collectionViewLayout:UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        //Distance to edge of collectionview.
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    }
    
    func collectionView( collectionView: UICollectionView, layout collectionViewLayout:UICollectionViewLayout,  sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        //Set our cells sizes according to constants.
        if (indexPath.row % 3) == 0 {
            return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.width)
        }
        else {
            return CGSizeMake( (collectionView.bounds.size.width/2) - 5, (collectionView.bounds.size.width/2) - 5)
        }
    }
    
    //Session delegate methods
    func acquiredImageURLs(arrImageURLs : NSArray) {
        
        //Untoggle getting images, and fast enumerate through values
        isGettingImages = false
        
        for imageValues in arrImageURLs {
            
            //Drill into necessary dictionary, and get either a low or high resolution image url
            let imgVal = imageValues as! NSDictionary
            let images = imgVal.objectForKey("images") as! NSDictionary
            var url = ""
            
            if (arrImageTuple.count % 3) == 0 {
                url = (images.objectForKey("low_resolution") as! NSDictionary).objectForKey("url") as! String
            }
            else {
                url = (images.objectForKey("thumbnail") as! NSDictionary).objectForKey("url") as! String
            }
            
            
            //Create a tuple of attained URL, and dummy image to add to array
            let newTuple = (url: url,  igImage: UIImage());
            arrImageTuple.append( newTuple )
        }
        
        //Call main thread to reload collection view
        dispatch_async(dispatch_get_main_queue(), {
            let colView = self.collectionView!
            colView.reloadData()
        })
    }
    
    func acquiredImage(data : NSData, index: Int) {
        dispatch_async(dispatch_get_main_queue(), {
            //Update tuple in array of data to hold newly downloaded image
            var aTuple = self.arrImageTuple[index]
            aTuple.igImage = UIImage(data: data)!
            let newTuple = ( aTuple.url, UIImage(data: data)!)
            self.arrImageTuple[index] = newTuple
            
            //Call main thread to reload necessary item
            self.collectionView?.reloadItemsAtIndexPaths( [ NSIndexPath(forRow: index, inSection: 0) ] )
        })
    }
    
    override func scrollViewDidScroll( scrollView: UIScrollView ){
        
        //Buffer next batch of data when three screen sizes away from the end of the scroll view
        let contentOffset = collectionView?.contentOffset.y
        let contentSize = collectionView?.contentSize.height
        let frameHeight = collectionView?.frame.size.height
        if contentOffset >= contentSize! - (frameHeight!*3) && !isGettingImages {
            //Toggle buffering boolean and get more images
            isGettingImages = true;
            SSInstagramSession.sharedInstance.getImageURLs()
        }
    }
    
    //Hide status bar
     override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}