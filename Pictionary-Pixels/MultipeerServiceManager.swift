//
//  MultipeerServiceManager.swift
//  Pictionary-Pixels
//
//  Created by Katie Luangkote on 11/30/17.
//  Copyright © 2017 TrinaKat. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MultipeerServiceManagerDelegate {
    func connectedDevicesChanged(manager : MultipeerServiceManager, connectedDevices: [String])
    
    // Used by devices to handle/respond to messages sent from other peers
    func messageReceived(manager: MultipeerServiceManager, message: NSDictionary)
}

class MultipeerServiceManager : NSObject {
    
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    private let MultipeerServiceType = "game-starter"
    
    var delegate : MultipeerServiceManagerDelegate?
    
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    public let serviceAdvertiser : MCNearbyServiceAdvertiser
    public let serviceBrowser : MCNearbyServiceBrowser
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        session.delegate = self as MCSessionDelegate
        return session
    }()
    
    // Used by all views to send data to other peers
    func sendMessage(message: NSDictionary){
        if session.connectedPeers.count > 0 {
            //store the devices
            do {
                try self.session.send(NSKeyedArchiver.archivedData(withRootObject: message), toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
            } catch {
                NSLog("\(error)")
            }
        }
    }
    
    func storeDevices() -> [String] {
//        let total_players:Int = session.connectedPeers.count + 1
//        starter = Int(arc4random_uniform(UInt32(total_players)))
        devices = session.connectedPeers.map{$0.displayName}
        devices?.append(myPeerId.displayName)
        print("\n\n\n\n\n start button pressed \n\n\n\n\n\n\n \(devices) \n\n\n\n\n")
        return devices!
    }
    
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
    
}

extension MultipeerServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
//        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
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
//        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
//        NSLog("%@", "foundPeer: \(peerID)")
//        NSLog("%@", "invitePeer: \(peerID)")
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
//        NSLog("%@", "lostPeer: \(peerID)")
    }
    
}

extension MultipeerServiceManager : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
//        NSLog("%@", "peer \(peerID) didChangeState: \(state)")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }
    
    // When peers send data, forwarded to other peers at messageReceived() for handling
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
//        NSLog("%@", "didReceiveData: \(data)")
        self.delegate?.messageReceived(manager: self, message: NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
//        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
//        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
//        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
}
