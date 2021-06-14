//
//  SceneDelegate.swift
//  TestUserActivity
//
//  Created by Tom Kraina on 14.06.2021.
//  Copyright © 2021 Tom Kraina. All rights reserved.
//
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        print(#function)
        print("> stateRestorationActivity:", session.stateRestorationActivity.debugDescription)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    // MARK: - NSUserActivity

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print("continue…\n--------------------------------------")

        print("user activity title:\(userActivity.title ?? "nil")")
        print("userInfo: \(userActivity.userInfo?.debugDescription ?? "nil")")
        dump(userActivity)

        assert(userActivity.userInfo?.keys.contains(UIDocument.userActivityURLKey) == true)
        assert(userActivity.userInfo?.keys.contains("bookmark") == true)
    }

    func scene(_ scene: UIScene, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        print(#function)
        print(userActivityType, error)
    }

    func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String) {
        print(#function)
        print(userActivityType)
    }

    override func restoreUserActivityState(_ activity: NSUserActivity) {
        print(#function)
        print(activity)
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        print(#function)

        // When reconnecting the scene and restoring state, the user activity provided by this method will be provided in the stateRestorationActivity property of UISceneSession.
        return self.userActivity
    }

    override func updateUserActivityState(_ activity: NSUserActivity) {
        super.updateUserActivityState(activity)
    }
}

