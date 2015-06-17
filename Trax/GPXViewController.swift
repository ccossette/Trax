//
//  ViewController.swift
//  Trax
//
//  Created by Carlo Cossette on 2015-06-15.
//  Copyright (c) 2015 C Cossette. All rights reserved.
//

import UIKit
import MapKit

class GPXViewController: UIViewController, MKMapViewDelegate
{

    @IBOutlet weak var mapView: MKMapView!
    {
        didSet
        {
            mapView.mapType = .Satellite
            mapView.delegate = self
        }
    }
    
    var gpxURL: NSURL?
    {
        didSet
        {
            clearWaypoints()
            if let url = gpxURL
            {
                GPX.parse(url) {
                 if let gpx = $0
                 {
                    self.handleWaypoints(gpx.waypoints)
                    }
                }
            }
        }
    }
    
    private func clearWaypoints()
    {
        if mapView?.annotations != nil { mapView.removeAnnotations (mapView.annotations as! [MKAnnotation]) }
    }
    
    private func handleWaypoints (waypoints: [GPX.Waypoint])
    {
        mapView.addAnnotations(waypoints)
        mapView.showAnnotations(waypoints, animated: true)
    }
    
    @IBAction func addWaypoint(sender: UILongPressGestureRecognizer)
    {
        if sender.state == UIGestureRecognizerState.Began
        {
            let coordinate = mapView.convertPoint(sender.locationInView(mapView), toCoordinateFromView: mapView)
            let waypoint = EditableWaypoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            waypoint.name = "Dropped"
            mapView.addAnnotation(waypoint)
        }
    }
    
    
    // MARK: - Constants
    
    private struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "waypoint"
        static let ShowImageSegue = "Show Image"
        static let EditWaypointSegue = "Edit Waypoint"
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!
    {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationViewReuseIdentifier)
        if view == nil
        {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view.canShowCallout = true
        } else
        {
            view.annotation = annotation
        }
        
        view.draggable = annotation is EditableWaypoint
        
        view.leftCalloutAccessoryView = nil
        view.rightCalloutAccessoryView = nil
        if let waypoint = annotation as? GPX.Waypoint
        {
            if waypoint.thumbnailURL != nil
            {
                view.leftCalloutAccessoryView = UIButton (frame: Constants.LeftCalloutFrame)
            }
            
            if annotation is EditableWaypoint
            {
                view.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
            }
        }
        
        return view
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if let waypoint = view.annotation as? GPX.Waypoint
        {
            if let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton
            {
                if let imageData = NSData(contentsOfURL: waypoint.thumbnailURL!) // this blocks main thread
                {
                    if let image = UIImage(data: imageData)
                    {
                        thumbnailImageButton.setImage(image, forState: .Normal)
                    }
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!)
    {
        if (control as? UIButton)?.buttonType == UIButtonType.DetailDisclosure
        {
            mapView.deselectAnnotation(view.annotation, animated: false)
            performSegueWithIdentifier(Constants.EditWaypointSegue, sender: view)
    
        } else if let waypoint = view.annotation as? GPX.Waypoint
        {
            if waypoint.imageURL != nil
            {
                performSegueWithIdentifier(Constants.ShowImageSegue, sender: view)
            }
        }
        
    }
    
    @IBOutlet weak var textView: UITextView!
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.ShowImageSegue
        {
            if let waypoint =  (sender as? MKAnnotationView)?.annotation as? GPX.Waypoint
            {
                if let ivc = segue.destinationViewController as? ImageViewController
                {
                    ivc.imageURL = waypoint.imageURL
                    ivc.title = waypoint.name
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        let appDelegate = UIApplication.sharedApplication().delegate
        
        center.addObserverForName(GPXURL.Notification, object: appDelegate, queue: queue)
            {
                notification in
                if let url = notification?.userInfo?[GPXURL.Key] as? NSURL
                {
                    self.gpxURL = url
                }
            
            
            }
        gpxURL = NSURL (string: "http://cs193p.stanford.edu/Vacation.gpx")
    }
}

