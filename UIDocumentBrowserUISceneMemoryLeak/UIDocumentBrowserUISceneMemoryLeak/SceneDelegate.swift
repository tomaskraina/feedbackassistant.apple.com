/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This class demonstrates how to use the scene delegate to configure a scene's interface.
 It also implements basic state restoration.
*/

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // The `window` property will automatically be loaded with the storyboard's initial view controller.
    var window: UIWindow?

    // MARK: - UIWindowSceneDelegate

    func sceneDidDisconnect(_ scene: UIScene) {
        guard let documentBrowser = self.window?.rootViewController as? DocumentBrowserViewController else { fatalError("rootViewController is not of type DocumentBrowserViewController") }

        weak var weakDocumentBrowser = documentBrowser
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // Check all the related objects has been released from memory
            assert(self?.window == nil, "Property 'window' of SceneDelegate is not nil after its scene was disconnected")
            assert(weakDocumentBrowser == nil, "DocumentBrowserViewController instance \(weakDocumentBrowser!) was not released from memory after its scene was disconnected")
        }
    }
}
