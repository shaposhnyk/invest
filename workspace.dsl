workspace "Investment System" {
    !identifiers hierarchical
    !adrs adr
    !docs ./

    model {
        user = person "User" "Mobile Client"
        eis = softwareSystem "External Investment System"
        fcm = softwareSystem "Firebase Cloud Messaging"

        mb = softwareSystem "Application Gateway" {
            api = container "API"

            # user -> api "orders/list"
            user -> api "orders/submit(UID)"
        }

        cbs = softwareSystem "Core Banking System" {
            !adrs adr/cbs
            !docs docs/cbs

            kafka = container "Message Broker"
            pms = container "Portfolio Management System"

            group "Investment Application" {
                api = container "API"
                creator-app = container "Order Creator"
                validator-app = container "Order Validator"
                placer-app = container "Order Placer"
            }
            db = container "Order Database" {
                tags "Database"
            }
            db -> kafka "produces order changes"

            kafka -> creator-app "consumes orders" {
                tags "EventConsumer"
            }
            kafka -> validator-app "consumes PENDING orders" {
                tags "EventConsumer"
            }
            kafka -> placer-app "consumes REQUESTED orders" {
                tags "EventConsumer"
            }

            creator-app -> db "persists orders"
            validator-app -> db "PENDING -> REQUESTED*"
            validator-app -> pms "portfolio/reserveAmount"

            placer-app -> db "REQUESTED -> COMPLETED*"
        }

        # mb.api -> cbs.api "cbs/orders/list"
        mb.api -> cbs.api "cbs/orders/submit(UID)"
        eis -> cbs.api "orders/onComplete(UID)"

        cbs -> mb.api "notifies changes"
        mb.api -> fcm "notifies changes"
        fcm -> user "notifies changes"

        cbs.placer-app -> eis "placeOrder(UID)"
    }

    views {
        styles {
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "Person" {
                shape person
                background #084276
                color #ffffff
            }
            element "Database" {
                shape cylinder
            }
            relationship "Relationship" {
                dashed false
            }
            relationship "EventConsumer" {
                dashed true
            }
        }
    }

}
