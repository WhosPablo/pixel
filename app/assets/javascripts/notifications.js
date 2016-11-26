/**
 * Created by Luciano on 11/25/16.
 */

$(document).on("turbolinks:load", notificationListeners);
var foo;
function notificationListeners() {
    clearNotificationsOnClick();
}

function clearNotificationsOnClick() {
    $("#notifications-button").on('click', function(obj){
        $.ajax({
            url: '/users/' + obj.target.dataset['userid'] + '/clear_notifications',
            type: 'PUT',
            success: function() {
                resetNotificationsCount()
            }
        });
    });
}
function resetNotificationsCount() {
    $("#notifications-link").text('Notifications');
}
