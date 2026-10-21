import SwiftUI
import UIKit


@main
struct SheetPreferredColorSchemeClearBugApp: App {

    // MARK: - App

    var body: some Scene {
        WindowGroup {
            LabView()
        }
    }
}

private enum ColorSchemeSelection: String, CaseIterable, Identifiable {

    case none = "nil"
    case light = ".light"
    case dark = ".dark"

    var id: Self { self }

    var colorScheme: ColorScheme? {
        switch self {
        case .none: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

private enum ModalPresentationStyle {

    case sheet
    case fullScreen
    case uiKitSheet

    var title: String {
        switch self {
        case .sheet: Strings.sheet
        case .fullScreen: Strings.fullScreen
        case .uiKitSheet: Strings.uiKitSheet
        }
    }
}

private enum Defaults {

    static let presentation = "presentationColorScheme"
    static let root = "rootColorScheme"
    static let behavior = "preferredColorSchemeBehavior"
}

private struct AppearanceTraits: Equatable {

    var screen: UIUserInterfaceStyle = .unspecified
    var scene: UIUserInterfaceStyle = .unspecified
}

enum PreferredColorSchemeBehavior: String {

    case whenSpecified
    case always
}

extension View {

    func applyPreferredColorScheme(_ colorScheme: ColorScheme?, behavior: PreferredColorSchemeBehavior) -> some View {
        self.modifier(PreferredColorSchemeModifier(colorScheme: colorScheme, behavior: behavior))
    }
}

// This intentional identity-changing branch is the experiment, not a workaround.
private struct PreferredColorSchemeModifier: ViewModifier {

    // MARK: - Properties

    let colorScheme: ColorScheme?
    let behavior: PreferredColorSchemeBehavior

    // MARK: - ViewModifier

    func body(content: Content) -> some View {
        if self.behavior == .always || self.colorScheme != nil {
            content.preferredColorScheme(self.colorScheme)
        } else {
            content
        }
    }
}

private struct LabView: View {

    @AppStorage(Defaults.presentation) private var presentation = ColorSchemeSelection.none
    @AppStorage(Defaults.root) private var root = ColorSchemeSelection.none
    @AppStorage(Defaults.behavior) private var behavior = PreferredColorSchemeBehavior.always
    @State private var sheetPresented = false
    @State private var coverPresented = false
    @State private var uiKitSheetPresented = false
    @State private var traits = AppearanceTraits()

    // MARK: - View

    var body: some View {
        NavigationStack {
            Form {
                Section(Strings.modal) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(Strings.preferredColorScheme)
                        ColorSchemePicker(selection: self.$presentation)
                    }
                    HStack {
                        Text(Strings.swiftUIFramework)
                        Spacer(minLength: 0.0)
                        Button(Strings.sheetButton) {
                            self.sheetPresented = true
                        }
                        Button(Strings.fullScreenButton) {
                            self.coverPresented = true
                        }
                    }
                    .buttonStyle(.bordered)
                    HStack {
                        Text(Strings.uiKitFramework)
                        Spacer(minLength: 0)
                        Button(Strings.presentViewController) {
                            self.uiKitSheetPresented = true
                        }
                        .accessibilityIdentifier("presentUIKitSheet")
                    }
                    .buttonStyle(.bordered)
                }
                AppearanceReadout(
                    presentation: self.presentation,
                    root: self.rootScheme,
                    behavior: self.behavior,
                    traits: self.traits
                )
                Section(Strings.tryThis) {
                    Text(Strings.instructions)
                    Text(Strings.statusBarHint)
                }
                Section {
                    Button(Strings.reset, action: self.reset)
                }
            }
            .navigationTitle(Strings.appTitle)
        }
        .preferredColorScheme(self.rootScheme)
        .background(SystemAppearanceReader(traits: self.$traits))
        .background(UIKitSheetPresenter(isPresented: self.$uiKitSheetPresented))
        .sheet(isPresented: self.$sheetPresented) {
            PresentationView(style: .sheet, rootScheme: self.rootScheme, traits: self.traits)
                .applyPreferredColorScheme(self.presentation.colorScheme, behavior: self.behavior)
        }
        .fullScreenCover(isPresented: self.$coverPresented) {
            PresentationView(style: .fullScreen, rootScheme: self.rootScheme, traits: self.traits)
                .applyPreferredColorScheme(self.presentation.colorScheme, behavior: self.behavior)
        }
    }
}

// MARK: - Private

private extension LabView {

    var rootScheme: ColorScheme? {
        self.sheetPresented || self.coverPresented || self.uiKitSheetPresented ? self.root.colorScheme : nil
    }

    func reset() {
        self.presentation = .none
        self.root = .none
        self.behavior = .always
    }
}

private struct PresentationView: View {

