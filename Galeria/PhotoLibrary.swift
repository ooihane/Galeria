import SwiftUI
import Photos
import UIKit

struct AlbumRow: Identifiable {
    let id: String
    let title: String
    let count: Int?
    let depth: Int
}

@MainActor
final class PhotoLibrary: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    @Published var status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    @Published var assets: [PHAsset] = []
    @Published var albums: [AlbumRow] = []
    @Published var total = 0
    @Published var favorites = 0
    @Published var message: String?
    @Published var busy = false

    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
        refresh()
    }

    deinit { PHPhotoLibrary.shared().unregisterChangeObserver(self) }

    nonisolated func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { @MainActor [weak self] in self?.refresh() }
    }

    func requestAccess() async {
        _ = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        refresh()
    }

    func refresh() {
        status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .authorized || status == .limited else {
            assets = []; albums = []; total = 0; favorites = 0
            return
        }
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let all = PHAsset.fetchAssets(with: options)
        total = all.count
        // The feasibility screen deliberately bounds displayed assets.
        assets = (0..<min(60, all.count)).map { all.object(at: $0) }
        let favoriteAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)
        favorites = favoriteAlbums.firstObject.map {
            PHAsset.fetchAssets(in: $0, options: nil).count
        } ?? 0
        var rows: [AlbumRow] = []
        var visited = Set<String>()
        func visit(_ collections: PHFetchResult<PHCollection>, depth: Int) {
            collections.enumerateObjects { collection, _, _ in
                guard visited.insert(collection.localIdentifier).inserted else { return }
                if let album = collection as? PHAssetCollection {
                    rows.append(AlbumRow(id: album.localIdentifier,
                                         title: album.localizedTitle ?? "Álbum",
                                         count: PHAsset.fetchAssets(in: album, options: nil).count,
                                         depth: depth))
                } else if let folder = collection as? PHCollectionList {
                    rows.append(AlbumRow(id: folder.localIdentifier,
                                         title: folder.localizedTitle ?? "Carpeta", count: nil, depth: depth))
                    visit(PHCollection.fetchCollections(in: folder, options: nil), depth: depth + 1)
                }
            }
        }
        visit(PHCollectionList.fetchTopLevelUserCollections(with: nil), depth: 0)
        albums = rows
    }

    func toggleFavorite(_ asset: PHAsset) async {
        guard !busy else { return }
        guard let current = PHAsset.fetchAssets(withLocalIdentifiers: [asset.localIdentifier], options: nil).firstObject,
              current.canPerform(.properties) else {
            message = "Fotos no permite modificar este elemento."
            return
        }
        busy = true
        defer { busy = false }
        let nextValue = !current.isFavorite
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest(for: current).isFavorite = nextValue
            }
            refresh()
            message = nextValue ? "Marcada como favorita en Fotos." : "Quitada de Favoritos en Fotos."
        } catch { message = "No se pudo cambiar el favorito: \(error.localizedDescription)" }
    }

    func createTestAlbum() async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        // Reuse the named test album instead of creating one on every tap.
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "title == %@", "Galería · Prueba técnica")
        guard PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options).count == 0 else {
            message = "El álbum de prueba ya existe."
            return
        }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "Galería · Prueba técnica")
            }
            refresh()
            message = "Álbum vacío creado. Puedes eliminarlo después desde Fotos."
        } catch { message = "No se pudo crear el álbum: \(error.localizedDescription)" }
    }
}
