$(document).on("turbolinks:load", questionSetup);

function questionSetup() {
    createMentionableRecipients();
    initializeCommentSlides();
    $('.question-body').linkify();
    autosize($('#question_body'));

}

function createMentionableRecipients(){
    $('.input-mentionable').ready(function() {
        $('.input-mentionable').atwho({
            at: '@',
            data: $('#mentionable-data').data('content'),
            insertTpl: '${username}, ',
            displayTpl: '<li data-id="${id}"><span>${username}</span></li>',
            limit: 15,
            searchKey: "username"
        });
    });
}

function initializeCommentSlides() {
    $(".show-comments-link").on("click", function(){
        $(this).parents(".question").find(".comments-section").slideToggle(600)
    })
}
