
function createMentionableRecipients(){
    $(".question-recipients").ready(function() {
        $('.input-mentionable').atwho({
            at: '@',
            data: $('#mentionable-data').data('content'),
            insertTpl: '<a href="/users/${id}">${username}</a>',
            displayTpl: '<li data-id="${id}"><span>${username}</span></li>',
            limit: 15,
            searchKey: "username"
        });
    });
};

$(document).ready(createMentionableRecipients);
$(document).on("turbolinks:load", createMentionableRecipients);
