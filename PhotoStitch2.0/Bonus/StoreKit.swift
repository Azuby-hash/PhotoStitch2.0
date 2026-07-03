//
//  StoreKit.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 7/2/26.
//

import StoreKit

enum StoreKitError: Error {
    case error(String)
}

@globalActor
actor StoreKit {
    static let shared = StoreKit()
    
    private(set) var products: [ProductPlan: ProductInfo] = [:]
    private var isPrePaid = false
    
    private var updatesTask: Task<Void, Never>?
    
    var isPro: Bool {
        get { products.values.contains(where: { $0.isActive }) || isPrePaid }
    }
    
    enum ProductPlan: String, CaseIterable {
        case weekly = "weekly"
        case yearly = "yearly"
    }
    
    func load() async throws {
        let pros = try await Product.products(for: ProductPlan.allCases.map({ $0.rawValue }))
        
        for pro in pros {
            guard let plan = ProductPlan(rawValue: pro.id) else { continue }
            products[plan] = try await ProductInfo(product: pro)
        }
        
        let result = try await AppTransaction.shared
        
        switch result {
        case .verified(let tranaction):
            print("Verified \(tranaction.originalPurchaseDate)")
            // User from 1 time paid app, will able to use all premium free forever
            
            if tranaction.originalPurchaseDate < Date(timeIntervalSinceNow: -213123123) {
                isPrePaid = true
            }
        case .unverified(let tranaction, let error):
            print("Unverified \(tranaction) \(error)")
        }
        
        if updatesTask == nil {
            updatesTask = Task {
                do {
                    for await result in Transaction.updates {
                        guard case .verified(let transaction) = result else { continue }
                        
                        await transaction.finish()
                        try await self.check()
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func restore() async throws {
        try await AppStore.sync()
        try await check()
    }
    
    func info(for plan: ProductPlan) throws -> ProductInfo {
        guard let productInfo = products[plan] else {
            throw StoreKitError.error("No product \(plan.rawValue)")
        }
        
        return productInfo
    }
    
    func check() async throws {
        var transactions = [Transaction]()
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            transactions.append(transaction)
        }
        
        for product in products.values {
            product.isActive = false
        }
        
        for product in products.values {
            if transactions.contains(where: { $0.productID == product.product.id }) {
                product.isActive = true
            }
        }
    }
    
    class ProductInfo {
        fileprivate(set) var product: Product
        fileprivate(set) var period: String
        fileprivate(set) var price: String
        fileprivate(set) var description: String
        fileprivate(set) var introPeriod: String?
        fileprivate(set) var isActive: Bool = false
        
        init(product: Product) async throws {
            guard let subscription = product.subscription else {
                throw StoreKitError.error("No product \(product.id)")
            }
            
            self.product = product
            self.period = await subscription.subscriptionPeriod.string(.frequency)
            self.price = product.displayPrice
            self.description = product.description
            
            if let introPeriod = await subscription.introductoryOffer?.period.string(.constant) {
                self.introPeriod = "\(introPeriod) free trial"
            }
        }
        
        func purchase() async throws {
            let result = try await product.purchase()
            
            if case let .success(verification) = result, case let .verified(transaction) = verification {
                await transaction.finish()
                try await StoreKit.shared.check()
            }
        }
    }
}

@StoreKit
extension Product.SubscriptionPeriod {
    enum PeriodStyle {
        case constant
        case frequency
    }
    
    func string(_ style: PeriodStyle) -> String {
        let value = value

        switch style {
        case .constant:
            switch unit {
            case .day:
                return value == 1 ? "1 day" : "\(value) days"
            case .week:
                return value == 1 ? "1 week" : "\(value) weeks"
            case .month:
                return value == 1 ? "1 month" : "\(value) months"
            case .year:
                return value == 1 ? "1 year" : "\(value) years"
            default:
                return "\(value)"
            }

        case .frequency:
            switch unit {
            case .day:
                return value == 1 ? "daily" : "every \(value) days"
            case .week:
                return value == 1 ? "weekly" : "every \(value) weeks"
            case .month:
                return value == 1 ? "monthly" : "every \(value) months"
            case .year:
                return value == 1 ? "yearly" : "every \(value) years"
            default:
                return "\(value)"
            }
        }
    }
}
