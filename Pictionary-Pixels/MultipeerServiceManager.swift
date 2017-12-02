//
//  MultipeerServiceManager.swift
//  Pictionary-Pixels
//
//  Created by Katie Luangkote on 11/30/17.
//  Copyright © 2017 TrinaKat. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MultipeerServiceManager : NSObject {
    
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    private let MultipeerServiceType = "game-starter"
    var delegate : MultipeerServiceManagerDelegate?
    
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    public let serviceAdvertiser : MCNearbyServiceAdvertiser
    public let serviceBrowser : MCNearbyServiceBrowser
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self as MCSessionDelegate
        return session
    }()
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: MultipeerServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: MultipeerServiceType)
        super.init()
        self.serviceAdvertiser.delegate = self as MCNearbyServiceAdvertiserDelegate
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.delegate = self as MCNearbyServiceBrowserDelegate
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func stopAdvertisingSelf() {
        NSLog("%@", "Stopped advertising \(UIDevice.current.name) and all other players")
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
        if (session.connectedPeers.count > 0) {
            let dataDict: NSDictionary = ["startGame": "startGame"]
            let data = NSKeyedArchiver.archivedData(withRootObject: dataDict)
            do {
                try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error: Could not stop advertising all players: \(error)")
            }
        }
    }
    
    func setPoints(points: Data) {
        do {
            try self.session.send(points, toPeers: session.connectedPeers, with: .reliable)
        }
        catch let error {
            NSLog("%@", "Error choosing points: \(error)")
        }
    }
    
    // RELEVANT TO IMAGE
    func sendImage(image: Data) {
        do {
            try self.session.send(image, toPeers: session.connectedPeers, with: .reliable)
        }
        catch let error {
            NSLog("%@", "Error choosing points: \(error)")
        }
    }
    
}

extension MultipeerServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        if let wd = UIApplication.shared.delegate?.window {
            var vc = wd!.rootViewController
            if (vc is UINavigationController) {
                vc = (vc as! UINavigationController).visibleViewController
            }
            if (vc is HomeViewController) {
                invitationHandler(true, self.session)
            }
        }
    }
    
}

extension MultipeerServiceManager : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        if let wd = UIApplication.shared.delegate?.window {
            var vc = wd!.rootViewController
            if (vc is UINavigationController) {
                vc = (vc as! UINavigationController).visibleViewController
            }
            if (vc is HomeViewController) {
                browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
}

extension MultipeerServiceManager : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state)")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let unarchivedDictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String, Any>
        let key = Array(unarchivedDictionary.keys)[0]
        // RELEVANT TO IMAGE
        if (key == "image") {
            let imageUIImage = unarchivedDictionary["image"] as! UIImage
            self.delegate?.sendImage(manager: self, image: imageUIImage)
        } else if (key == "startGame") {
            // let str = String(data: data, encoding: .utf8)!
            print("startGame \n \n \n \n \n")
    //            self.serviceAdvertiser.stopAdvertisingPeer()
    //            self.serviceBrowser.stopBrowsingForPeers()
            self.delegate?.startGame(manager: self)
        } else if (key == "pointsChosen") {
            self.delegate?.setPoints(manager: self, points: unarchivedDictionary["pointsChosen"] as! Int)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
}

protocol MultipeerServiceManagerDelegate {
    func connectedDevicesChanged(manager : MultipeerServiceManager, connectedDevices: [String])
    func startGame(manager: MultipeerServiceManager)
    func setPoints(manager: MultipeerServiceManager, points: Int)
    // RELEVANT TO IMAGE
    func sendImage(manager: MultipeerServiceManager, image: UIImage)
}
