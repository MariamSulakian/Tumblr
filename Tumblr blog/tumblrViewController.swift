//
//  tumblrViewController.swift
//  Tumblr blog
//
//  Created by Mariam Sulakian on 6/16/16.
//  Copyright © 2016 Mariam Sulakian. All rights reserved.
//

import UIKit
import AFNetworking

class tumblrViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var posts: [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        downloadPosts(false, refreshControl: nil)
        
        tableView.rowHeight = 240
        
    }
    
    func downloadPosts(refreshing: Bool, refreshControl: UIRefreshControl?) {
        let url = NSURL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
                                                                      completionHandler: { (data, response, error) in
                                                                        if let data = data {
                                                                            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                                                                                data, options:[]) as? NSDictionary {
                                                                                print("responseDictionary: \(responseDictionary)")
                                                                                
                                                                                // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                                                                                // This is how we get the 'response' field
                                                                                let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                                                                                
                                                                                // This is where you will store the returned array of posts in your posts property
                                                                                self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                                                                                
                                                                                if (refreshing) {
                                                                                    refreshControl!.endRefreshing()
                                                                                }
                                                                                
                                                                                self.tableView.reloadData()
                                                                            }
                                                                        }
        });
        task.resume()
    }
    
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        tableView.reloadData()
        downloadPosts(true, refreshControl: refreshControl)
        refreshControl.endRefreshing()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell") as! PhotoCell
        
        let post = posts[indexPath.row]
        if let photos = post.valueForKeyPath("photos") as? [NSDictionary] {
            let imageUrlString = photos[0].valueForKeyPath("original_size.url") as? String

            if let imageUrl = NSURL(string: imageUrlString!) {
                cell.photoView.setImageWithURL(imageUrl)

            } else {
                // NSURL(string: imageUrlString!) is nil. Good thing we didn't try to unwrap it!
            }
        } else {
            // photos is nil. Good thing we didn't try to unwrap it!
        }

        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var vc = segue.destinationViewController as! PhotoDetailsViewController
        var indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
        
        let post = posts[indexPath!.row]
        if let photos = post.valueForKeyPath("photos") as? [NSDictionary] {
            let imageUrlString = photos[0].valueForKeyPath("original_size.url") as? String
            
            if let imageUrl = NSURL(string: imageUrlString!) {
                vc.photoUrl = imageUrl
                
            } else {
                // NSURL(string: imageUrlString!) is nil. Good thing we didn't try to unwrap it!
            }
        } else {
            // photos is nil. Good thing we didn't try to unwrap it!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
    }
    
    var isMoreDataLoading = false
    
    func loadMoreData() {
        
        let url = NSURL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV&offset=20")
        let request = NSURLRequest(URL: url!)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
                                                                      completionHandler: { (data, response, error) in
                                                                        
                                                                        // Update flag
                                                                        self.isMoreDataLoading = false
                                                                        if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                                                                            data!, options:[]) as? NSDictionary {
                                                                            let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                                                                            
                                                                            // This is where you will store the returned array of posts in your posts property
                                                                            self.posts.appendContentsOf( responseFieldDictionary["posts"] as! [NSDictionary])
                                                                        }
                                                                        
                                                                        
                                                                        print(self.posts.count)
                                                                        // Reload the tableView now that there is new data
                                                                        self.tableView.reloadData()
        });
        task.resume()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                
                isMoreDataLoading = true
                print("request")
                // Code to load more results
                loadMoreData()
            }
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
