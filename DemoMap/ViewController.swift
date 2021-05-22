//
//  ViewController.swift
//  DemoMap
//
//  Created by Yashwant Jangid on 22/05/21.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var viewMap: MKMapView!
    @IBOutlet weak var lbl_Current: UITextField!
    {
        didSet {
            lbl_Current.delegate = self
            lbl_Current.returnKeyType = .done
        }
    }
    
    @IBOutlet weak var lbl_Destination: UITextField!
    {
        didSet {
            lbl_Destination.delegate = self
            lbl_Destination.returnKeyType = .done
        }
    }
    
    var loc_coordinate_Current = CLLocationCoordinate2D()
    var loc_coordinate_Destina = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewMap.delegate = self
    }
    
    @IBAction func actionManager(_ sender: UIButton) {
        
        if sender.tag == 1
        {
            viewMap.removeAnnotations(viewMap.annotations)
            for poll in viewMap.overlays {
                
                viewMap.removeOverlay(poll)
            }
            
            if lbl_Current.text != nil && lbl_Destination.text != nil
            {
            self.showRouteOnMap(pickupCoordinate: self.loc_coordinate_Current, destinationCoordinate: self.loc_coordinate_Destina)
            }
            else
            {
                showAlert("Requered...!!", message: "Both Current and destination location is requered")
            }
        }
        else if sender.tag == 2
        {
            for poll in viewMap.overlays {
                
                viewMap.removeOverlay(poll)
            }
            viewMap.removeAnnotations(viewMap.annotations)
        }
    }
    
    @IBAction func segmentedControlAction(sender: UISegmentedControl!) {

        if sender.selectedSegmentIndex == 0{

            viewMap.mapType = MKMapType.standard
        }
        else if sender.selectedSegmentIndex == 1{

            viewMap.mapType = MKMapType.satellite
        }
        else if sender.selectedSegmentIndex == 2{

            viewMap.mapType = MKMapType.hybrid
        }
    }
}

//MARK:- CLLocationManagerDelegate Methods
extension ViewController: MKMapViewDelegate, CLLocationManagerDelegate
{
    // MARK:- showRouteOnMap
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {

        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)

        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let sourceAnnotation = MKPointAnnotation()

        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }

        let destinationAnnotation = MKPointAnnotation()

        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }

        self.viewMap.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )

        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile

        // Calculate the direction
        let directions = MKDirections(request: directionRequest)

        directions.calculate {
            (response, error) -> Void in

            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }

                return
            }

            let route = response.routes[0]

            self.viewMap.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)

            let rect = route.polyline.boundingMapRect
            self.viewMap.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }

    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        let renderer = MKPolylineRenderer(overlay: overlay)

        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)

        renderer.lineWidth = 5.0

        return renderer
    }
}

//MARK:- UITextFieldDelegate Methods
extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: textField)
        perform(#selector(self.reload(_:)), with: textField, afterDelay: 0.75)

        return true
    }

    @objc func reload(_ textField: UITextField) {
        
        guard let query = textField.text, query.trimmingCharacters(in: .whitespaces) != "" else {
            print("nothing to search")
            return
        }
        if textField == lbl_Current
        {
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(textField.text!) { (placemarks, error) in
                guard let placemarks = placemarks else {
                    // handle no location found
                    self.showAlert("Oops. error", message: "Cordinate not found on your location")
                    return
                }
                
                print(placemarks)
                if let LC = placemarks.first?.location?.coordinate
                {
                    self.loc_coordinate_Current = LC
                }
            }
        }
        else
        {
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(textField.text!) { (placemarks, error) in
                guard let placemarks = placemarks else {
                    // handle no location found
                    self.showAlert("Oops. error", message: "Cordinate not found on your location")
                    return
                }
                
                print(placemarks)
                if let LC = placemarks.first?.location?.coordinate
                {
                    self.loc_coordinate_Destina = LC
                }
            }
        }
    }
}

extension UIViewController
{
    func showAlert(_ title:String, message:String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            // Code in this block will trigger when OK button tapped.
            print("Ok button tapped");
            
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
}
