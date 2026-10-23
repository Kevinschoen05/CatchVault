import SwiftUI
import SwiftData
import PhotosUI

@Observable
class EditCatchViewModel {
    /// The core persistent entity being edited
    let fishCatch: FishCatch
    
    // MARK: - Draft State
    var draftWeight: Double?
    var draftTimestamp: Date
    var draftComment: String
    var draftAngler: Angler?
    var draftSpecies: Species?
    
    // MARK: - Photo State
    var selectedPhotoItem: PhotosPickerItem? = nil {
        didSet { Task { await loadPhoto() } }
    }
    var draftImage: UIImage? = nil
    var isProcessingPhoto: Bool = false
    
    var errorMessage: String? = nil
    
    init(fishCatch: FishCatch) {
        self.fishCatch = fishCatch
        
        // Initialize draft state
        self.draftWeight = fishCatch.weight
        self.draftTimestamp = fishCatch.timestamp
        self.draftComment = fishCatch.comment ?? ""
        self.draftAngler = fishCatch.angler
        self.draftSpecies = fishCatch.species
        
        // Load existing photo if present
        if let path = fishCatch.imagePath {
            self.draftImage = ImageStorageService.shared.loadImage(relativePath: path)
        }
    }
    
    // MARK: - Invariants & Validation
    
    var isValid: Bool {
        let weightValid = (draftWeight ?? 0) > 0
        return weightValid && draftAngler != nil && draftSpecies != nil
    }
    
    // MARK: - Photo Processing
    
    @MainActor
    private func loadPhoto() async {
        guard let item = selectedPhotoItem else { return }
        isProcessingPhoto = true
        defer { isProcessingPhoto = false }
        
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            self.draftImage = uiImage
        }
    }
    
    // MARK: - Commit Phase
    
    /// Pushes draft state back to the core entity and commits the context
    func saveChanges(context: ModelContext) async -> Bool {
            guard isValid else { return false }
            
            fishCatch.weight = draftWeight ?? 0
            fishCatch.timestamp = draftTimestamp
            fishCatch.angler = draftAngler
            fishCatch.species = draftSpecies
            
            let trimmedComment = draftComment.trimmingCharacters(in: .whitespacesAndNewlines)
            fishCatch.comment = trimmedComment.isEmpty ? nil : trimmedComment
            
            // Only trigger the storage service if a NEW photo was picked
            if selectedPhotoItem != nil, let imageToSave = draftImage {
                do {
                    let newPath = try await ImageStorageService.shared.saveCatchPhoto(imageToSave)
                    fishCatch.imagePath = newPath
                } catch {
                    errorMessage = "Failed to save new photo: \(error.localizedDescription)"
                    return false
                }
            } else if draftImage == nil {
                // User explicitly removed the photo
                fishCatch.imagePath = nil
            }
            
            do {
                try context.save()
                return true
            } catch {
                errorMessage = "Failed to save changes: \(error.localizedDescription)"
                return false
            }
        }
    /// Executes a cascade delete on the target catch
    func deleteCatch(context: ModelContext) -> Bool {
        context.delete(fishCatch)
        do {
            try context.save()
            return true
        } catch {
            errorMessage = "Failed to delete catch: \(error.localizedDescription)"
            return false
        }
    }
}
