//
//  ShortcutWidgetEntry.swift
//  WidgetsExtension
//
//  Created by Joses Solmaximo on 28/04/23.
//

import WidgetKit

struct ShortcutWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ShortcutConfigurationIntent
    var shortcuts: [Shortcut]
}
