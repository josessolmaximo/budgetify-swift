//
//  ShortcutGrid.swift
//  WidgetsExtension
//
//  Created by Joses Solmaximo on 28/04/23.
//

import SwiftUI

struct ShortcutGrid: View {
    @EnvironmentObject var tm: ThemeManager
    
    let shortcuts: [Shortcut]
    let columns: [GridItem]
    let slots: ClosedRange<Int>
    
    init(shortcuts: [Shortcut], columns: Int, slots: Int){
        self.shortcuts = shortcuts
        self.columns = Array(repeating: GridItem(.fixed(60), spacing: 15), count: columns)
        self.slots = (1...slots)
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(slots, id: \.self) { slot in
                let shortcut = shortcuts.first(where: { $0.slot == slot })
                
                if let shortcut = shortcut {
                    Link(destination: URL(string: "budgetify://transaction?slot=\(slot)")!) {
                        Circle()
                            .strokeBorder(shortcut.color.stringToColor(), lineWidth: 3)
                            .frame(width: 55, height: 55)
                            .overlay(
                                CustomIconView(imageName: shortcut.image, dimensions: 22.5)
                                    .foregroundColor(shortcut.color.stringToColor())
                            )
                    }
                } else {
                    Link(destination: URL(string: "budgetify://transaction")!) {
                        Circle()
                            .strokeBorder(tm.selectedTheme.secondaryLabel, lineWidth: 3)
                            .frame(width: 55, height: 55)
//                            .overlay(
//                                Text("\(slot)")
//                                    .font(.system(size: 19, weight: .semibold))
//                                    .foregroundColor(tm.selectedTheme.secondaryLabel)
//                            )
                    }
                }
            }
        }
    }
}
