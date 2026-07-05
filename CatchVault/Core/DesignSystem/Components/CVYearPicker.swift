//
//  CVYearPicker.swift
//  CatchVault
//
//  Created by Kevin Schoen on 7/5/26.
//
import SwiftUI

/// A reusable, token-compliant year filter menu selection component.
/// Binds directly into localized `@State` parameters to drive on-device SwiftData array filters.
struct CVYearPicker: View {
    @Binding var selectedYear: Int?
    let availableYears: [Int]
    
    var body: some View {
        Menu {
            // Unrestricted All Time State Option
            Button(action: { selectedYear = nil }) {
                HStack {
                    Text("All Time")
                    if selectedYear == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Divider()
            
            // Chronologically ordered years (Most recent at top)
            ForEach(availableYears.sorted(by: >), id: \.self) { year in
                Button(action: { selectedYear = year }) {
                    HStack {
                        Text(String(year))
                        if selectedYear == year {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedYear != nil ? String(selectedYear!) : "All Time")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.primary.opacity(0.06))
            )
            .foregroundColor(.secondary) // Maps cleanly against textSecondary intentions
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedYear: Int? = 2026
        var body: some View {
            VStack(spacing: 20) {
                CVYearPicker(selectedYear: $selectedYear, availableYears: [2024, 2025, 2026])
                
                Button("Clear Filter") { selectedYear = nil }
            }
            .padding()
        }
    }
    return PreviewWrapper()
}
