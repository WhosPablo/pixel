/**
 * Created by Luciano on 11/25/16.
 */

$(document).on("turbolinks:load", notificationListeners);
function notificationListeners() {
    clearNotificationsOnClick();
}

function clearNotificationsOnClick() {
    $("#notifications-link").on('click', function(obj){
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
    $(".notifications-count").text('');
    $("title").text('Quiki');
}

function incrementNotificationCount() {
    count = Number($(".notifications-count").text().replace(/[()]/g, ''));
    count++;
    string_count = "(" + count + ")";
    $(".notifications-count").text(string_count);
    $("title").text('Quiki ' + string_count);
}

function addNotification(notification) {
    incrementNotificationCount();
    $(".notification-menu").prepend("<li>" + notification + "</li>")
}
