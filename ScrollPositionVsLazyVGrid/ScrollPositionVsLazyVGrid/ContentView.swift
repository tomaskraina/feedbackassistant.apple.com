//
//  ContentView.swift
//  ScrollPositionVsSectionHeader
//
//  Created by Tom Kraina on 17.10.2023.
//

import SwiftUI


struct ContentView: View {

    private var itemSize: CGSize = .init(width: 50.0, height: 50.0)

    // Annotated as @State to create the sections only once
    @State private var sectionData = makeSections()

    // Tracking scroll position
    @State private var currentItemID: MyIdentifier?
    var currentItemDescription: String { self.currentItemID?.stringId ?? "nil" }

    var body: some View {
        VStack {
            // 1. Scroll View
            ScrollView(.vertical) {
                LazyVGrid(
                    columns: [.init(.adaptive(minimum: self.itemSize.width), spacing: Constants.columnSpacing, alignment: .center)],
                    alignment: .center,
                    spacing: Constants.sectionSpacing
                ) {
                    ForEach(self.sectionData) { section in
                        Section(section.title) {
                            ForEach(section.items) { item in
                                Text(item.text)
                                    .frame(width: self.itemSize.width, height: self.itemSize.height)
                            }
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: self.$currentItemID) // TODO: Comment out this line to make the scrolling work

            Divider()

            // 2. Settings
            Group {
                Label(
                    title: { Text(self.currentItemDescription) },
                    icon: { Image(systemName: "42.circle") }
                )
            }
            .padding()
        }
        #if os(macOS)
        .frame(width: 320, height: 480, alignment: .center)
        #endif
    }
}

// MARK: - Private

private extension ContentView {

    enum MyIdentifier: Hashable {
        case item(id: Int)
        case section(id: Int)

        var stringId: String {
            switch self {
            case .item(let id):
                "item-\(id)"
            case .section(let id):
                "section-\(id)"
            }
        }
    }

    struct Item: Identifiable {
        var id: MyIdentifier
        let index: Int
        var text: String
    }

    struct SectionInfo: Identifiable {
        let id: MyIdentifier
        var index: Int
        var title: String
        var items: [Item]
    }

    enum Constants {
        static let columnSpacing: CGFloat = 6.0
        static let sectionSpacing: CGFloat = 6.0
    }
}

// MARK: - Make Sections

private func makeSections() -> [ContentView.SectionInfo] {
    let items = (0..<300).map {
        ContentView.Item(
            id: .item(id: $0),
            index: $0,
            text: "item \($0)"
        )
    }

    // divide into section per 10 items
    let groupedItems = Dictionary(grouping: items) {
        $0.index / 10
    }

    return groupedItems.map { (sectionIndex, items) in
        ContentView.SectionInfo(
            id: .section(id: sectionIndex),
            index: sectionIndex,
            title: "section \(sectionIndex * 10)",
            items: items
        )
    }
    .sorted(by: { $0.index < $1.index })
}

// MARK: - Preview

#Preview {
    ContentView()
}
