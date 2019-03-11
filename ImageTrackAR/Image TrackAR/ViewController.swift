//
//  ViewController.swift
//  Image TrackAR
//
//  Created by andrew@hwang on 2/17/19
//  Copyright © 2019 andrew. All rights reserved.
//

// Hello! Before you try out the app, please check the AR Resources in "assets.xcassets". Thanks!

import UIKit
import SceneKit
import ARKit
import AVFoundation
import SpriteKit
import CoreLocation
import Foundation
import Vision

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var lm:CLLocationManager!
    let locationManager = CLLocationManager()
    var landmarks = ["Hoover Tower": (37.427867, -122.166532),
                     "Memorial Church": (37.427145, -122.169947),
                     "The Oval": (37.430302, -122.169083),
                     "Gates Building": (37.430200, -122.172826),
                     "Arillaga Dining": (37.425551, -122.163896),
                     "AOERC": (37.426879, -122.177112),
                     "Bing Concert Hall": (37.432335, -122.165485)]
    
    var landmark_vectors = [String: (Double, Double)]()
    var landmark_screenlocations = [String: (Double, Double)]()
    
    var fieldofview = CGFloat()
    var current_heading = 0.0
    var realtime_heading = 0.0
    var scene_created = false
    var heading_received = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Set the view's delegate
        sceneView.delegate = self
        
        fieldofview = sceneView.pointOfView?.camera!.fieldOfView ?? -1
        
        
        // request location services and see that they allowed us to use their location.
        locationManager.requestWhenInUseAuthorization()
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            print("location services not authorized")
            return
        }
        if !CLLocationManager.locationServicesEnabled() {
            print("location services not availible")
            return
        }
        
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 5   // In meters.
        
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        //makes the code function properly
        guard let arImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        configuration.trackingImages = arImages
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.removeExistingAnchors])
    }
    
    //overrides the function
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        //sceneView.session.run(configuration, options: [.removeExistingAnchors])
    }
    
    //puts the func in function
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    
        guard anchor is ARImageAnchor else { return }
        
        // Container
        guard let container = sceneView.scene.rootNode.childNode(withName: "container", recursively: false) else { return }
        container.removeFromParentNode()
        node.addChildNode(container)
        container.isHidden = false
        
        // Video
        let videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4")!
        let videoPlayer = AVPlayer(url: videoURL)
        
        let videoScene = SKScene(size: CGSize(width: 720.0, height: 1280.0))
        
        let videoNode = SKVideoNode(avPlayer: videoPlayer)
        videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
        videoNode.size = videoScene.size
        videoNode.yScale = -1
        videoNode.play()
        
        videoScene.addChild(videoNode)
        
        guard let video = container.childNode(withName: "video", recursively: true) else { return }
        video.geometry?.firstMaterial?.diffuse.contents = videoScene
        
        // Animations
        guard let videoContainer = container.childNode(withName: "videoContainer", recursively: false) else { return }
        guard let text = container.childNode(withName: "text", recursively: false) else { return }
        //guard let textTwitter = container.childNode(withName: "textTwitter", recursively: false) else { return }
        
        videoContainer.runAction(SCNAction.sequence([SCNAction.wait(duration: 1.0), SCNAction.scale(to: 4.0, duration: 0.5)]))
        text.runAction(SCNAction.sequence([SCNAction.wait(duration: 1.5), SCNAction.scale(to: 0.01, duration: 0.5)]))
        //textTwitter.runAction(SCNAction.sequence([SCNAction.wait(duration: 2.0), SCNAction.scale(to: 0.006, duration: 0.5)]))
        
        // Particlez!!!
        let particle = SCNParticleSystem(named: "particle.scnp", inDirectory: nil)!
        let particleNode = SCNNode()
        
        container.addChildNode(particleNode)
        particleNode.addParticleSystem(particle)
    }
    
    // location locationManager
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
//        print(locations.last!)
        
        
        if !scene_created {
            if !heading_received {
                return
            }
            // Create a new scene
            let scene = SCNScene(named: "art.scnassets/ship.scn")!
            
            // Set the scene to the view
            sceneView.scene = scene
            
            scene_created = true
            current_heading = realtime_heading
//            print("heading: ", current_heading)
        }
            
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        
        let lastLocation = locations.last!
        let lastCoordinates = lastLocation.coordinate
        let current_location = (lastCoordinates.latitude, lastCoordinates.longitude)
        
        if lastLocation.speed > 3 {
            current_heading = realtime_heading
        }
    
        var distance_vectors = [String: (Double, Double)]()
        for (landmark, location) in landmarks {
            distance_vectors[landmark] = (location.0 - current_location.0, location.1 - current_location.1)
            let y = sin(distance_vectors[landmark]!.1 * Double.pi / 180) * cos(location.0 * Double.pi / 180)
            let x = cos(current_location.0 * Double.pi / 180)*sin(location.0 * Double.pi / 180) - sin(current_location.0 * Double.pi / 180)*cos(location.0 * Double.pi / 180)*cos(distance_vectors[landmark]!.1 * Double.pi / 180)
            let bearing = atan2(y, x) * 180 / Double.pi
            
            
            let R = 6371e3; // metres
            
            let a = sin(distance_vectors[landmark]!.0 * Double.pi / 360) * sin(distance_vectors[landmark]!.0 * Double.pi / 360) +
                cos(current_location.0 * Double.pi / 180) * cos(location.0 * Double.pi / 180) *
                sin(distance_vectors[landmark]!.1 * Double.pi / 360) * sin(distance_vectors[landmark]!.1 * Double.pi / 360)
            let c = 2 * atan2(sqrt(a), sqrt(1-a));
            
            let distance = R * c * 3.28084; // feet
            
            landmark_vectors[landmark] = (distance, bearing)
//            print(landmark, distance, bearing)
            
            let angle = (bearing - current_heading - 90)
            
            let xCoord = cos(angle * (Double.pi / 180))
            
            let yCoord = 0.0
            
            let zCoord = sin(angle * (Double.pi / 180))
            
//            print(landmark, angle, xCoord, zCoord)
            
            let scale = Float(min(max(0.0015, 0.8 / distance), 0.004))
            
            let text = SCNText(string: landmark + "\n" + String(Int(distance)) + " ft.", extrusionDepth: 1)
            let material = SCNMaterial()
            material.roughness.contents = UIColor.white
            text.materials = [material]
            let node = SCNNode()
            node.position = SCNVector3(x: Float(xCoord), y: Float(yCoord), z: Float(zCoord))
            node.scale = SCNVector3(x: scale, y: scale, z: scale)
            node.geometry = text
            node.constraints = [SCNBillboardConstraint()]
            sceneView.scene.rootNode.addChildNode(node)
            sceneView.autoenablesDefaultLighting = true
            
            let minVec = node.boundingBox.min
            let maxVec = node.boundingBox.max
            let bound = SCNVector3Make(maxVec.x - minVec.x,
                                       maxVec.y - minVec.y,
                                       maxVec.z - minVec.z);
            
            let plane = SCNPlane(width: CGFloat(bound.x + 10),
                                 height: CGFloat(bound.y + 10))
            plane.cornerRadius = 5
            plane.firstMaterial?.diffuse.contents = UIColor.red
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.position = SCNVector3(CGFloat( minVec.x) + CGFloat(bound.x) / 2 ,
                                            CGFloat( minVec.y) + CGFloat(bound.y) / 2,CGFloat(minVec.z - 0.01))
            
            node.addChildNode(planeNode)
//            let old_planeNode = planeNode
//
//            minVec = planeNode.boundingBox.min
//            maxVec = planeNode.boundingBox.max
//            bound = SCNVector3Make(maxVec.x - minVec.x,
//                                       maxVec.y - minVec.y,
//                                       maxVec.z - minVec.z);
//
//            plane = SCNPlane(width: CGFloat(bound.x + 3),
//                                 height: CGFloat(bound.y + 3))
//            plane.cornerRadius = 6.5
//            plane.firstMaterial?.diffuse.contents = UIColor.black
//
//            planeNode = SCNNode(geometry: plane)
//            planeNode.position = SCNVector3(CGFloat( minVec.x) + CGFloat(bound.x) / 2 ,
//                                            CGFloat( minVec.y) + CGFloat(bound.y) / 2,CGFloat(minVec.z - 0.10))
//
//            old_planeNode.addChildNode(planeNode)
//            planeNode.name = "text"
            
//            let labelNode = SKLabelNode(text: landmark)
//            labelNode.fontSize = 120
//            labelNode.position = CGPoint(x: xCoord,y: yCoord)
//            labelNode.zPosition = CGFloat(zCoord)
//            labelNode.fontColor = UIColor.cyan
//            videoScene.addChild(labelNode)
        }
        
