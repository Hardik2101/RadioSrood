
import UIKit
import SWRevealViewController
import Alamofire
import AlamofireImage
import GoogleMobileAds
import StoreKit
import MediaPlayer
import AVKit
import AVPlayerViewControllerSubtitles
import SpotlightLyrics

var player: AVPlayer?
var songImage : String = ""
var artistSongName : String = ""
var songName : String = ""
var songController : UIViewController?

protocol MusicPlayerViewControllerDelegate : AnyObject{
    func dismissMusicPlayer()
}

class MusicPlayerViewController: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var lblLyrics: UILabel!
    @IBOutlet weak var viewLyrics: UIView!
    @IBOutlet weak var heightView: NSLayoutConstraint!
    @IBOutlet weak var radioTableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var tableBgHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var artCoverImage: UIImageView!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var btnBackward: UIButton!
    @IBOutlet weak var btnForward: UIButton!
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var btnRepeat: UIButton!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var btnLike: UIButton!
    
    @IBOutlet weak var vwDownloadProgress: UIProgressView!
    
    weak var delegate : MusicPlayerViewControllerDelegate?
    
    var dataHelper: DataHelper!
    var nativeAd: GADUnifiedNativeAd?
    var adLoader: GADAdLoader!
    var isSetupRemoteTransport = false
    var isPlay: Bool = false
    var track: [Track]?
    var tempTrack: [Track]?
    var firstTrackList: [Track]?
    var selectedIndex: Int = 0
    var homeHeader: HomeHeader = .newReleases
    var groupID: Int?
    var isSetMusic = false
    var isLike = false
    var isRepeat = false
    var timeObserver: Any?
    private var lastIndex: Int? = nil
    private var parser: LyricsParser? = nil
    private var isPurchaseSuccess: Bool = false

    var bannerAdViews: [GADBannerView] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        let yourBackImage = UIImage(named: "left-arrow")
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.backItem?.title = ""
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        radioTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 0.1))
        radioTableView.tableFooterView = UIView()
      //  self.view!.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        loadNativeAd()
        prepareView()
        isSetupRemoteTransport = true
        vwDownloadProgress.isHidden = true
        vwDownloadProgress.setProgress(0.0, animated: false)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(RadioViewController.didBecomeActiveNotificationReceived),
                                               name:NSNotification.Name(rawValue: "UIApplicationDidBecomeActiveNotification"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(RadioViewController.playerInterruption(notification:)),
                                               name:NSNotification.Name(rawValue: "AVAudioSessionInterruptionNotification"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleIAPPurchase), name: .PurchaseSuccess, object: nil)
        
        radioTableView.register(UINib(nibName: "BannerAdCell", bundle: nil), forCellReuseIdentifier: "BannerAdCell")

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        radioTableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
        }
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.dismissMusicPlayer()
    }
    

    
    
    private func prepareView() {
        switch homeHeader {
        case .newReleases:
            loadNewReleaseData()
        case .currentRadio:
            break
        case .trending:
            loadTrendingPlaylistData()
        case .popularTracks:
            loadPopularPlaylistData()
        case .playlists:
            loadPlaylistData()
        case .featuredArtist:
            loadFeaturedArtistData()
        case .myPlaylist:
            break
        case .recentlyPlayed:
            break
        }
    }
    
