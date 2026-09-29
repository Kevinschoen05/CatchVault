//
//  CVYearPicker.swift
//  CatchVault
//

import SwiftUI

public struct CVYearPicker: View {
    @Binding private var selectedYear: Int?
    private let availableYears: [Int]
    
    public init(
        selectedYear: Binding<Int?>,
        availableYears: [Int]
    ) {
        self._selectedYear = selectedYear
        self.availableYears = availableYears
    }
    
    public var body: some View {
        Menu {
            Button("All Time") {
                selectedYear = nil
            }
            
            ForEach(availableYears, id: \.self) { year in
                Button(String(year)) {
                    selectedYear = year
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedYear != nil ? String(selectedYear!) : "All Time")
                    .cvFont(CVFont.metadata)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .bold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.brandAccent)
            .foregroundStyle(Color.white)
            .clipShape(Capsule())
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
    }
}
