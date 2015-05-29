//
//  DetailViewController.swift
//  Shoes
//
//  Created by Taylor Romero on 5/1/15.
//  Copyright (c) 2015 Spruce. All rights reserved.
//

import UIKit
import MBAlertView

class DetailViewController: UIViewController {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblVendor: UILabel!
    @IBOutlet weak var lblSizes: UILabel!


    var meta : [Dictionary<String, AnyObject>]!
    var delegate : ViewController!
    
    var shoe : NSDictionary? {
        didSet {
            
            meta = [];

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblName.alpha = 0
        self.lblVendor.alpha = 0
        self.lblSizes.alpha = 0

        //self.view.backgroundColor = UIColor.grayColor()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didClickExit(sender: AnyObject) {
        
        self.delegate.removeDetails()
        
    }
    
    func labelFor( size: String,  quantity: Int) -> UIView {
        
        let width = CGFloat(140);
        let height = CGFloat(50)
        let wrapper = UIView(frame: CGRectMake(self.view.frameWidth / 2 - width / 2 + 9, 0, width, height))
//        wrapper.backgroundColor = UIColor.grayColor()
        
        var font = UIFont(name: "hellogoodbye", size: 45)
        
        let lblSize = UILabel(frame: CGRectMake(0, 0, width * 0.4, wrapper.frameHeight))
        lblSize.text = size
        wrapper.addSubview(lblSize)
        lblSize.font = font
    
        
        let lblX = UILabel(frame: CGRectMake(lblSize.frameRight, 0, width * 0.2, height))
        lblX.text = "x"
        lblX.font = UIFont(name: "hellogoodbye", size: 30)
        
        wrapper.addSubview(lblX)
        
        let lblQuantity = UILabel(frame: CGRectMake(lblX.frameRight, 0, width * 0.4, height))
        lblQuantity.font = font
        lblQuantity.text = "\(quantity)"
        
        wrapper.addSubview(lblQuantity)
    
        
        return wrapper;
        
        
    }
    
    func refresh() {
        
        self.lblName.text = shoe?["title"] as? String
//        self.lblVendor.text = shoe?["vendor"] as? String
        let vendor = shoe!["vendor"] as! String
        let color = shoe!["color"] as! String
        let price = shoe!["price"] as! String
        self.lblVendor.text = "\(vendor) - \(color) - $\(price)"

        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            self.lblName.alpha = 1
            
        }) { (success) -> Void in
            
            
        }
        
        UIView.animateWithDuration(0.5, delay: 0.05, options: nil, animations: { () -> Void in
            self.lblVendor.alpha = 1
        }) { (success) -> Void in
            
            
        }
        
        UIView.animateWithDuration(0.5, delay: 0.1, options: nil, animations: { () -> Void in
            self.lblSizes.alpha = 1
            }) { (success) -> Void in
                
                
        }
        
     
        
        var top : CGFloat = self.lblSizes.frameBottom + 10
        var delay = 0.15
        var index = 0;
        
        if let sizes = shoe?["sizes"] as? [AnyObject] {
            
            for size in sizes {
                
                var lbl = self.labelFor(size[0] as! String, quantity: size[1] as! Int)
                lbl.alpha = 0
                lbl.frameY = top
                lbl.tag = index
                
                meta.append([
                    "size": size[0] as! String,
                    "id": size[2] as! Int
                ]);
                
                index += 1

                top += lbl.frameHeight + 5

                let tap = UITapGestureRecognizer(target: self, action: Selector("didTapSize:"))
                lbl.addGestureRecognizer(tap)
                
                self.view.addSubview(lbl)
                
                UIView.animateWithDuration(0.5, delay: delay, options: nil, animations: { () -> Void in
                    
                    lbl.alpha = 1
                    
                }, completion: { (success) -> Void in
                    
                    
                })
                
                delay += 0.05

                
            }
            
        }
        
        
        

    }
    
    
    func didTapSize(recognizer: UITapGestureRecognizer) {
        
        if let tag = recognizer.view?.tag {
            
            let data = meta[tag] as Dictionary<String, AnyObject>
            let size = data["size"] as! String
            let id = data["id"] as! Int
            
            var alert = MBAlertView.alertWithBody("Would you like someone to bring you a size \(size) to try on?", cancelTitle: "Nah", cancelBlock: { () -> Void in
                
                
            })
            
            alert.addButtonWithText("Yes!", type: MBAlertViewItemTypePositive, block: { () -> Void in
                
                self.delegate.sendShoeText(id)
                
                let a = MBAlertView.alertWithBody("It will be done!", cancelTitle: "Cool", cancelBlock: { () -> Void in
                    
                    self.delegate.removeDetails()
                    
                })
                
                a.addToDisplayQueue()
                
            })
            alert.addToDisplayQueue()

            
            
            
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
