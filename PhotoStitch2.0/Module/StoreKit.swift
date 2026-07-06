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

extension StoreKit {
    static let infosDidChange = Notification.Name(UUID().uuidString)
}

class StoreKit {
    static let shared = StoreKit()
    
    private(set) var products: [ProductInfo] = []
    private var isPrePaid = false
    private var isGoneFree = false
    private(set) var isLoaded = false
    
    private var updatesTask: Task<Void, Never>?
    
    var isPro: Bool {
        get { products.contains(where: { $0.isActive }) || isPrePaid || isGoneFree }
    }
    
    typealias ProductPlan = SubscriptionPlan
    
    func load(_ freeUntilDate: Date = Date.init(timeIntervalSince1970: 0), _ isGoneFree: Bool = false) async throws {
        self.isGoneFree = isGoneFree
        let pros = try await Product.products(for: ProductPlan.allCases.map({ $0.rawValue }))
        
        products.removeAll()
        
        for pro in pros {
            guard let plan = ProductPlan(rawValue: pro.id) else { continue }
            products.append(try await ProductInfo(product: pro, plan: plan))
        }
        
        do {
            let result = try await AppTransaction.shared
            
            switch result {
            case .verified(let tranaction):
                print("Verified \(tranaction.originalPurchaseDate)")
                // User from 1 time paid app, will able to use all premium free forever
                if tranaction.originalPurchaseDate.timeIntervalSince1970 < freeUntilDate.timeIntervalSince1970 {
                    isPrePaid = true
                }
            case .unverified(let tranaction, let error):
                print("Unverified \(tranaction) \(error)")
            }
        } catch {
            print(error)
        }
        
        try await check()
        
        if updatesTask == nil {
            updatesTask = Task {
                for await result in Transaction.updates {
                    guard case .verified(let transaction) = result else { continue }
                    
                    await transaction.finish()
                    
                    do {
                        try await self.check()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func restore() async throws {
        try await AppStore.sync()
        try await check()
    }
    
    func info(for plan: ProductPlan) throws -> ProductInfo {
        guard let productInfo = products.first(where: { $0.plan == plan }) else {
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
        
        for product in products {
            product.isActive = false
        }
        
        for product in products {
            if transactions.contains(where: { $0.productID == product.product.id }) {
                product.isActive = true
            }
        }
        
        print("Grant subscription:", isPro)
        
        isLoaded = true
        
        NotificationCenter.default.post(name: StoreKit.infosDidChange, object: nil)
    }
    
    final class ProductInfo {
        fileprivate(set) var plan: ProductPlan
        fileprivate(set) var product: Product
        fileprivate(set) var period: String
        fileprivate(set) var price: String
        fileprivate(set) var unit: String
        fileprivate(set) var description: String
        fileprivate(set) var introPeriod: String?
        fileprivate(set) var isActive: Bool = false
        
        init(product: Product, plan: ProductPlan) async throws {
            guard let subscription = product.subscription else {
                throw StoreKitError.error("No product \(product.id)")
            }
            
            self.plan = plan
            self.product = product
            self.period = subscription.subscriptionPeriod.string(.frequency)
            self.price = product.displayPrice
            self.unit = subscription.subscriptionPeriod.string(.unit)
            self.description = product.description
            
            if let introPeriod = subscription.introductoryOffer?.period.string(.constant) {
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

extension Product.SubscriptionPeriod {
    enum PeriodStyle {
        case constant
        case frequency
        case unit
    }

    var normalized: (value: Int, unit: Unit) {
        let totalDays: Int

        switch unit {
        case .day:
            totalDays = value
        case .week:
            totalDays = value * 7
        case .month:
            // A month is not an exact number of days, so don't route months
            // through day-math. Just collapse 12/24/... months into years.
            return value % 12 == 0 ? (value / 12, .year) : (value, .month)
        case .year:
            return (value, .year)
        @unknown default:
            return (value, unit)
        }

        // Re-derive the largest unit that fits exactly (order matters).
        if totalDays % 365 == 0 { return (totalDays / 365, .year) }
        if totalDays % 30  == 0 { return (totalDays / 30,  .month) }
        if totalDays % 7   == 0 { return (totalDays / 7,   .week) }
        return (totalDays, .day)
    }

    func string(_ style: PeriodStyle) -> String {
        let (value, unit) = normalized

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
            @unknown default:
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
            @unknown default:
                return "\(value)"
            }

        case .unit:
            switch unit {
            case .day:
                return "day"
            case .week:
                return "week"
            case .month:
                return "month"
            case .year:
                return "year"
            @unknown default:
                return "unknown"
            }
        }
    }
}
