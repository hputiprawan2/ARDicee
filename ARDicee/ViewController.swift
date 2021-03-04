//
//  ViewController.swift
//  ARDicee
//
//  Created by Hanna Putiprawan on 3/3/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
//        let sphere = SCNSphere(radius: 0.2)
//
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
//        sphere.materials = [material]
//
//        let node = SCNNode()
//        // x=0 center, y=0.1 raise up, z=-0.5 far away from you
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.9)
//        node.geometry = sphere
//
//        sceneView.scene.rootNode.addChildNode(node)
        sceneView.autoenablesDefaultLighting = true
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/diceCollada.scn")!

        // Set the scene to the view
//        sceneView.scene = scene
        
        if let diceNode = scene.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
            sceneView.scene.rootNode.addChildNode(diceNode)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
}