//        let labelNode = SKLabelNode(text: "test")
//        labelNode.fontSize = 120
//        labelNode.position = CGPoint(x: 1,y: 1)
//        labelNode.zPosition = CGFloat(1)
//        labelNode.fontColor = UIColor.red
//        videoScene.addChild(labelNode)
    }
    
    // compass locationManager
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //        print(newHeading.trueHeading)
        realtime_heading = Double(Int(newHeading.trueHeading))
        heading_received = true
//        print(realtime_heading)
//        var currentViewRight = CGFloat(newHeading.trueHeading) + (fieldofview/2)
//        var currentViewLeft = CGFloat(newHeading.trueHeading) - (fieldofview/2)
//
//        let contains_zero = currentViewLeft < 0 || currentViewRight > 360
//
//        if currentViewRight > 360 { currentViewRight -= 360 }
//        if currentViewLeft < 0 { currentViewLeft += 360 }
//
//        print("current buildings in the view")
//        for (landmark, vector) in landmark_vectors {
//            if !contains_zero {
//                if vector.1 < Double(currentViewRight) && vector.1 > Double(currentViewLeft) {
//                    print(landmark, terminator: ": ")
//                    print(Int(vector.0), " ft away")
//                }
//            }
//            else {
//                if vector.1 < Double(currentViewRight) || vector.1 > Double(currentViewLeft) {
//                    print(landmark, terminator: ": ")
//                    print(Int(vector.0), " ft away")
//                }
//            }
//        }
//        print("")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
