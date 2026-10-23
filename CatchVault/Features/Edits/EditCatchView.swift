import SwiftUI
import SwiftData
import PhotosUI

struct EditCatchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Species.name) private var allSpecies: [Species]
    
    @State private var viewModel: EditCatchViewModel
    @State private var showingDeleteConfirmation = false
    
    init(catchItem: FishCatch) {
        _viewModel = State(initialValue: EditCatchViewModel(fishCatch: catchItem))
    }
    
    // Dynamically scope available anglers to the trip's existing roster
    private var availableAnglers: [Angler] {
        viewModel.fishCatch.trip?.anglers ?? []
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundMain
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        photoAttachmentCard
                        metadataCard
                        telemetryCard
                        notesCard
                        deleteCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Edit Catch")
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
                        Task {
                            if await viewModel.saveChanges(context: modelContext) {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.isValid || viewModel.isProcessingPhoto)
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
    
    private var photoAttachmentCard: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("CATCH PHOTO")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.textOnCardPrimary)
                
                HStack(spacing: 16) {
                    if let image = viewModel.draftImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Button(role: .destructive) {
                            viewModel.draftImage = nil
                            viewModel.selectedPhotoItem = nil
                        } label: {
                            Text("Remove")
                                .cvFont(CVFont.primaryBody)
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.surfaceSecondary.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay {
                                if viewModel.isProcessingPhoto {
                                    ProgressView()
                                        .tint(Color.brandAccent)
                                } else {
                                    Image(systemName: "photo")
                                        .foregroundStyle(Color.textOnCardSecondary)
                                }
                            }
                    }
                    
                    Spacer()
                    
                    PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                        Text(viewModel.draftImage == nil ? "Attach Photo" : "Change Photo")
                            .cvFont(CVFont.primaryBody)
                            .foregroundStyle(Color.brandAccent)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.brandAccent.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    private var metadataCard: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 16) {
                Text("CATCH METRICS")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.textOnCardPrimary)
                
                HStack {
                    Text("Weight (lbs)")
                        .cvFont(CVFont.primaryBody)
                        .foregroundStyle(Color.textOnCardPrimary)
                    Spacer()
                    TextField("0.00", value: $viewModel.draftWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .cvFont(CVFont.telemetryMedium)
                        .foregroundStyle(Color.brandAccent)
                }
                
                Divider().background(Color.textOnCardSecondary.opacity(0.2))
                
                Picker("Species", selection: $viewModel.draftSpecies) {
                    Text("Select Species").tag(nil as Species?)
                    ForEach(allSpecies) { species in
                        Text(species.name).tag(species as Species?)
                    }
                }
                .tint(Color.brandAccent)
                
                Divider().background(Color.textOnCardSecondary.opacity(0.2))
                
                Picker("Angler", selection: $viewModel.draftAngler) {
                    Text("Select Angler").tag(nil as Angler?)
                    ForEach(availableAnglers) { angler in
                        Text(angler.name).tag(angler as Angler?)
                    }
                }
                .tint(Color.brandAccent)
                
                Divider().background(Color.textOnCardSecondary.opacity(0.2))
                
                DatePicker("Time Caught", selection: $viewModel.draftTimestamp, displayedComponents: [.date, .hourAndMinute])
                    .cvFont(CVFont.primaryBody)
                    .foregroundStyle(Color.textOnCardPrimary)
                    .tint(Color.brandAccent)
            }
        }
    }
    
    private var telemetryCard: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundStyle(viewModel.fishCatch.latitude != nil ? Color.brandAccent : Color.textOnCardSecondary)
                    Text("GPS TELEMETRY (LOCKED)")
                        .cvFont(CVFont.sectionHeader)
                        .foregroundStyle(Color.textOnCardPrimary)
                }
                
                if let lat = viewModel.fishCatch.latitude, let lon = viewModel.fishCatch.longitude {
                    Text("\(lat), \(lon)")
                        .cvFont(CVFont.telemetryHeavy)
                        .foregroundStyle(Color.textOnCardSecondary)
                        .minimumScaleFactor(0.8)
                } else {
                    Text("No GPS coordinates captured.")
                        .cvFont(CVFont.metadata)
                        .foregroundStyle(Color.textOnCardSecondary)
                }
            }
        }
    }
    
    private var notesCard: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("CATCH COMMENTS")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.textOnCardPrimary)
                
                TextField("", text: $viewModel.draftComment, prompt: Text("Lure, cover, depth...").foregroundStyle(Color.textOnCardSecondary.opacity(0.6)), axis: .vertical)
                    .cvFont(CVFont.primaryBody)
                    .foregroundStyle(Color.textOnCardPrimary)
                    .lineLimit(4...8)
                    .padding(10)
                    .background(Color.surfaceSecondary.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    private var deleteCard: some View {
        Button {
            showingDeleteConfirmation = true
        } label: {
            HStack {
                Spacer()
                Image(systemName: "trash")
                Text("Delete Catch")
                    .cvFont(CVFont.sectionHeader)
                Spacer()
            }
            .foregroundStyle(Color.white)
            .padding(.vertical, 14)
            .background(Color.red.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 16)
        .alert("Delete Catch?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if viewModel.deleteCatch(context: modelContext) {
                    dismiss()
                }
            }
        } message: {
            Text("This action cannot be undone. Are you sure you want to permanently remove this catch from your log?")
        }
    }
}
