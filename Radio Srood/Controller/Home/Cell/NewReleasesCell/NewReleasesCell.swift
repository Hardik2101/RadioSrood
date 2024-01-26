
import UIKit

class NewReleasesCell: UITableViewCell {
    
    @IBOutlet private weak var newReleasesCollectionView: UICollectionView!
    @IBOutlet private weak var newReleasesHeightConstraint: NSLayoutConstraint!
    
    var newReleases: [NewRelease] = []
    var presentView: HomeViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        newReleasesCollectionView.delegate = self
        newReleasesCollectionView.dataSource = self
    }
    
    func reloadCollectionView() {
        setCellHeight()
        newReleasesCollectionView.reloadData()
    }
    
    private func setCellHeight() {
        let topInset: CGFloat = 10
        let bottomInset: CGFloat = 10
        let lineSpace: CGFloat = 10
        let columnCount = ceil(CGFloat(newReleases.count/3))
        newReleasesHeightConstraint.constant = (getCellSize() * columnCount) + (lineSpace * (columnCount-1)) + topInset + bottomInset
    }
    
    private func getCellSize() -> CGFloat {
        let cellSpace: CGFloat = 10
        let leftInset: CGFloat = 8
        let rightInset: CGFloat = 8
        let space = cellSpace * 2
        let totalInset: CGFloat = leftInset + rightInset + space
        let width = (Common.screenSize.width  - totalInset) / 3
        let height = width + 50
        return height
    }
    
}

//MARK: - collectionview delegates methods
extension NewReleasesCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newReleases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.registerAndGet(NewReleasesCollectionCell.self, indexPath: indexPath) {
            cell.newRelease = newReleases[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let presentView = presentView {
            presentView.groupID = newReleases[indexPath.row].newReleasesTrackID
            presentView.homeHeader = .newReleases
            if presentView.interstitial != nil {
                presentView.interstitial.present(fromRootViewController: presentView)
            } else {
                presentView.openMusicPlayerViewController()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSpace = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
        let leftInset = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset.left ?? 0
        let rightInset = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset.right ?? 0
        let space = cellSpace * 2
        let totalInset = leftInset + rightInset + space
        let width = (Common.screenSize.width  - totalInset) / 3
        let height = width + 50
        return CGSize(width: width, height: height)
    }
    
}

