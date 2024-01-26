//
//  IAPVC.swift
//  Radio Srood
//
//  Created by Hardik Chotaliya on 19/12/23.
//  Copyright © 2023 Appteve. All rights reserved.
//

import UIKit
import StoreKit

class IAPVC: UIViewController {
    
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var lblSrood: UILabel!
    @IBOutlet weak var lblPlus: UILabel!
    @IBOutlet weak var vwFeatures: UIView!
    
    @IBOutlet weak var lblFeature1: UILabel!
    @IBOutlet weak var lblFeature2: UILabel!
    @IBOutlet weak var lblFeature3: UILabel!
    
    @IBOutlet weak var segmentControlls: UISegmentedControl!
    
    @IBOutlet weak var lblSingleAccount: UILabel!
    
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var btnUpgradeToPlan: UIButton!
    
    private var isYearly: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
    }
    
    private func setUpUI() {
        
        lblSrood.text = "SROOD"
        lblPlus.text = "PLUS"
        lblFeature1.text = "No Ads - music without ads & unlimited skips."
        lblFeature2.text = "Download songs & albums to play them offline."
        lblFeature3.text = "High quality sound. 192-320 kHz"
        lblSingleAccount.text = "A Single account with access to the full Radio Srood experience."
//        lblPrice.text = "$4.99/Month"
        btnUpgradeToPlan.setTitle("Upgrade your plan", for: .normal)
        segmentControlls.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
//        for product in IAPHandler.shared.productArray! {
//            if let productIden = IAProduct(rawValue: product.productIdentifier) {
//                switch productIden {
//                case .Product_identifierOneMonth:
//
//                    if let currencySymbol = product.priceLocale.currencySymbol {
//                        print("Monthly price", "\(currencySymbol)" + "\(product.price.floatValue)")
//                        //                        lblMonthlyPrice.text = "\(currencySymbol)" + "\(product.price.floatValue)"
//                    } else {
//                        print("Yearly price","\(product.price.floatValue)" )
//                        //                        lblMonthlyPrice.text = "\(product.price.floatValue)"
//                    }
//                    break
//
//                case .Product_identifierYearly:
//                    if let currencySymbol = product.priceLocale.currencySymbol {
//                        print("Monthly price", "\(currencySymbol)" + "\(product.price.floatValue)")
//
//                        //                        lblYearlyPrice.text = "\(currencySymbol)" + "\(product.price.floatValue)"
//                    } else {
//                        print("Yearly price","\(product.price.floatValue)" )
//
//                        //                        lblYearlyPrice.text = "\(product.price.floatValue)"
//                    }
//
//                    break
//
//                }
//            }
//        }
        if Reachability.isConnectedToNetwork() {
            
            if let product = IAPHandler.shared.productArray?.first(where: { $0.productIdentifier == IAProduct.Product_identifierOneMonth.rawValue }) {
                updatePriceLabel(product)
            }
        } else {
            CustomLoader.shared.hideLoader()
            _ = CustomAlertController.alert(title: "Internet is not connected. Please check internet connectivity." )
        }

    }
    
    
    @objc func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            if let product = IAPHandler.shared.productArray?.first(where: { $0.productIdentifier == IAProduct.Product_identifierOneMonth.rawValue }) {
                updatePriceLabel(product)
                lblSingleAccount.text = "A Single account with access to the full Radio Srood experience."
                isYearly = false
            }
        } else {
            if let product = IAPHandler.shared.productArray?.first(where: { $0.productIdentifier == IAProduct.Product_identifierYearly.rawValue }) {
                updatePriceLabel(product)
                lblSingleAccount.text = "Save 16.5% by paying 12 months upfront."
                isYearly = true
            }
        }
    }

    private func updatePriceLabel(_ product: SKProduct) {
        let currencySymbol = product.priceLocale.currencySymbol ?? ""
        let price = "\(currencySymbol)\(product.price.floatValue)"
        let currencyCode = product.priceLocale.currencyCode ?? ""

        if product.productIdentifier == IAProduct.Product_identifierOneMonth.rawValue {
            lblPrice.text = "\(price) \(currencyCode) / Monthly"
        } else if product.productIdentifier == IAProduct.Product_identifierYearly.rawValue {
            lblPrice.text = "\(price) \(currencyCode) / Yearly"
        }
    }

    
    private func getProductDetails(productIdn: String) {
        
        if Reachability.isConnectedToNetwork() {
            if IAPHandler.shared.productArray == nil {
                IAPHandler.shared.fetchAvailableProducts { [self](products)   in
                    
                    if products.count != 0 {
                        guard let product = IAPHandler.shared.findPaymentIndex(productIdentifier: productIdn) else {
                            return
                        }
                        self.purchaseProduct(IAPHandler.shared.productArray![product])
                    }
                }
            } else {
                guard let product = IAPHandler.shared.findPaymentIndex(productIdentifier: productIdn) else {
                    return
                }
                self.purchaseProduct(IAPHandler.shared.productArray![product])
            }
        } else {
            CustomLoader.shared.hideLoader()
            _ = CustomAlertController.alert(title: "Internet is not connected. Please check internet connectivity." )
        }
        
    }
    
    private func purchaseProduct(_ product: SKProduct) {
        if Reachability.isConnectedToNetwork() {
            CustomLoader.shared.showLoader(in: self.view)
            IAPHandler.shared.purchase(product: product) { [weak self](alert, product, transaction) in
                if let tran = transaction, let prod = product {
                    
                    // use transaction details and purchased product as you want
                    print("\(tran.description)")
                    print("\(prod.productIdentifier)")
                    guard let sSelf = self else {return}
                    NotificationCenter.default.post(name: .PurchaseSuccess, object: nil)
                    sSelf.dismiss(animated: true, completion: {
                        CustomLoader.shared.hideLoader()
                        
                    })
                } else {
                    CustomLoader.shared.hideLoader()
                    guard let sSelf = self else {return}
                    runOnAfterTime(afterTime: 1, block: {
                        _ = CustomAlertController.alert(title: "\(alert.message)")
                    })
                }
            }
        } else {
            CustomLoader.shared.hideLoader()
            _ = CustomAlertController.alert(title: "Internet is not connected. Please check internet connectivity.")
        }
    }
    
    
    @IBAction func clickOn_btnBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func clickOn_btnUpgradeToPlan(_ sender: Any) {
        
        if isYearly {
            self.getProductDetails(productIdn: IAProduct.Product_identifierYearly.rawValue)
            
        } else {
            self.getProductDetails(productIdn: IAProduct.Product_identifierOneMonth.rawValue)
            
        }
    }
    
    
    
}
