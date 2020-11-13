# UIDocumentBrowserViewController memory leak FB8894765

If an app is using UIDocumentBrowserViewController in a "Multi-Windows" setup on iPad, the document browser of is never released from memory when its window is closed. This makes the whole object graph retained by the document browser to hang in memory, causing all sorts of incorrect behaviour and crashes.

## Steps to reproduce

1. Build and run the demo app in iPad Simulator
2. Add new app window: show home screen (CMD+H) > long-press on app's icon > Show All Windows > Tap (+) in the top right corner
3. Show app switcher: SWIFT+CONTROL+CMD+H
4. Remove the FIRST* app window: swipe it up

## Expected results
`UIWindow` is successfully removed on `SceneDelegate.sceneDidDisconnect(_:)`, together with its view controller hierarchy, starting with `UIDocumentBrowserViewController` which assigned as `rootViewController`

## Actual results
`UIWindow` is successfully removed on `SceneDelegate.sceneDidDisconnect(_:)` but `UIDocumentBrowserViewController` which assigned as `rootViewController` keeps handing in memory, together with its view controller hierachy (e.g. `childen` or `presentedViewController`)

![Screen recording showing the steps to reproduce the bug](https://github.com/tomaskraina/feedbackassistant.apple.com/blob/master/UIDocumentBrowserUISceneMemoryLeak/UIDocumentBrowser-memory-leak.gif?raw=true)

### Object Graphs

![Object Graph of visible UIDocumentBrowserViewController](https://github.com/tomaskraina/feedbackassistant.apple.com/blob/master/UIDocumentBrowserUISceneMemoryLeak/UIDocumentBrowser.png?raw=true)
![Object Graph of UIDocumentBrowserViewController that's supposed to be released](https://github.com/tomaskraina/feedbackassistant.apple.com/blob/master/UIDocumentBrowserUISceneMemoryLeak/UIDocumentBrowser-memory-leak.png?raw=true)

### Footnote
* It is important to remove the first opened app window, not the one that was added by tapping (+) otherwise the whole app gets killed