//    func loadBannerAds() {
//            guard !IAPHandler.shared.isGetPurchase() else {
//                return
//            }
//
//            let adView1 = GADBannerView(adSize: kGADAdSizeBanner)
//            adView1.adUnitID = GOOGLE_ADMOB_ForMusicPlayer
//            adView1.rootViewController = self
//            adView1.delegate = self
//            adView1.load(GADRequest())
//
//
//            bannerAdViews = [adView1]
//        }

    
    @objc func didBecomeActiveNotificationReceived() {
        updateNowPlaying(isPause: true)
    }
    
    @objc func playerInterruption(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        if type == .began {
            player?.pause()
            updateNowPlaying(isPause: false)
        }
        else if type == .ended {
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                    if UIApplication.shared.applicationState == .background {
                        print("App in Background")
                        player?.play()
                        self.setupNowPlaying()
                        self.updateNowPlaying(isPause: true)
                    } else {
                        player?.play()
                    }
                }
            }
        }
    }
    
    private func loadNewReleaseData() {
        dataHelper = DataHelper()
        dataHelper.getNewReleaseData { [weak self] resp in
            guard let self = self else { return }
            if let resp = resp {
                self.track = resp.newRelease.first(where: { $0.id == self.groupID})?.tracks
                self.tempTrack = self.track
                self.isSetMusic = true
                self.isPlay = true
                self.handleRecentInView(index: self.selectedIndex)
                self.tableBgHeightConstraints.constant = CGFloat((((self.tempTrack?.count ?? 0)-1) * 60)+165)
                self.radioTableView.reloadData()
            }
        }
    }
    
    private func loadTrendingPlaylistData() {
        dataHelper = DataHelper()
        dataHelper.getTrendingPlaylistData { [weak self] resp in
            guard let self = self else { return }
            if let resp = resp {
                self.track = resp.trendingTracks.first(where: { $0.id == self.groupID})?.tracks
                self.tempTrack = self.track
                self.isSetMusic = true
                self.isPlay = true
                self.handleRecentInView(index: self.selectedIndex)
                self.tableBgHeightConstraints.constant = CGFloat((((self.tempTrack?.count ?? 0)-1) * 60) + 165)
                self.radioTableView.reloadData()
            }
        }
    }
    
    private func loadPopularPlaylistData() {
        dataHelper = DataHelper()
        dataHelper.getPopularPlaylistData { [weak self] resp in
            guard let self = self else { return }
            if let resp = resp {
                self.track = resp.popularTracks.first(where: { $0.id == self.groupID})?.tracks
                self.tempTrack = self.track
                self.isSetMusic = true
                self.isPlay = true
                self.handleRecentInView(index: self.selectedIndex)
                self.tableBgHeightConstraints.constant = CGFloat((((self.tempTrack?.count ?? 0)-1) * 60) + 165)
                self.radioTableView.reloadData()
            }
        }
    }
    
    private func loadPlaylistData() {
        dataHelper = DataHelper()
        dataHelper.getPlaylistData { [weak self] resp in
            guard let self = self else { return }
            if let resp = resp {
                self.track = resp.trendingPlaylist.first(where: { $0.id == self.groupID})?.tracks
                self.tempTrack = self.track
                self.isSetMusic = true
                self.isPlay = true
                self.handleRecentInView(index: self.selectedIndex)
                self.tableBgHeightConstraints.constant = CGFloat((((self.tempTrack?.count ?? 0)-1) * 60)+165)
                self.radioTableView.reloadData()
            }
        }
    }
    
    private func loadFeaturedArtistData() {
        dataHelper = DataHelper()
        dataHelper.getFeaturedArtistData { [weak self] resp in
            guard let self = self else { return }
            if let resp = resp {
                self.track = resp.rSroodFeaturedArtistData.first(where: { $0.id == self.groupID})?.tracks
                self.tempTrack = self.track
                self.isSetMusic = true
                self.isPlay = true
                self.handleRecentInView(index: self.selectedIndex)
                self.tableBgHeightConstraints.constant = CGFloat((((self.tempTrack?.count ?? 0)-1) * 60)+165)
                self.radioTableView.reloadData()
            }
        }
    }
    
   
    deinit {
        UIApplication.shared.endReceivingRemoteControlEvents()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
        NotificationCenter.default.removeObserver(self,
                                                  name:NSNotification.Name(rawValue: "UIApplicationDidBecomeActiveNotification"),
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name:NSNotification.Name(rawValue: "AVAudioSessionInterruptionNotification"),
                                                  object: nil)
        NotificationCenter.default.removeObserver(self)
        print("Remove screen")
    }
    
    
    
    private func setHeaderData(headerTitle: String) -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 30))
        let lblTitle = UILabel(frame: CGRect(x: 15, y: 5, width: screenSize.width - 30, height: 20))
        lblTitle.text = headerTitle
        lblTitle.textColor = .white.withAlphaComponent(1.1)
        lblTitle.font = UIFont(name: "Avenir Next Ultra Light", size: 19)
        containerView.addSubview(lblTitle)
        return containerView
    }
    
    func handleRecentInView(index: Int) {
        self.artCoverImage.layer.cornerRadius = 3
        self.artCoverImage.layer.masksToBounds = true
        if let item = track?[index] {
            if let url = URL(string: item.artcover) {
                self.artCoverImage.af_setImage(withURL: url, placeholderImage: UIImage(named: "Lav_Radio_Logo.png"))
                self.bgImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "b1.png"))
            }
            self.trackTitle.text = item.track
            self.artistName.text = item.artist
            songName = item.track
            songController = self
            artistSongName = item.artist
            songImage = item.artcover
            self.isAlreadyLiked(track: item)
            self.configureRecentlyPlayed(index: self.selectedIndex)
            lastIndex = nil
            if item.lyric_synced == ""{
                self.heightView.constant  = 0
                self.viewLyrics.isHidden = true
                self.parser = nil
            }
            else{
                self.heightView.constant  = 40
                self.viewLyrics.isHidden = false
                self.lblLyrics.text = ""
                let lyricsUrl = "\(lyricsURL)\(item.lyric_synced ?? "")"
                let data = (try? Data(contentsOf: URL(string: lyricsUrl)!))!
                let lyrics = String(data: data, encoding: .utf8)
                guard let lyricss = lyrics?.emptyToNil() else {
                    return
                }
                parser = LyricsParser(lyrics: lyricss)
            }
            if let urlString = item.mediaPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: songPath + urlString) {
                if isSetMusic {
                    isSetMusic = false
                    self.play(url: url, isPlay: self.isPlay)
                }
                if isSetupRemoteTransport {
                    isSetupRemoteTransport = false
                    self.setupRemoteTransportControls()
                }
            }
        }
    }
    
    func showLyric(toTime time: TimeInterval) {
        guard let lyrics = parser?.lyrics else {
            return
        }
        
        guard let index = lyrics.index(where: { $0.time >= player?.currentTime().seconds ?? time }) else {
            // when no lyric is before the time passed in means scrolling to the first
            return
        }
        
        guard lastIndex == nil || index - 1 != lastIndex else {
            return
        }
        
        if index > 0 {
            self.lblLyrics.text = lyrics[index - 1].text
            print(self.lblLyrics.text)
            lastIndex = index - 1
        }
    }
    
    @objc func lyricsBtnClicked() {
    
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LyricsViewController") as! LyricsViewController
        if let track = track {
            vc.track = track[selectedIndex]
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func optionMenuBtnClicked() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayerOptionViewController") as! PlayerOptionViewController

        if let track = track {
            vc.currentSong = track[selectedIndex].convertToSongModel()
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func moreInfoBtnClicked() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MoreInfoViewController") as! MoreInfoViewController
        if let track = track {
            vc.track = track[selectedIndex]
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func backwardBtnPressed() {
        if let track = track, selectedIndex > 0 {
            self.selectedIndex = selectedIndex - 1
            self.tempTrack = Array(track.dropFirst(selectedIndex))
            firstTrackList = Array(track.dropLast(track.count - selectedIndex))
            isSetMusic = true
            self.isPlay = true
            handleRecentInView(index: selectedIndex)
            self.tableBgHeightConstraints.constant = CGFloat((((self.tempTrack?.count ?? 0)-1) * 60)+165)
            self.radioTableView.reloadData()
        } else {
            player?.pause()
            self.playPauseBtn.setImage(UIImage(named: "ic_play"), for:.normal)
        }
    }
    
    @objc func forwardBtnPressed() {
        if let track = track, selectedIndex < track.count-1 {
            selectedIndex = selectedIndex + 1
            tempTrack = Array(track.dropFirst(selectedIndex))
            firstTrackList = Array(track.dropLast(track.count - selectedIndex))
            isSetMusic = true
            isPlay = true
            handleRecentInView(index: selectedIndex)
            self.tableBgHeightConstraints.constant = CGFloat((((self.tempTrack?.count ?? 0)-1) * 60)+165)
            self.radioTableView.reloadData()
        } else {
            player?.pause()
            self.playPauseBtn.setImage(UIImage(named: "ic_play"), for:.normal)
        }
    }
    
    func shareBtnClicked(url: URL) {
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
        vc.modalPresentationStyle = .popover
        if let wPPC = vc.popoverPresentationController {
            wPPC.sourceView = self.view
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func actionLyrics(_ sender: Any) {
        if let track = track {
            if track[selectedIndex].lyric_synced != ""{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LyricPlayViewController") as! LyricPlayViewController
                vc.lyricsUrl = "\(lyricsURL)\(track[selectedIndex].lyric_synced ?? "")"
                vc.currentSong = track[selectedIndex].convertToSongModel()
                self.present(vc, animated: true)
            }
        }
    }
    
    @IBAction func actionClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc private func handleIAPPurchase() {
        isPurchaseSuccess = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
            self.isPurchaseSuccess = false
        })
    }

    
    @IBAction func clickOn_btnDownload(_ sender: Any) {
        
        let purchase = IAPHandler.shared.isGetPurchase()
        
        if purchase || self.isPurchaseSuccess {
            if let currentTrack = track?[selectedIndex] {
                let urlString = currentTrack.mediaPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                guard let mediaPathInfo = urlString, let url = URL(string: songPath + mediaPathInfo) else {
                    return
                }

                var name = "\(url.lastPathComponent)"
                let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                    var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    documentsURL.appendPathComponent(name)
                    return (documentsURL, [.removePreviousFile])
                }

                Alamofire.download(url, to: destination)
                    .downloadProgress { progress in
                        self.vwDownloadProgress.isHidden = false
                        DispatchQueue.main.async {
                            self.vwDownloadProgress.setProgress(Float(progress.fractionCompleted), animated: true)
                        }
                        print("Download Progress: \(progress.fractionCompleted)")
                        if (progress.fractionCompleted == 1) {
                            self.navigationController?.finishProgress()
                            self.vwDownloadProgress.isHidden = true
                            self.vwDownloadProgress.setProgress(0.0, animated: false)

                        }
                    }
                    .response { response in
                        if let destinationURL = response.destinationURL {
                            print(destinationURL)
                        }
                    }

                // Update UserDefaults with artcover for the current track
                UserDefaults.standard.set(currentTrack.artcover, forKey: "\(url.deletingPathExtension().lastPathComponent)")

                if let url = URL(string: currentTrack.artcover) {
                }
            }

        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "IAPVC") as! IAPVC
            let navVC = UINavigationController(rootViewController: vc)
            navVC.navigationBar.isHidden = true
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
        }

    }

}

extension MusicPlayerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mainCount = 2
        switch homeHeader {
        case .newReleases:
            return mainCount + ((tempTrack?.count ?? 0)-1)
        case .currentRadio:
            return 0
        case .trending:
            return mainCount + ((tempTrack?.count ?? 0)-1)
        case .popularTracks:
            return mainCount + ((tempTrack?.count ?? 0)-1)
        case .myPlaylist:
            return mainCount + ((tempTrack?.count ?? 0)-1)
        case .recentlyPlayed:
            return mainCount + ((tempTrack?.count ?? 0)-1)
        case .playlists:
            return mainCount + ((tempTrack?.count ?? 0)-1)
        case .featuredArtist:
            return mainCount + ((tempTrack?.count ?? 0)-1)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            
            let isValid: Bool = false
            if !isValid {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BannerAdCell", for: indexPath) as! BannerAdCell
            for subview in cell.vwMain.subviews {
                subview.removeFromSuperview()
            }
//
                if IAPHandler.shared.isGetPurchase() {
                    cell.vwMain.isHidden = true
                    cell.heightOfVw.constant = 0
                } else {
                    cell.vwMain.isHidden = false
                    cell.heightOfVw.constant = 65
                }
                
                cell.selectionStyle = .none
                cell.backgroundColor = .clear

                // Load banner ad into the cell's view hierarchy
                let bannerView = GADBannerView(adSize: kGADAdSizeBanner)
                bannerView.adUnitID = GOOGLE_ADMOB_ForMusicPlayer
                bannerView.rootViewController = self
                bannerView.delegate = self
                bannerView.load(GADRequest())
                // Set the banner view frame
//                bannerView.frame = CGRect(x: 0, y: 0, width: cell.vwMain.frame.width, height: cell.vwMain.frame.height)
                // Remove any existing subviews from vwAds

                // Add the banner view to the cell's content view
                cell.vwMain.addSubview(bannerView)

                // Set the banner view frame
                bannerView.frame = cell.vwMain.bounds

                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecentPlayerOptionCell", for: indexPath) as! RecentPlayerOptionCell
                cell.selectionStyle = .none
                cell.btnLyrics.addTarget(self, action: #selector(lyricsBtnClicked), for: .touchUpInside)
                cell.btnMoreInfo.addTarget(self, action: #selector(moreInfoBtnClicked), for: .touchUpInside)
                cell.btnOption.addTarget(self, action: #selector(optionMenuBtnClicked), for: .touchUpInside)
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecentPlayerOptionCell", for: indexPath) as! RecentPlayerOptionCell
            cell.selectionStyle = .none
            cell.btnLyrics.addTarget(self, action: #selector(lyricsBtnClicked), for: .touchUpInside)
            cell.btnMoreInfo.addTarget(self, action: #selector(moreInfoBtnClicked), for: .touchUpInside)
            cell.btnOption.addTarget(self, action: #selector(optionMenuBtnClicked), for: .touchUpInside)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecentListCell", for: indexPath) as! RecentListCell
            cell.selectionStyle = .none
            cell.artCoverImage.layer.cornerRadius = 3
            cell.artCoverImage.layer.masksToBounds = true
            if let item = tempTrack?[(indexPath.row + 1) - 2] {
                if let url = URL(string: item.artcover) {
                    cell.artCoverImage.af_setImage(withURL: url, placeholderImage: UIImage(named: "Lav_Radio_Logo.png"))
                }
                cell.trackTitle.text = item.track
                cell.artistName.text = item.artist
            }
            return cell

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecentListCell", for: indexPath) as! RecentListCell
            cell.selectionStyle = .none
            cell.artCoverImage.layer.cornerRadius = 3
            cell.artCoverImage.layer.masksToBounds = true
            if let item = tempTrack?[(indexPath.row + 1) - 2] {
                if let url = URL(string: item.artcover) {
                    cell.artCoverImage.af_setImage(withURL: url, placeholderImage: UIImage(named: "Lav_Radio_Logo.png"))
                }
                cell.trackTitle.text = item.track
                cell.artistName.text = item.artist
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            break
        default:
            pausePlayer()
            self.selectedIndex = (firstTrackList?.count ?? 0) + indexPath.row - 1
            self.isPlay = true
            if let track = track {
                self.tempTrack = Array(track.dropFirst(selectedIndex))
                firstTrackList = Array(track.dropLast(track.count - selectedIndex))
            }
            isSetMusic = true
            handleRecentInView(index: selectedIndex)
            tableBgHeightConstraints.constant = CGFloat((((tempTrack?.count ?? 0)-1) * 60) + 165)
            radioTableView.reloadData()
        }
    }
    
}

extension MusicPlayerViewController: GADAdLoaderDelegate, GADUnifiedNativeAdLoaderDelegate {
    
    func loadNativeAd() {
        guard !IAPHandler.shared.isGetPurchase() else {
            return
        }

        adLoader = GADAdLoader(adUnitID: GOOGLE_ADMOB_NATIVE,
                               rootViewController: self,
                               adTypes: [.unifiedNative],
                               options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        guard !IAPHandler.shared.isGetPurchase() else {
            return
        }

        self.nativeAd = nativeAd
        tableBgHeightConstraints.constant = CGFloat((((tempTrack?.count ?? 0)-1) * 60)+165)
        radioTableView.reloadData()
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
    }
    
}

extension MusicPlayerViewController {

    func play(url: URL, isPlay: Bool = false) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem:playerItem)
        self.playerSlider.minimumValue = 0.0
        self.playerSlider.maximumValue = Float(player?.currentItem?.asset.duration.seconds ?? 0.0)
        populateLabelWithTime(self.lblStartTime, time: 0.0)
        populateLabelWithTime(self.lblEndTime, time: player?.currentItem?.asset.duration.seconds ?? 0.0)
        player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        self.playerSlider.value = 0.0
        playerSlider.setValue(0, animated: true)
        if !isPlay {
            self.playPauseBtn.setImage(UIImage(named: "ic_play"), for: .normal)
            self.updateNowPlaying(isPause: true)
            player?.pause()
        } else {
            self.playPauseBtn.setImage(UIImage(named: "ic_pause"), for: .normal)
            self.updateNowPlaying(isPause: false)
            let subtitleURL = URL(string: "https://api.radiosrood.com/static/app/lyrics/")//URL(fileURLWithPath: subtitleFile!)
            let parser = try? Subtitles(file: subtitleURL!, encoding: .utf8)
            player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { [weak self] (time)  in
                  if player?.currentItem?.status == .readyToPlay {
                      let currentTime = CMTimeGetSeconds(player?.currentTime() ?? CMTime())
                      let secs = Int(currentTime)
                      let text = parser?.searchSubtitles(at: TimeInterval(secs)) ?? ""
                      self?.showLyric(toTime: TimeInterval(secs))
                      print("\(secs)------>\(text)")
                  }
              })
            player?.play()
        }
       // self.btnLike.setImage(UIImage(named: "ic_like"), for: .normal)
       // self.isLike = false
        self.setupNowPlaying()
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        //time observer to update slider.
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), // used to monitor the current play time and update slider
                                       queue: DispatchQueue.global(), using: { [weak self] (progressTime) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.playerSlider.value = Float(progressTime.seconds)
                self.populateLabelWithTime(self.lblStartTime, time: progressTime.seconds)
            }
        })
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        playerSlider.setValue(0, animated: true)
        populateLabelWithTime(self.lblStartTime, time: 0.0)
        player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        if isRepeat {
            player?.play()
        } else {
            NotificationCenter.default.removeObserver(self,
                                                      name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                      object: nil)
            if let track = track, selectedIndex < track.count-1 {
                if let timeObserver = timeObserver {
                    if player != nil {
                        player?.removeTimeObserver(timeObserver)
                    }
                }
            }
            self.forwardBtnPressed()
        }
    }

    func populateLabelWithTime(_ label : UILabel, time: Double) {
        let minutes = Int(time / 60)
        let seconds = Int(time) - minutes * 60
        label.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
    }

    @IBAction func pausePressed() {
        if (player?.isPlaying ?? true) {
            DispatchQueue.main.async {
                self.playPauseBtn.setImage(UIImage(named: "ic_play"), for:.normal)
            }
            player?.pause()
            updateNowPlaying(isPause: true)
        } else {
            DispatchQueue.main.async {
                self.playPauseBtn.setImage(UIImage(named: "ic_pause"), for: .normal)
            }
            player?.play()
            updateNowPlaying(isPause: false)
        }
    }

    @IBAction func likeBtnPressed(_ sender: Any) {
        if isLike {
            btnLike.setImage(UIImage(named: "ic_like"), for: .normal)
            isLike = false
        } else {
            btnLike.setImage(UIImage(named: "ic_like_filled"), for: .normal)
            isLike = true
        }
        configureLike(index: self.selectedIndex)
    }

    @IBAction func repeatBtnPressed(_ sender: Any) {
        let image = UIImage(named: "ic_repeat")?.withRenderingMode(.alwaysTemplate)
        self.btnRepeat.setImage(image, for: .normal)
        if isRepeat {
            isRepeat = false
            self.btnRepeat.tintColor = .white
        } else {
            isRepeat = true
            self.btnRepeat.tintColor = .red
        }
    }

    @IBAction func backwardBtnEvent(_ sender: Any) {
        self.pausePlayer()
        self.backwardBtnPressed()
    }

    @IBAction func forwardBtnEvent(_ sender: Any) {
        self.pausePlayer()
        self.forwardBtnPressed()
    }
    
    @IBAction func progressSliderValueChanged() {
        let seconds: Int64 = Int64(playerSlider.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        player?.seek(to: targetTime)
    }

    func updateNowPlaying(isPause: Bool) {
        // Define Now Playing Info
        if var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPause ? 0 : 1
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }

    func setupNowPlaying() {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyArtist] = artistName.text
        nowPlayingInfo[MPMediaItemPropertyTitle] = trackTitle.text
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artCoverImage.image
        if let image = artCoverImage.image {
            if #available(iOS 10.0, *) {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
                }
            } else {
                // Fallback on earlier versions
            }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo

        if LOCAL_NOTIFICATION {
            let localNotification = UILocalNotification()
            localNotification.fireDate = NSDate(timeIntervalSinceNow: 5) as Date
            //            localNotification.alertBody = radioName.text!
            localNotification.timeZone = NSTimeZone.default
            localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
    }

    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            if let player = player {
                if !player.isPlaying {
                    player.play()
                    self.playPauseBtn.setImage(UIImage(named: "ic_pause"), for:.normal)
                    return .success
                }
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            if let player = player {
                if player.isPlaying {
                    player.pause()
                    self.playPauseBtn.setImage(UIImage(named: "ic_play"), for:.normal)
                    return .success
                }
            }
            return .commandFailed
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            if player != nil {
                self.pausePlayer()
                self.forwardBtnPressed()
                return .success
            }
            return .commandFailed
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            if player != nil {
                self.pausePlayer()
                self.backwardBtnPressed()
                return .success
            }
            return .commandFailed
        }

    }

    func pausePlayer() {
        player?.pause()
        self.playerSlider.setValue(0, animated: true)
        self.populateLabelWithTime(self.lblStartTime, time: 0.0)
        player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        if let timeObserver = timeObserver {
            if player != nil {
                player?.removeTimeObserver(timeObserver)
            }
        }
    }

}


extension MusicPlayerViewController{
    func isAlreadyLiked(track : Track){
        let savedTracks = UserDefaultsManager.shared.localTracksData
        let isInFav = savedTracks.filter({$0.isFav && track.trackid == $0.trackid})
        if isInFav.count > 0{
            isLike = true
        }
        else{
            isLike = false
        }
        if isLike {
            btnLike.setImage(UIImage(named: "ic_like_filled"), for: .normal)
        } else {
            btnLike.setImage(UIImage(named: "ic_like"), for: .normal)
        }
    }
    
    func configureLike(index : Int){
        if let item = track?[index] {
            var savedTracks = UserDefaultsManager.shared.localTracksData
            let trackIndex = savedTracks.firstIndex(where: {$0.trackid == item.trackid})
            if let trackIndex = trackIndex{
                savedTracks[trackIndex].isFav = isLike
            }
            else{
                let newItem = item.convertToSongModel()
                newItem.isFav = true
                savedTracks.append(newItem)
            }
            UserDefaultsManager.shared.localTracksData = savedTracks
        }
    }
    
    func configureRecentlyPlayed(index : Int){
        if let item = track?[index] {
            var savedTracks = UserDefaultsManager.shared.localTracksData
            let trackIndex = savedTracks.firstIndex(where: {$0.trackid == item.trackid})
            if let trackIndex = trackIndex {
                savedTracks.remove(at: trackIndex)
            }
            let newItem = item.convertToSongModel()
            newItem.isRecentlyPlayed = true
            savedTracks.append(newItem)
            UserDefaultsManager.shared.localTracksData = savedTracks
        }
    }
}