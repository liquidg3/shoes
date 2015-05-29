//
//  ViewController.swift
//  Shoes
//
//  Created by Taylor Romero on 4/30/15.
//  Copyright (c) 2015 Spruce. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift
import iCarousel
import MBAlertView

class ViewController: UIViewController, iCarouselDelegate {
    
    var socket : SocketIOClient?
    var shoes : [NSDictionary]?
    var imageCache = [ String: UIImage]()
    var vcDetails : DetailViewController!

    @IBOutlet var carousel: iCarousel!
 

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.carousel.type = iCarouselTypeCoverFlow2


        // Do any additional setup after loading the view, typically from a nib.
        if (socket === nil) {
            
            socket = SocketIOClient(socketURL: "https://appointments.spruce.me")
//            socket = SocketIOClient(socketURL: "https://taysmacbookpro.local:8080")
            socket?.connect()
            socket?.on("connect", callback: { (results, ack) -> Void in
                
                println("connected!");
                self.refreshShoes()
                
            })
            
            socket?.on("error", callback: { (results, ack) -> Void in
                
                println("error \(results)")
                
            })
            
        }
        
    }
    
    func refreshShoes() {
        
        MBHUDView.hudWithBody("Loading Shoes...", type: MBAlertViewHUDTypeActivityIndicator, hidesAfter: 4, show: true)
        
        
       let cb = socket!.emitWithAck("products", "30721080")
        
        cb(timeout: 10) { (response) -> Void in
            
            if let results = response {
                
                if results.count == 1 {
                    
                    let alert = UIAlertView(title: "ERROR", message: "Bad Results", delegate: nil, cancelButtonTitle: "Bummer")
                        alert.show()
                    return
                }

                if let data = results[1] as? NSDictionary {

                    
                    if let _shoes = data["results"] as? [NSDictionary] {
                        

                        self.shoes = self.cleanupShoeResults(_shoes);
                        self.carousel.reloadData()

                        
                        
                    }
                    
                }
                
            }

           
            
        }

        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue) | Int(UIInterfaceOrientationMask.LandscapeLeft.rawValue) | Int(UIInterfaceOrientationMask.LandscapeRight.rawValue)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    func cleanupShoeResults(shoes: [NSDictionary]) -> [NSDictionary] {
        
        var results = [NSDictionary]()
        
        func variantById(shoe: NSDictionary, id: Int) -> NSDictionary? {
            
            var variant : NSDictionary?;
            
            for _variant in shoe["variants"] as! [NSDictionary] {
                
                var _id = _variant["id"] as! Int
                
                if _id == id {
                    variant = _variant
                    break;
                }
                
            }
            
            return variant;
            
            
        }
        
//        println("shoes\(shoes)")
        
        for shoe in shoes {
            
            //only bring in shoes that have images
            let images = shoe["images"] as! [NSDictionary]

            
            for image in images  {
                
                var variants = image["variant_ids"] as! [Int]
                var src = image["src"] as! String
                var title = shoe["title"] as! String
                var sizes : [ [AnyObject] ] = []
                
                
                var newShoe : [String: AnyObject] = [
                    "title": title,
                    "vendor": shoe["vendor"]!,
                    "picture": src,
                    "color": "",
                    "price": "",
                    "sizes": sizes
                ]
                
                
//                println("image src for \(title): \(src)")
                
                //sort variants by option2
                
                
                for variant in variants {
                
                    if let data = variantById(shoe, variant) {
                    
                        var size        = data["option2"] as! String
                        var color       = data["option1"] as! String
                        var price       = data["price"] as! String
                        var quantity    = data["inventory_quantity"] as! Int
                        
                        sizes.append([size, quantity, variant])
                        newShoe["color"] = color
                        newShoe["sizes"] = sizes
                        newShoe["price"] = price
                    }
                
                    
                
                }
                
                
                results.append(newShoe)
                
            }
      
            
            
        }
        
//        println("---")
        
        return results;
        
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //delegate methods
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        if let shoes = self.shoes {
            return shoes.count
        }
        return 0
    }
    
    func carousel(carousel: iCarousel!, viewForItemAtIndex index: UInt, reusingView view: UIView?) -> UIView! {
        
        var newView : UIImageView!
        
        if view == nil {
            
            newView = UIImageView(frame: CGRectMake(0, 0, 600, 600))
            newView.contentMode = UIViewContentMode.ScaleAspectFit
//            newView.backgroundColor = UIColor.blackColor()
            
        } else {
            newView = view as! UIImageView
        }
        
        var shoes = self.shoes! as [AnyObject]
        
        if let shoe = shoes[Int(index)] as? NSDictionary {
            
            var pic = shoe["picture"] as! String;
            var title = shoe["title"] as! String;
            var image :UIImage!
            
            if let i = self.imageCache[pic] as UIImage? {
                image = i
            } else {
                image =  UIImage(data: NSData(contentsOfURL: NSURL(string: pic)!)!)
                self.imageCache[pic] = image
            }
            

            newView.image = image
            

        }
 
        
        return newView;

        
    }
    
    func carouselItemWidth( carousel : iCarousel) -> CGFloat {
        return CGFloat(600)
    }
    
    func carousel(carousel: iCarousel!, didSelectItemAtIndex index: Int) {
        
        self.removeDetails()
        
        let shoe = self.shoes?[index]
        

        self.showDetails(shoe!)
       
        
//        println("shoe \(shoe)")
        
        
        
        
    }
    
    func carousel(carousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
      
    
        switch(option.value) {
        case iCarouselOptionVisibleItems.value:
            return 6
        case iCarouselOptionWrap.value:
            return 0;
        default:
            return value
            
        }
        
    }
    
    func showDetails( shoe: NSDictionary ) {
        
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("details") as! DetailViewController
        self.vcDetails = vc
        self.vcDetails.view.alpha = 0
        self.vcDetails.delegate = self
        self.view.addSubview(vc.view!)
        self.vcDetails.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5)
        vc.shoe = shoe

        
//        UIView.animateWithDuration(0.5, delay: 0, options: <#UIViewAnimationOptions#>, animations: <#() -> Void##() -> Void#>, completion: <#((Bool) -> Void)?##(Bool) -> Void#>)
        
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.vcDetails.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)
        }) { (success) -> Void in
            
            
        }

        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.vcDetails.view.alpha = 1
            self.carousel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);

        }) { (finished) -> Void in
            self.vcDetails.refresh()

        }
        
    }
    
    func removeDetails() {
        
        

        self.vcDetails?.view?.removeFromSuperview()
        self.vcDetails = nil;
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.carousel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            }) { (finished) -> Void in

                
        }
    }
    
    func sendShoeText( id : Int) {
        
//        println("shoe id \(id)")
        self.socket?.emit("send-shoe-text", id)
        
        
    }
    
    
   
//    - (CGFloat)carouselItemWidth:(iCarousel *)carousel {
//    return 800;
//    }


}

