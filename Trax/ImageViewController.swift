//
//  ImageViewController.swift
//  Cassini
//
//  Created by Carlo Cossette on 2015-06-07.
//  Copyright (c) 2015 C Cossette. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate
{
    var imageURL: NSURL?
    {
        didSet
        {
            image = nil
            if view.window != nil
            {
            fetchImage()
            }
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    private func fetchImage()
    {
        if let url = imageURL
        {
            spinner?.startAnimating()
            let qos = Int(QOS_CLASS_USER_INITIATED.value)
            dispatch_async(dispatch_get_global_queue(qos, 0))
            {
                () -> Void in
                let imageData = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue())
                    {
                    if url == self.imageURL
                    {
                        if imageData != nil
                        {
                            self.image = UIImage(data: imageData!)
                        
                        } else
                            {
                                self.image = nil
                            }
                    } 
                }
            }
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    {
        didSet
        {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
            
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    private var imageView = UIImageView()
    
    private var image: UIImage?
    {
        get { return imageView.image }
        set
        {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            spinner?.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
            }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil
        {
            fetchImage()
        }
    }
    
}
