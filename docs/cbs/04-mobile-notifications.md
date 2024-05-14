## Mobile notification

OrderStatus changes are streamed into a kafka topic. 
From there, they are forwarded to a backend system, 
which notifies corresponding Mobile Client. 

For example, we can use Google Firebase Cloud Messaging (FCM) 
for push notification to Android and IOS devices.
