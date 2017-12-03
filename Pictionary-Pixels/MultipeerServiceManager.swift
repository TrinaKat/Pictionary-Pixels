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
    var viewController : MultipeerServiceViewManager?
    
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    public let serviceAdvertiser : MCNearbyServiceAdvertiser
    public let serviceBrowser : MCNearbyServiceBrowser
    public var starter : Int
    public var rounds : Int
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self as MCSessionDelegate
        return session
    }()
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: MultipeerServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: MultipeerServiceType)
        self.starter = 0
        self.rounds = 0
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
            do {
                try self.session.send("startGame".data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error: Could not stop advertising all players: \(error)")
            }
        }
    }
    
    func start() {
        NSLog("%@", "To the Game View")
        print("/n/n/n/n/n/n/nTo the Game View /n/n/n/n/n")
        if (session.connectedPeers.count > 0) {
            do {
                try self.session.send("toGame".data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error: Could not go to Game View: \(error)")
            }
        }
    }
    
    func chooseDrawer() {
        let total_players:Int = session.connectedPeers.count
        starter = Int(arc4random_uniform(UInt32(total_players)))
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
        //self.viewController?.assignViews(manager: self, connectedDevices:
            //session.connectedPeers.map{$0.displayName}, firstDrawer: starter)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let str = String(data: data, encoding: .utf8)!
        if (str == "startGame") {
            self.serviceAdvertiser.stopAdvertisingPeer()
            self.serviceBrowser.stopBrowsingForPeers()
            self.delegate?.startGame(manager: self)
        }
        
        if (str == "toGame") {
            self.viewController?.allToDraw(manager: self)
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
}

protocol MultipeerServiceViewManager {
    //func assignViews(manager: MultipeerServiceManager, connectedDevices: [String], firstDrawer: Int)
    func allToDraw(manager : MultipeerServiceManager)
}
