//
//  ShortcutWidgetProvider.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 28/04/23.
//

import WidgetKit

struct ShortcutWidgetProvider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> ShortcutWidgetEntry {
        return ShortcutWidgetEntry(date: Date(), configuration: ShortcutConfigurationIntent(), shortcuts: [])
    }
    
    func getSnapshot(for configuration: ShortcutConfigurationIntent, in context: Context, completion: @escaping (ShortcutWidgetEntry) -> ()) {
        var entry = ShortcutWidgetEntry(date: Date(), configuration: ShortcutConfigurationIntent(), shortcuts: [])
        
        entry.shortcuts = WidgetDataManager.getShortcuts()
        
        completion(entry)
    }

    func getTimeline(for configuration: ShortcutConfigurationIntent, in context: Context, completion: @escaping (Timeline<ShortcutWidgetEntry>) -> ()) {
        var entry = ShortcutWidgetEntry(date: Date(), configuration: ShortcutConfigurationIntent(), shortcuts: [])
     
        entry.shortcuts = WidgetDataManager.getShortcuts()
        
        let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 60 * 60 * 30)))
        
        completion(timeline)
    }
}
