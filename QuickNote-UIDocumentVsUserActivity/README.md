# Quick Note does not show "Add Link" for iCloud documents even though persistentIdentifier is set  

I would love to adopt Quick Note in our document-based app, however, I can't get Quick Note to show "Add Link" button for iCloud documents even though both 'persistentIdentifer' and 'targetContentIdentifier' were provided.

I don't see the same issue with local documents, where the NSUserActivity is created in code. For iCloud documents, I'm setting the NSUserActivity provided by UIKit do the UIDocument instance and set the 'persistentIdentifer' and 'targetContentIdentifier' before assigning it to the UIResponder (UIViewController that shows the document).

Moreover, and what's probably blocking us from adopting Quick Note altogether, is that the `userInfo` dictionary on `NSUserActivity` gets completely removed when continuing the activity in `UISceneDelegate.scene(_ scene: UIScene, continue userActivity: NSUserActivity)`.

When setting the `NSUserActivity`, the `userInfo` dictionary contains all the necessary information about the document's location, like fileURL (key `UIDocument.userActivityURLKey`) and bookmark, together with the keys being added to `requiredUserInfoKeys`.

For more information, see the exact implentation in the attached Xcode project.

## Steps to reproduce

1. Run the attached project on a real device with iCloud account set up
2. Select "iCloud Drive" in Locations
3. Create a new document using "+" button
4. Show Quick Note window (Pencil swipe from the bottom right corner)
5. Ensure "Add Link" button is present in Quick Note window
6. Tap "Done" to close the document
7. Select "On my iPad" in Locations
8. Create a new document using "+" button
9. Show Quick Note window (Pencil swipe from the bottom right corner)
10. Tap "Add Link" button in Quick Note window
11. Tap the added link in Quick Note window

## Expected results
- "Add Link" button is visible in Quick Note window in both cases (local and iCloud document)
- App is provided with NSUserActivity with all the necessary data in `userInfo` property when tapping the added link in Quick Note

## Actual results
- no "Add Link" button is visible in Quick Note window for iCloud document
- App is NOT provided with NSUserActivity with all the necessary data in `userInfo` property when tapping the added link in Quick Note
