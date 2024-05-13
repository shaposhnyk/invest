workspace {
    !identifiers hierarchical
    !adrs adr

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
            db = container "Order Database"
            db -> kafka "produces order changes"

            kafka -> creator-app "consumes orders"
            kafka -> validator-app "consumes PENDING orders"
            kafka -> placer-app "consumes REQUESTED orders"

            creator-app -> db "persists orders"
            validator-app -> db "PENDING -> REQUESTED*"
            validator-app -> pms "portfolio/reserveAmount"

            placer-app -> db "REQUESTED -> COMPLETED*"
        }

        # mb.api -> cbs.api "cbs/orders/list"
        mb.api -> cbs.api "cbs/orders/submit(UID)"
        eis -> mb.api "orders/onComplete(UID)"

        cbs -> mb.api "notifies changes"
        mb.api -> fcm "notifies changes"
        fcm -> user "notifies changes"

        cbs.placer-app -> eis "placeOrder(UID)"
    }

    views {
        systemContext mb "Overview" {
            include *
            exclude fcm
            include eis
            # autolayout lr
        }
        container cbs "Core" {
            include *
            # autoLayout
        }
        dynamic cbs {
            title "Making Investment Order"
            user -> mb.api "orders/submit(UID)"
            # mb.api -> cbs.api "cbs/orders/submit(UID)"
            # kafka -> cbs.creator-app "consumes CREATED event"
            # cbs.creator-app -> cbs.db "persists orders"
            #kafka -> cbs.validator-app "consumes PENDING event"
            #cbs.validator-app -> cbs.db "PENDING -> REQUESTED*"
            #kafka -> cbs.placer-app "consumes REQUESTED event"
            #cbs.placer-app -> cbs.db "REQUESTED -> COMPLETED*"
            autoLayout lr
        }

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
        }
    }

}
