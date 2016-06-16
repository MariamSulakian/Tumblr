//
//  PhotoDetailsViewController.swift
//  Tumblr blog
//
//  Created by Mariam Sulakian on 6/16/16.
//  Copyright © 2016 Mariam Sulakian. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    
    @IBOutlet weak var photoView: UIImageView!
    var photoUrl: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoView.setImageWithURL(photoUrl!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
   
    @IBAction func tap(sender: UITapGestureRecognizer) {
        print("hello")
        performSegueWithIdentifier("zoom", sender: self)
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
