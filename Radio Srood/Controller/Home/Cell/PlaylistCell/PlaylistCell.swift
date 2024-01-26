
import UIKit

class PlaylistCell: UITableViewCell {
    
    @IBOutlet private weak var playlistCollectionView: UICollectionView!
    @IBOutlet private weak var playlistHeightConstraint: NSLayoutConstraint!
    
    var playlist: [Playlist] = []
    var presentView: HomeViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        playlistCollectionView.delegate = self
        playlistCollectionView.dataSource = self
    }
    
    func reloadCollectionView() {
        playlistCollectionView.reloadData()
    }
    
}

//MARK: - collectionview delegates methods
extension PlaylistCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlist.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.registerAndGet(PlaylistCollectionCell.self, indexPath: indexPath) {
            cell.playlist = playlist[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let presentView = presentView {
            presentView.groupID = playlist[indexPath.row].playlistid
            presentView.homeHeader = .playlists
            if presentView.interstitial != nil {
                presentView.interstitial.present(fromRootViewController: presentView)
            } else {
                presentView.openMusicPlayerViewController()
            }
        }
    }
    
}
