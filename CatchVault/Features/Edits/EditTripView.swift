import SwiftUI
import SwiftData

struct EditTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: EditTripViewModel
    
    init(trip: Trip) {
        _viewModel = State(initialValue: EditTripViewModel(trip: trip))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Layer 0 Base Canvas Backdrop
                Color.backgroundMain
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        timingCard
                        notesCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Edit Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.backgroundMain, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.textOnCardSecondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.saveChanges(context: modelContext) {
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.isValid)
                    .foregroundStyle(viewModel.isValid ? Color.brandAccent : Color.secondary)
                }
            }
            .alert("Invalid Edit", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - Subviews
    
    private var timingCard: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 16) {
                Text("TRIP BOUNDARIES")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.textOnCardPrimary)
                
                DatePicker(
                    "Start Time",
                    selection: $viewModel.draftStartTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .cvFont(CVFont.primaryBody)
                .foregroundStyle(Color.textOnCardPrimary)
                .tint(Color.brandAccent)
                
                Divider()
                    .background(Color.textOnCardSecondary.opacity(0.2))
                
                DatePicker(
                    "End Time",
                    selection: $viewModel.draftEndTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .cvFont(CVFont.primaryBody)
                .foregroundStyle(Color.textOnCardPrimary)
                .tint(Color.brandAccent)
            }
        }
    }
    
    private var notesCard: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("NOTES & OBSERVATIONS")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.textOnCardPrimary)
                
                TextField(
                    "",
                    text: $viewModel.draftNotes,
                    prompt: Text("Water clarity, weather, active lures, tactics...").foregroundStyle(Color.textOnCardSecondary.opacity(0.6)),
                    axis: .vertical
                )
                .cvFont(CVFont.primaryBody)
                .foregroundStyle(Color.textOnCardPrimary)
                .lineLimit(6...10)
                .padding(10)
                .background(Color.surfaceSecondary.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }
}