    @Environment(\.dismiss) private var dismiss
    @AppStorage(Defaults.presentation) private var presentation = ColorSchemeSelection.none
    @AppStorage(Defaults.root) private var root = ColorSchemeSelection.none
    @AppStorage(Defaults.behavior) private var behavior = PreferredColorSchemeBehavior.always
    @State private var sheetPresented = false
    @State private var coverPresented = false

    // MARK: - Properties

    let style: ModalPresentationStyle
    let rootScheme: ColorScheme?
    let traits: AppearanceTraits
    var dismissPresentation: (() -> Void)?

    // MARK: - View

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ColorSchemePicker(selection: self.$presentation)
                } header: {
                    Text(Strings.preferredColorScheme)
                }
                Section {
                    ColorSchemePicker(selection: self.$root)
                        .accessibilityIdentifier("rootColorSchemePicker")
                } header: {
                    Text(Strings.rootPreference)
                } footer: {
                    Text(Strings.rootScopeHint)
                }

                Section {
                    Toggle(Strings.whenSpecified, isOn: self.usesConditionalBehavior)
                        .accessibilityIdentifier("conditionalModifierToggle")
                } header: {
                    Text("Debugging")
                } footer: {
                    Text(Strings.behaviorHint)
                }

                AppearanceReadout(
                    presentation: self.presentation,
                    root: self.rootScheme,
                    behavior: self.behavior,
                    traits: self.traits
                )
                Section(Strings.nesting) {
                    Button(Strings.showAnotherSheet) {
                        self.sheetPresented = true
                    }
                    Button(Strings.showAnotherFullScreen) {
                        self.coverPresented = true
                    }
                }
            }
            .navigationTitle(self.style.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.done, action: self.dismissModal)
                }
            }
        }
        .sheet(isPresented: self.$sheetPresented) {
            PresentationView(style: .sheet, rootScheme: self.rootScheme, traits: self.traits)
                .applyPreferredColorScheme(self.presentation.colorScheme, behavior: self.behavior)
        }
        .fullScreenCover(isPresented: self.$coverPresented) {
            PresentationView(style: .fullScreen, rootScheme: self.rootScheme, traits: self.traits)
                .applyPreferredColorScheme(self.presentation.colorScheme, behavior: self.behavior)
        }
    }
}

// MARK: - Private

private extension PresentationView {

    func dismissModal() {
        if let dismissPresentation = self.dismissPresentation {
            dismissPresentation()
        } else {
            self.dismiss()
        }
    }

    var usesConditionalBehavior: Binding<Bool> {
        Binding(
            get: { self.behavior == .whenSpecified },
            set: { self.behavior = $0 ? .whenSpecified : .always }
        )
    }
}

// A separate SwiftUI root observes defaults within the UIKit hosting controller.
// The controller and its rootView are created once per presentation.
private struct UIKitSheetContent: View {

    @AppStorage(Defaults.presentation) private var presentation = ColorSchemeSelection.none
    @AppStorage(Defaults.root) private var root = ColorSchemeSelection.none
    @AppStorage(Defaults.behavior) private var behavior = PreferredColorSchemeBehavior.always
    @State private var traits = AppearanceTraits()

    // MARK: - Properties

    let dismissPresentation: () -> Void

    // MARK: - View

    var body: some View {
        PresentationView(
            style: .uiKitSheet,
            rootScheme: self.root.colorScheme,
            traits: self.traits,
            dismissPresentation: self.dismissPresentation
        )
        .applyPreferredColorScheme(self.presentation.colorScheme, behavior: self.behavior)
        .background(SystemAppearanceReader(traits: self.$traits))
    }
}

private struct UIKitSheetPresenter: UIViewControllerRepresentable {

    // MARK: - Properties

    @Binding var isPresented: Bool

