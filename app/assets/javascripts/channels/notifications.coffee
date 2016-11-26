App.notifications = App.cable.subscriptions.create "NotificationsChannel",
  connected: ->
    console.log("connected")
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    if(data['title'] == "Notification")
      addNotification(data['body'])

    # Called when there's incoming data on the websocket for this channel
