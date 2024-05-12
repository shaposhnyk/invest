workspace {
    !identifiers hierarchical
    !adrs adr

    model {
        user = person "User" "Mobile Client"
        eis = softwareSystem "External Investment System"
        pms = softwareSystem "Portfolio Management System"
        fcm = softwareSystem "Firebase Cloud Messaging"

        kafka = softwareSystem "Message Broker"

        mb = softwareSystem "Application Gateway" {
            api = container "API"
            api -> kafka "creation request(UID)"

            user -> api "orders/list"
            user -> api "orders/submit(UID)"
        }

        cbs = softwareSystem "Core Banking System" {
            !adrs adr/cbs
            !docs docs/cbs

            api = container "API"
            group "Investment Services" {
                creator-app = container "Order Creator"
                validator-app = container "Order Validator"
                placer-app = container "Order Placer"
            }
            db = container "Order Database"

            kafka -> creator-app "consumes orders"
            kafka -> validator-app "consumes PENDING orders"
            kafka -> placer-app "consumes REQUESTED orders"

            creator-app -> db "persists orders"
            validator-app -> db "PENDING -> REQUESTED*"
            placer-app -> db "REQUESTED -> COMPLETED*"
        }
        mb -> cbs.api "orders/list"
        eis -> cbs.api "orders/onComplete(UID)"

        cbs.db -> kafka "produces order changes"
        cbs -> mb.api "notifies changes"
        mb.api -> fcm "notifies changes"
        fcm -> user "notifies changes"

        cbs.placer-app -> eis "placeOrder(UID)"
        cbs.validator-app -> pms "portfolio/reserveAmount"
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
            mb.api -> kafka "pending creation"
            kafka -> cbs.creator-app "consumes CREATED event"
            cbs.creator-app -> cbs.db "persists orders"
            kafka -> cbs.validator-app "consumes PENDING event"
            cbs.validator-app -> cbs.db "PENDING -> REQUESTED*"
            kafka -> cbs.placer-app "consumes REQUESTED event"
            cbs.placer-app -> cbs.db "REQUESTED -> COMPLETED*"
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
