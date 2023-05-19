//
//  SmallShortcutWidget.swift
//  WidgetsExtension
//
//  Created by Joses Solmaximo on 28/04/23.
//

import SwiftUI
import WidgetKit

struct SmallShortcutWidget: View {
    @EnvironmentObject var tm: ThemeManager
    
    let entry: ShortcutWidgetEntry
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            ShortcutGrid(shortcuts: entry.shortcuts, columns: 4, slots: 8)
        }
    }
}

struct SmallShortcutWidget_Previews: PreviewProvider {
    static var previews: some View {
        SmallShortcutWidget(entry: ShortcutWidgetEntry(date: Date(), configuration: .init(), shortcuts: [
            .init(name: "", image: "house", color: defaultColors.blue.rawValue, transactions: []),
            .init(name: "", image: "parkingsign", color: defaultColors.yellow.rawValue, transactions: []),
            .init(name: "", image: "gamecontroller", color: defaultColors.purple.rawValue, transactions: []),
            .init(name: "", image: "house", color: defaultColors.blue.rawValue, transactions: []),
            .init(name: "", image: "parkingsign", color: defaultColors.yellow.rawValue, transactions: []),
            .init(name: "", image: "gamecontroller", color: defaultColors.purple.rawValue, slot: 7, transactions: []),
            
        ]))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .environmentObject(ThemeManager())
    }
}
