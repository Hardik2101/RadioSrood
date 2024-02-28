//
//  AdsAPIView.swift
//  Radio Srood
//
//  Created by Hardik Chotaliya on 04/02/24.
//  Copyright © 2024 Appteve. All rights reserved.
//

import UIKit
import AlamofireImage
import AVFoundation

protocol AdsAPIViewDelegate: AnyObject {
    func adsPlaybackDidFinish()
}

class AdsAPIView: UIViewController {

    @IBOutlet weak var vwMain: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var btnFollowus: UIButton!

    var adsCampaign: [AdsCampaign] = [AdsCampaign]()
    var audioPlayer: AVPlayer?
    var sliderTimer: Timer?
    weak var delegate: AdsAPIViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        apiCall()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        playAudio()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        audioPlayer?.pause()
        sliderTimer?.invalidate()
    }

    private func setUpUI() {
        self.btnFollowus.backgroundColor = UIColor.cyan
        self.btnFollowus.setTitleColor(.black, for: .normal)
        self.btnFollowus.layer.cornerRadius = 10
        self.btnFollowus.layer.borderWidth = 2
        self.btnFollowus.layer.borderColor = UIColor.cyan.cgColor
        
        self.btnBack.isHidden = true
    }

    private func apiCall() {
        ApiManager.fetchSroodAds { result in
            switch result {
            case .success(let sroodAds):
                self.adsCampaign = sroodAds.AdsCampaign
                DispatchQueue.main.async {
                    self.lblTitle.text = sroodAds.AdsCampaign[0].CampaignTitle
                    self.lblSubTitle.text = sroodAds.AdsCampaign[0].CampaignSubTitle
                    
                    if let campaignCoverURLString = sroodAds.AdsCampaign[0].CampaignCover, let campaignCoverURL = URL(string: campaignCoverURLString) {
                        self.imgLogo.af_setImage(withURL: campaignCoverURL, placeholderImage: UIImage(named: "Lav_Radio_Logo.png"))
                    } else {
                        // Handle the case where the campaign cover URL is nil or invalid
                        print("Campaign cover URL is nil or invalid.")
                        // You might want to set a default image or take some other action here
                    }

                    self.playAudio()
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    private func playAudio() {
//        guard let audioURL = URL(string: "https://mediahost.6cp4ukzdmze0dz21tovov7shhs1ldq5x.srood.stream/media/ads/Har-Laza-Bah-Shuma.mp3") else {
//            return
//        }
        
        
        guard let audioURL = URL(string: self.adsCampaign[0].CampaignAudio ?? "") else {
            return
        }

//        guard let audioURL = URL(string: "https://www2.cs.uic.edu/~i101/SoundFiles/StarWars3.wav") else {
//            return
//        }


        let playerItem = AVPlayerItem(url: audioURL)
        audioPlayer = AVPlayer(playerItem: playerItem)

        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)

        audioPlayer?.play()

        sliderTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if let duration = self.audioPlayer?.currentItem?.duration.seconds, duration > 0 {
                let progress = self.audioPlayer?.currentTime().seconds ?? 0
                let sliderValue = Float(progress / duration)
                self.slider.value = sliderValue

                // Update start and end time labels in "mm:ss" format
                self.lblStartTime.text = self.formatTime(seconds: progress)
                self.lblEndTime.text = self.formatTime(seconds: duration)
            }
        }
    }

    private func formatTime(seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    @objc private func playerDidFinishPlaying() {
        print("Song was ended.")
        self.dismiss(animated: true)
        delegate?.adsPlaybackDidFinish()
    }

    @IBAction func clickon_btnFollowUS(_ sender: Any) {
        if let url = URL(string: adsCampaign[0].CampaignLink ?? "https://facebook.com/radiosrood") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @IBAction func clickOn_btnBack(_ sender: Any) {
        // Handle back button click
    }
}
