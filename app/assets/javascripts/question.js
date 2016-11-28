
function createMentionableRecipients(){
    $('.input-mentionable').ready(function() {
        console.log("here")
        $('.input-mentionable').atwho({
            at: '@',
            data: $('#mentionable-data').data('content'),
            insertTpl: '${username}, ',
            displayTpl: '<li data-id="${id}"><span>${username}</span></li>',
            limit: 15,
            searchKey: "username"
        });
    });
};

$(document).ready(createMentionableRecipients);
$(document).on("turbolinks:load", createMentionableRecipients);