    // MARK: - UIViewControllerRepresentable

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: self.$isPresented)
    }

    func makeUIViewController(context: Context) -> PresenterViewController {
        let controller = PresenterViewController()
        controller.onAppear = { [weak coordinator = context.coordinator, weak controller] in
            guard let controller else { return }

            coordinator?.synchronize(from: controller)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: PresenterViewController, context: Context) {
        context.coordinator.isPresented = self.$isPresented
        context.coordinator.synchronize(from: uiViewController)
    }

    static func dismantleUIViewController(_ uiViewController: PresenterViewController, coordinator: Coordinator) {
        uiViewController.onAppear = nil
        coordinator.dismissImmediately()
    }

    final class PresenterViewController: UIViewController {

        // MARK: - Properties

        var onAppear: (() -> Void)?

        // MARK: - UIViewController

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            self.onAppear?()
        }
    }

    final class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {

        private var hostingController: UIHostingController<UIKitSheetContent>?

        // MARK: - Properties

        var isPresented: Binding<Bool>

        // MARK: - Lifecycle

        init(isPresented: Binding<Bool>) {
            self.isPresented = isPresented
        }

        // MARK: - Coordinator

        func synchronize(from presenter: UIViewController) {
            if self.isPresented.wrappedValue {
                guard self.hostingController == nil,
                      presenter.presentedViewController == nil,
                      presenter.viewIfLoaded?.window != nil else { return }

                let hostingController = UIHostingController(rootView: UIKitSheetContent { [weak self] in
                    self?.isPresented.wrappedValue = false
                })
                hostingController.modalPresentationStyle = .pageSheet
                self.hostingController = hostingController
                presenter.present(hostingController, animated: true) { [weak self, weak presenter] in
                    guard let presenter else { return }

                    self?.synchronize(from: presenter)
                }
                hostingController.presentationController?.delegate = self
            } else if let hostingController = self.hostingController {
                guard !hostingController.isBeingPresented, !hostingController.isBeingDismissed else { return }

                hostingController.dismiss(animated: true) { [weak self, weak presenter] in
                    self?.hostingController = nil
                    guard let presenter else { return }

                    self?.synchronize(from: presenter)
                }
            }
        }

        func dismissImmediately() {
            self.hostingController?.dismiss(animated: false)
            self.hostingController = nil
        }

        // MARK: - UIAdaptivePresentationControllerDelegate

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            self.hostingController = nil
            self.isPresented.wrappedValue = false
        }
    }
}

private struct ColorSchemePicker: View {

    // MARK: - Properties

    @Binding var selection: ColorSchemeSelection

    // MARK: - View

