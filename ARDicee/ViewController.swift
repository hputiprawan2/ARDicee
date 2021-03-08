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
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
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

        
        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // Touch is detected in the view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first { // detect the location when user touches the screen
            let touchLocation = touch.location(in: sceneView)
            
            // Convert 2D location (phone screen) to 3D location (real world)
            if let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .any) {
                let results = sceneView.session.raycast(query)
                if let hitResult = results.first {
                    // Create a new scene
                    let scene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                    if let diceNode = scene.rootNode.childNode(withName: "Dice", recursively: true) {
                        // + diceNode.boundingSphere.radius to elevate the dice up in y position so the dice is align with the plane not half dice
                        diceNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x,
                                                       y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                                                       z: hitResult.worldTransform.columns.3.z)
                        sceneView.scene.rootNode.addChildNode(diceNode)
                    }
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                 height: CGFloat(planeAnchor.extent.z))
            let planeNode = SCNNode() // vertical when created
            // y = 0; want it flat with the surface
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            
            // Since the planeNode is default in vertical, we need to transform by rotated it 90 degrees to horizontal - flat
            // Rotating 90 degrees by 1PI rad = 180, so we need half PI radient to rotate to 90
            // Rotating clockwise by using negative
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            node.addChildNode(planeNode)
        } else {
            return
        }
    }
}
