

import UIKit
import SWRevealViewController
import GoogleMobileAds
import AlamofireImage
import AlamofireImage
import AVKit
import AVFoundation
class TimelineTableViewController: UITableViewController {
    
    @IBOutlet weak var menuBtn :UIBarButtonItem!
    
    var dataHelper: DataHelper!
    var musicData: NSArray!
    var timelineData = [TimelineModel]()
    var timelineDict = [NSDictionary]()
    var bannerView: GADBannerView!
    let avPlayerViewController = AVPlayerViewController()
    var avPlayer: AVPlayer?
    var player = Player.radio
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuBtn.target = self.revealViewController()
        menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view!.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        let uiback = UIImageView(image: UIImage(named: "b1.png"))
        uiback.contentMode = UIView.ContentMode.scaleAspectFill
        tableView.backgroundView = uiback
        createBanner()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        getAppleData()
    }
    
    func getAppleData(){
        self.timelineData.removeAll()
        self.timelineDict = [NSDictionary]()
        self.dataHelper = DataHelper() ///
        self.dataHelper.getTimelineData { (data) in
            
            for post in data {
                let postA = post as! NSDictionary
                if postA.value(forKey: "tv_name") as! String != "PAMIR TV "
                {
                    let nameTrack = postA.value(forKey: "tv_name")
                    let urlTrack = postA.value(forKey: "tv_stream") as! String
                    let imagePost = postA.value(forKey: "image") as! String
                    self.timelineData.append(TimelineModel(trackName: nameTrack as! String, trackUrl: urlTrack, trackImageUrl: imagePost))
                    self.timelineDict.append(postA)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timelineData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "apple", for: indexPath) as! AppleTableViewCell
        
        /*  let data  = self.timelineData[indexPath.row]
         
         cell.trackName.text = data.trackName
         
         let ava = data.trackImageUrl
         
         let urla = URL(string:ava!)
         
         cell.trackImage.af_setImage(withURL: urla!)  //kf.setImage(with: urla)
         cell.trackImage.layer.cornerRadius = 3
         cell.trackImage.layer.masksToBounds = true */
        
        let data  = self.timelineData[indexPath.row]
        
        cell.trackName.text = data.trackName
        
        let ava = data.trackImageUrl
        
        let img = BASE_BACKEND_URL + UPLOAD_IMAGE + ava! as String
        
        let urla = URL(string:img)!
        
        cell.trackImage.af_setImage(withURL: urla) //  af_setImage(with: urla)
        cell.trackImage.layer.cornerRadius = 3
        cell.trackImage.layer.masksToBounds = true
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data_obj  = self.timelineData[indexPath.row]
        let movieURL = data_obj.trackUrl
        if data_obj.trackName == "PAMIR TV "
        {
            guard let url = URL(string: movieURL!) else { return }
            let asset = AVAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            self.avPlayer = AVPlayer(playerItem: playerItem)
            self.avPlayerViewController.player = self.avPlayer
            self.present(self.avPlayerViewController, animated: true) { [weak self] in
                self?.avPlayerViewController.player?.play()
            }
        }
        else
        {
            let data  = self.timelineDict[indexPath.row]
            UserDefaults.standard.setValue(data, forKey: "NowPlayData")
            let story = UIStoryboard.init(name: "Main", bundle: nil)
            let cv = story.instantiateViewController(withIdentifier:"RadioViewNavController") as! UINavigationController
            self.revealViewController()?.frontViewController = cv
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadRadio"), object: nil, userInfo: nil)
        }
    }
    
    func createBanner(){
        guard !IAPHandler.shared.isGetPurchase() else {
            // Skip loading the ad if the purchase is made
            return
        }

        bannerView = GADBannerView(frame:CGRect(x: 0, y: 0, width:  tableView.frame.size.width, height: 50))
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0);
        bannerView.adUnitID = GOOGLE_ADMOB_KEY
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        if SHOW_BANNER_ADMOB {self.view.addSubview(bannerView)}
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !IAPHandler.shared.isGetPurchase() else {
            // Skip loading the ad if the purchase is made
            return
        }

        var bannerFrame: CGRect = self.bannerView.frame
        bannerFrame.origin.y = self.view.frame.size.height - 50 + self.tableView.contentOffset.y
        self.bannerView.frame = bannerFrame
    }
}