    var body: some View {
        Picker(Strings.preferredColorScheme, selection: self.$selection) {
            ForEach(ColorSchemeSelection.allCases) { selection in
                Text(verbatim: selection.rawValue).tag(selection)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("colorSchemePicker")
    }
}

private struct AppearanceReadout: View {

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Properties

    let presentation: ColorSchemeSelection
    let root: ColorScheme?
    let behavior: PreferredColorSchemeBehavior
    let traits: AppearanceTraits

    // MARK: - View

    var body: some View {
        Section(Strings.liveReadout) {
            LabeledContent(Strings.rootPreferredColorScheme, value: Self.name(self.root))
            LabeledContent(Strings.swiftUI, value: Self.name(self.colorScheme))
                .accessibilityIdentifier("effectiveAppearance")
            LabeledContent(Strings.screen, value: Self.name(self.traits.screen))
                .accessibilityIdentifier("screenAppearance")
            LabeledContent(Strings.scene, value: Self.name(self.traits.scene))
                .accessibilityIdentifier("sceneAppearance")
        }
    }
}

// MARK: - Private

private extension AppearanceReadout {

    static func name(_ scheme: ColorScheme?) -> String {
        guard let scheme else { return "nil" }

        return scheme == .dark ? ".dark" : ".light"
    }

    static func name(_ style: UIUserInterfaceStyle) -> String {
        switch style {
        case .unspecified: ".unspecified"
        case .light: ".light"
        case .dark: ".dark"
        @unknown default: "@unknown (\(style.rawValue))"
        }
    }
}

// Read UIKit values without applying any appearance overrides. Sampling both
// levels also catches system changes while a scene has a fixed appearance.
private struct SystemAppearanceReader: UIViewRepresentable {

    // MARK: - Properties

    @Binding var traits: AppearanceTraits

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> ProbeView {
        let view = ProbeView()
        view.onChange = { traits in
            if self.traits != traits {
                self.traits = traits
            }
        }
        return view
    }

    func updateUIView(_ uiView: ProbeView, context: Context) {}

    static func dismantleUIView(_ uiView: ProbeView, coordinator: Void) {
        uiView.stopObserving()
    }

    final class ProbeView: UIView {

        private var observationTask: Task<Void, Never>?

        // MARK: - Properties

        var onChange: ((AppearanceTraits) -> Void)?

        // MARK: - UIView

        override func didMoveToWindow() {
            super.didMoveToWindow()
            self.stopObserving()
            guard self.window != nil else { return }

            // UIScreen has no public interface-style registration independent
            // of scene overrides. This polling is only diagnostic sampling.
            self.observationTask = Task { @MainActor [weak self] in
                while !Task.isCancelled {
                    self?.report()
                    do {
                        try await Task.sleep(for: .milliseconds(1000))
                    } catch {
                        break
                    }
                }
            }
        }

        // MARK: - ProbeView

        func stopObserving() {
            self.observationTask?.cancel()
            self.observationTask = nil
        }
    }
}

// MARK: - Private

private extension SystemAppearanceReader.ProbeView {

    func report() {
        guard let scene = self.window?.windowScene else { return }

        self.onChange?(AppearanceTraits(
            screen: scene.screen.traitCollection.userInterfaceStyle,
            scene: scene.traitCollection.userInterfaceStyle
        ))
    }
}

// MARK: - Strings

private enum Strings {

    static let swiftUIFramework = NSLocalizedString("SwiftUI", bundle: .main, comment: "SwiftUI presentation controls row")
    static let uiKitFramework = NSLocalizedString("UIKit", bundle: .main, comment: "UIKit presentation controls row")
    static let presentViewController = NSLocalizedString("present UIHostingController", bundle: .main, comment: "Present a hosting controller using UIKit")
    static let sheetButton = NSLocalizedString(".sheet", bundle: .main, comment: "Present a sheet")
    static let fullScreenButton = NSLocalizedString(".fullScreen", bundle: .main, comment: "Present a full screen cover")
    static let modal = NSLocalizedString("Modal", bundle: .main, comment: "Main presentation section header")
    static let appTitle = NSLocalizedString("SheetPreferredColorSchemeClearBug", bundle: .main, comment: "App title")
    static let preferredColorScheme = NSLocalizedString(".preferredColorScheme", bundle: .main, comment: "Exact modifier name above argument picker")
    static let rootPreference = NSLocalizedString("RootView.preferredColorScheme", bundle: .main, comment: "Root modifier argument picker title")
    static let showAnotherSheet = NSLocalizedString("Present another sheet", bundle: .main, comment: "Nested presentation button")
    static let showAnotherFullScreen = NSLocalizedString("Present another full screen", bundle: .main, comment: "Nested presentation button")
    static let whenSpecified = NSLocalizedString("Apply .preferredColorScheme conditionally", bundle: .main, comment: "Toggle whenSpecified versus always behavior policy")
    static let behaviorHint = NSLocalizedString("Off: behavior: .always, including nil. On: behavior: .whenSpecified, omitting the modifier for nil. Removing it changes structural identity and may reset nested view state. Shared across all presentation levels; values are saved in UserDefaults.", bundle: .main, comment: "Behavior experiment explanation")
    static let rootScopeHint = NSLocalizedString("Independent root preference, applied only while a modal is presented. nil means no root preference. This uses the ordinary unconditional modifier.", bundle: .main, comment: "Root preference experiment scope")
    static let liveReadout = NSLocalizedString("Live colorScheme", bundle: .main, comment: "Diagnostics title")
    static let rootPreferredColorScheme = NSLocalizedString("Root view preferredColorScheme", bundle: .main, comment: "Active root modifier value")
    static let applied = NSLocalizedString("Applied", bundle: .main, comment: "Modifier is applied")
    static let omitted = NSLocalizedString("Omitted", bundle: .main, comment: "Modifier is absent")
    static let swiftUI = NSLocalizedString("SwiftUI colorScheme", bundle: .main, comment: "SwiftUI environment diagnostic label")
    static let screen = NSLocalizedString("UIScreen.traitCollection.userInterfaceStyle", bundle: .main, comment: "UIScreen traitCollection userInterfaceStyle diagnostic label")
    static let scene = NSLocalizedString("UIWindowScene.traitCollection.userInterfaceStyle", bundle: .main, comment: "UIWindowScene traitCollection userInterfaceStyle diagnostic label")
    static let uiKitSheet = NSLocalizedString("UIKit sheet", bundle: .main, comment: "UIKit sheet navigation title")
    static let sheet = NSLocalizedString("SwiftUI .sheet", bundle: .main, comment: "SwiftUI sheet navigation title")
    static let fullScreen = NSLocalizedString("SwiftUI .fullScreen", bundle: .main, comment: "SwiftUI full screen navigation title")
    static let nesting = NSLocalizedString("Nested presentation", bundle: .main, comment: "Section title")
    static let done = NSLocalizedString("Done", bundle: .main, comment: "Dismiss button")
    static let tryThis = NSLocalizedString("Try this", bundle: .main, comment: "Instructions title")
    static let instructions = NSLocalizedString("Keep the modal open and select .dark → .light → nil. Repeat with different root arguments and conditional mode on and off. Try nested sheets and full-screen covers, then dismiss and reopen.", bundle: .main, comment: "Reproduction instructions")
    static let statusBarHint = NSLocalizedString("Compare actual status-bar text, navigation bar, and background with the readouts. nil means no local preference, and may inherit the presenter’s appearance.", bundle: .main, comment: "Visual inspection instructions")
    static let reset = NSLocalizedString("Reset sample settings", bundle: .main, comment: "Reset button")
}
