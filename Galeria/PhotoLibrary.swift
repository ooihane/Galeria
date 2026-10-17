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
    @Published var requestingAccess = false
    @Published var permissionMessage: String?
    private var observingChanges = false
    private var permissionTimeout: Task<Void, Never>?

    override init() {
        super.init()
        refresh()
    }

    deinit { PHPhotoLibrary.shared().unregisterChangeObserver(self) }

    nonisolated func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { @MainActor [weak self] in self?.refresh() }
    }

    func requestAccess() {
        guard !requestingAccess else { return }
        status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .notDetermined else {
            refresh()
            permissionMessage = status == .denied
                ? "El acceso está denegado. Puedes cambiarlo en Ajustes."
                : "El estado del permiso se ha actualizado."
            return
        }
        guard UIApplication.shared.applicationState == .active else {
            permissionMessage = "Abre Galería en primer plano y vuelve a pulsar el botón."
            return
        }
        guard let explanation = Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryUsageDescription") as? String,
              !explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            permissionMessage = "Esta instalación no contiene la descripción del permiso de Fotos. Es necesario actualizar la aplicación."
            return
        }
        requestingAccess = true
        permissionMessage = "Solicitud enviada a iOS. Esperando tu elección…"
        // Invoke PhotoKit directly from the foreground button action; use the
        // documented completion handler and explicitly return UI updates to MainActor.
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.permissionTimeout?.cancel()
                self.requestingAccess = false
                self.refresh()
                switch self.status {
                case .authorized: self.permissionMessage = nil
                case .limited: self.permissionMessage = "Solo se mostrarán las fotos que has autorizado."
                case .denied: self.permissionMessage = "Acceso denegado. Puedes cambiarlo en Ajustes."
                case .restricted: self.permissionMessage = "iOS restringe el acceso a Fotos en este dispositivo."
                case .notDetermined: self.permissionMessage = "iOS ha respondido sin conceder ni denegar el acceso."
                @unknown default: self.permissionMessage = "iOS devolvió un estado de permiso desconocido."
                }
            }
        }
        permissionTimeout = Task { [weak self] in
            do { try await Task.sleep(for: .seconds(15)) } catch { return }
            guard let self, self.requestingAccess else { return }
            self.requestingAccess = false
            self.refresh()
            if self.status == .notDetermined {
                self.permissionMessage = "iOS todavía no ha respondido a la solicitud. Si no aparece ningún aviso, comunica este mensaje junto con la versión de Galería indicada abajo."
            }
        }
    }

    func refresh() {
        status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .authorized || status == .limited else {
            assets = []; albums = []; total = 0; favorites = 0
            return
        }
        if !observingChanges {
            PHPhotoLibrary.shared().register(self)
            observingChanges = true
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
